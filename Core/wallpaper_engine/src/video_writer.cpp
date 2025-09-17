#include "video_writer.hpp"

void VideoRes::open_video(String path) {
    av_format_context = avformat_alloc_context();
    if (!av_format_context)
        { UtilityFunctions::printerr("Could not allocate format context"); return; }

    if (avformat_open_input(&av_format_context, path.utf8(), NULL, NULL))
        { UtilityFunctions::printerr("Could not open video file: " + path); close_video(); return; }

    if (avformat_find_stream_info(av_format_context, NULL))
        { UtilityFunctions::printerr("Could not find stream information"); close_video(); return; }

    for (int i = 0; i < av_format_context->nb_streams; i++) {
        AVCodecParameters *av_codec_params = av_format_context->streams[i]->codecpar;

        if (!avcodec_find_decoder(av_codec_params->codec_id))
            continue;
        else if (av_codec_params->codec_type == AVMEDIA_TYPE_VIDEO)
            av_stream_video = av_format_context->streams[i];
        else if (av_codec_params->codec_type == AVMEDIA_TYPE_AUDIO)
            av_stream_audio = av_format_context->streams[i];
    }

    // Video Decoding
    const AVCodec *av_codec_video = avcodec_find_decoder(av_stream_video->codecpar->codec_id);
    if (!av_codec_video)
        { UtilityFunctions::printerr("Could not find video codec"); close_video(); return; }

    av_codec_context_video = avcodec_alloc_context3(av_codec_video);
    if (!av_codec_context_video)
        { UtilityFunctions::printerr("Could not allocate video codec context"); close_video(); return; }

    if (avcodec_parameters_to_context(av_codec_context_video, av_stream_video->codecpar))
        { UtilityFunctions::printerr("Could not initialize video codec parameters to context"); close_video(); return; }

    av_codec_context_video->thread_count = 0;
    if  (av_codec_video->capabilities & AV_CODEC_CAP_FRAME_THREADS)
        av_codec_context_video->thread_type = FF_THREAD_FRAME;
    else if (av_codec_video->capabilities & AV_CODEC_CAP_SLICE_THREADS)
        av_codec_context_video->thread_type = FF_THREAD_SLICE;
    else av_codec_context_video->thread_count = 1;
    
    if (avcodec_open2(av_codec_context_video, av_codec_video, NULL))
        { UtilityFunctions::printerr("Could not open video codec"); close_video(); return; }

    sws_context = sws_getContext(
        av_codec_context_video->width, av_codec_context_video->height, (AVPixelFormat)av_stream_video->codecpar->format,
        av_codec_context_video->width, av_codec_context_video->height, AV_PIX_FMT_RGB24,
        SWS_BILINEAR, NULL, NULL, NULL);
    if (!sws_context)
        { UtilityFunctions::printerr("Could not initialize SWScale context"); close_video(); return; }

    byte_array.resize(av_codec_context_video->width * av_codec_context_video->height * 3);
    src_linesize[0] = av_codec_context_video->width * 3;

    stream_time_base_video = av_q2d(av_stream_video->time_base) * 1000.0 * 1000.0; // microseconds
    start_time_video = av_stream_video->start_time != AV_NOPTS_VALUE ? (long)(av_stream_video->start_time * stream_time_base_video) : 0;

    frame_rate = av_q2d(av_stream_video->r_frame_rate);
    average_frame_duration = 1000000.0 / frame_rate;
    _get_total_frames();

    // Audio Decoding
    const AVCodec *av_codec_audio = avcodec_find_decoder(av_stream_audio->codecpar->codec_id);
    if (!av_codec_audio)
    { UtilityFunctions::printerr("Could not find audio codec"); close_video(); return; }
    
    av_codec_context_audio = avcodec_alloc_context3(av_codec_audio);
    if (!av_codec_context_audio)
    { UtilityFunctions::printerr("Could not allocate audio codec context"); close_video(); return; }
    
    if (avcodec_parameters_to_context(av_codec_context_audio, av_stream_audio->codecpar))
    { UtilityFunctions::printerr("Could not initialize audio codec parameters to context"); close_video(); return; }
    
    av_codec_context_audio->thread_count = 0;
    if  (av_codec_audio->capabilities & AV_CODEC_CAP_FRAME_THREADS)
    av_codec_context_audio->thread_type = FF_THREAD_FRAME;
    else if (av_codec_audio->capabilities & AV_CODEC_CAP_SLICE_THREADS)
    av_codec_context_audio->thread_type = FF_THREAD_SLICE;
    else av_codec_context_audio->thread_count = 1;
    
    if (avcodec_open2(av_codec_context_audio, av_codec_audio, NULL))
    { UtilityFunctions::printerr("Could not open audio codec"); close_video(); return; }
    
    av_codec_context_audio->request_sample_fmt = AV_SAMPLE_FMT_S16;
    response = swr_alloc_set_opts2(&swr_context,
        &av_codec_context_audio->ch_layout, AV_SAMPLE_FMT_S16, av_codec_context_audio->sample_rate,
        &av_codec_context_audio->ch_layout, av_codec_context_audio->sample_fmt, av_codec_context_audio->sample_rate,
        0, NULL);
        
    if (response < 0) { print_av_error("Failed to obtain SWR context"); close_video(); return; }
    else if (!swr_context) { UtilityFunctions::printerr("Could not allocate SWR context"); close_video(); return; }
    
    response = swr_init(swr_context) < 0;
    if (response < 0) { print_av_error("Failed to initialize SWR context"); close_video(); return; }
    
    stream_time_base_audio = av_q2d(av_stream_audio->time_base) * 1000.0 * 1000.0; // microseconds
    start_time_audio = av_stream_audio->start_time != AV_NOPTS_VALUE ? (long)(av_stream_audio->start_time * stream_time_base_audio) : 0;

    is_open = true;
}

Ref<AudioStreamWAV> VideoRes::get_audio_stream() {
    Ref<AudioStreamWAV> audio_wav = memnew(AudioStreamWAV);

    if (!is_open) { UtilityFunctions::printerr("Video file is not opened"); return audio_wav; }

    response = av_seek_frame(av_format_context, av_stream_audio->index, start_time_audio, AVSEEK_FLAG_ANY | AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(av_codec_context_audio);
    if (response < 0) 
        { UtilityFunctions::printerr("Error seeking to the beginning of the audio stream"); return audio_wav; }
    
    av_packet = av_packet_alloc();
    av_frame = av_frame_alloc();
    PackedByteArray audio_data = PackedByteArray();
    size_t audio_size = 0;
    
    while (av_read_frame(av_format_context, av_packet) >= 0)
    {
        if (av_packet->stream_index == av_stream_audio->index) {
            response = avcodec_send_packet(av_codec_context_audio, av_packet);
            if (response < 0) {
                UtilityFunctions::printerr("Error sending audio packet to decoder");
                av_packet_unref(av_packet);
                break;
            }
            
            while (response >= 0) {
                response = avcodec_receive_frame(av_codec_context_audio, av_frame);
                if (response == AVERROR(EAGAIN) || response == AVERROR_EOF)
                break;
                else if (response < 0) {
                    UtilityFunctions::printerr("Error receiving audio frame from decoder");
                    break;
                }
                
                AVFrame *av_new_frame = av_frame_alloc();
                av_new_frame->format = AV_SAMPLE_FMT_S16;
                av_new_frame->ch_layout = av_frame->ch_layout;
                av_new_frame->sample_rate = av_frame->sample_rate;
                av_new_frame->nb_samples = swr_get_out_samples(swr_context, av_frame->nb_samples);

                response = av_frame_get_buffer(av_new_frame, 0);
                if (response < 0) {
                    print_av_error("Could not create new frame");
                    av_frame_unref(av_frame);
                    av_frame_unref(av_new_frame);
                    break;
                }

                response = swr_convert_frame(swr_context, av_new_frame, av_frame);
                if (response < 0) {
                    print_av_error("Could not convert audio frame");
                    av_frame_unref(av_frame);
                    av_frame_unref(av_new_frame);
                    break;
                }

                size_t byte_size = av_new_frame->nb_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16);
                if (av_codec_context_audio->ch_layout.nb_channels >= 2)
                    byte_size *= 2;
                
                audio_data.resize(audio_size + byte_size);
                memcpy(&(audio_data.ptrw()[audio_size]), av_new_frame->extended_data[0], byte_size);
                audio_size += byte_size;
                
                av_frame_unref(av_frame);
            }
        }
        av_packet_unref(av_packet);
    }
    
    av_frame_free(&av_frame);
    av_packet_free(&av_packet);
    
    audio_wav->set_format(audio_wav->FORMAT_16_BITS);
    audio_wav->set_data(audio_data);
    audio_wav->set_mix_rate(av_codec_context_audio->sample_rate);
    audio_wav->set_stereo(av_codec_context_audio->ch_layout.nb_channels >= 2);
    
    return audio_wav;
}

Ref<Image> VideoRes::seek_frame(int frame_number) {
    Ref<Image> image = memnew(Image);
    if (!is_open) { UtilityFunctions::printerr("Video file is not opened"); return image; }

    frame_timestamp = (long)(average_frame_duration * frame_number);
    response = av_seek_frame(av_format_context, -1, start_time_video + frame_timestamp, AVSEEK_FLAG_BACKWARD | AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(av_codec_context_video);
    if (response < 0) { 
        UtilityFunctions::printerr("Error seek video file"); 
        av_frame_free(&av_frame);
        av_packet_free(&av_packet);
        return image; 
    }

    av_packet = av_packet_alloc();
    av_frame = av_frame_alloc();
    
    while (true)
    {
        response = av_read_frame(av_format_context, av_packet);
        if (response != 0) break;
        
        if (av_packet->stream_index != av_stream_video->index) {
            av_packet_unref(av_packet);
            continue;
        }
        
        response = avcodec_send_packet(av_codec_context_video, av_packet);
        av_packet_unref(av_packet);
        if (response != 0) break;

        while (true)
        {
            response = avcodec_receive_frame(av_codec_context_video, av_frame);
            if (response != 0) {
                av_frame_unref(av_frame);
                break;
            }

            current_position = av_frame->best_effort_timestamp == AV_NOPTS_VALUE ? av_frame->pts : av_frame->best_effort_timestamp;
            if (current_position == AV_NOPTS_VALUE) 
                { av_frame_unref(av_frame); continue; }

            if ((long)(current_position * stream_time_base_video) / 10000 < frame_timestamp / 10000) 
                { av_frame_unref(av_frame); continue; }

            uint8_t *dest_data[1] = { byte_array.ptrw() };
            sws_scale(sws_context, av_frame->data, av_frame->linesize, 0, av_frame->height, dest_data, src_linesize);
            image->set_data(av_frame->width, av_frame->height, 0, image->FORMAT_RGB8, byte_array);

            av_frame_unref(av_frame);
            av_frame_free(&av_frame);
            av_packet_free(&av_packet);
            
            return image;
        }
    }

    av_frame_free(&av_frame);
    av_packet_free(&av_packet);
    return image;
}

Ref<Image> VideoRes::next_frame() {
    Ref<Image> image = memnew(Image);
    if (!is_open) { UtilityFunctions::printerr("Video file is not opened"); return image; }

    av_packet = av_packet_alloc();
    av_frame = av_frame_alloc();
    
    while (true)
    {
        response = av_read_frame(av_format_context, av_packet);
        if (response != 0) break;
        
        if (av_packet->stream_index != av_stream_video->index) {
            av_packet_unref(av_packet);
            continue;
        }
        
        response = avcodec_send_packet(av_codec_context_video, av_packet);
        av_packet_unref(av_packet);
        if (response != 0) break;

        while (true)
        {
            response = avcodec_receive_frame(av_codec_context_video, av_frame);
            if (response != 0) {
                av_frame_unref(av_frame);
                break;
            }

            uint8_t *dest_data[1] = { byte_array.ptrw() };
            sws_scale(sws_context, av_frame->data, av_frame->linesize, 0, av_frame->height, dest_data, src_linesize);
            image->set_data(av_frame->width, av_frame->height, 0, image->FORMAT_RGB8, byte_array);

            av_frame_unref(av_frame);
            av_frame_free(&av_frame);
            av_packet_free(&av_packet);
            
            return image;
        }
    }

    av_frame_free(&av_frame);
    av_packet_free(&av_packet);
    return image;
}

void VideoRes::_get_total_frames() {
    UtilityFunctions::print(av_stream_video->nb_frames);

    if (av_stream_video->nb_frames > 500)
        total_frames_number = av_stream_video->nb_frames - 30;
    
    av_packet = av_packet_alloc();
    av_frame = av_frame_alloc();

    frame_timestamp = (long)(average_frame_duration * total_frames_number);
    response = av_seek_frame(av_format_context, -1, start_time_video + frame_timestamp, AVSEEK_FLAG_BACKWARD | AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(av_codec_context_video);
    if (response < 0) { 
        UtilityFunctions::printerr("Error seek video stream"); 
        av_frame_free(&av_frame);
        av_packet_free(&av_packet);
    }

    while (true)
    {
        response = av_read_frame(av_format_context, av_packet);
        if (response != 0) break;
        
        if (av_packet->stream_index != av_stream_video->index) {
            av_packet_unref(av_packet);
            continue;
        }
        
        response = avcodec_send_packet(av_codec_context_video, av_packet);
        av_packet_unref(av_packet);
        if (response != 0) break;

        while (true)
        {
            response = avcodec_receive_frame(av_codec_context_video, av_frame);
            if (response != 0) {
                av_frame_unref(av_frame);
                break;
            }

            current_position = av_frame->best_effort_timestamp == AV_NOPTS_VALUE ? av_frame->pts : av_frame->best_effort_timestamp;
            if (current_position == AV_NOPTS_VALUE) 
                { av_frame_unref(av_frame); continue; }

            if ((long)(current_position * stream_time_base_video) / 10000 < frame_timestamp / 10000) 
                { av_frame_unref(av_frame); continue; }

            total_frames_number++;
        }
    }    
}

void VideoRes::close_video() {
    is_open = false;

    if (av_format_context) avformat_close_input(&av_format_context);
    if (av_codec_context_video) avcodec_free_context(&av_codec_context_video);
    if (av_codec_context_audio) avcodec_free_context(&av_codec_context_audio);
    if (swr_context) swr_free(&swr_context);
    if (sws_context) sws_freeContext(sws_context);
    if (av_frame) av_frame_free(&av_frame);
    if (av_packet) av_packet_free(&av_packet);
}

void VideoRes::print_av_error(const char *msg) {
    char errbuf[AV_ERROR_MAX_STRING_SIZE];
    av_strerror(response, errbuf, sizeof(errbuf));
    UtilityFunctions::printerr((std::string(msg) + ": " + errbuf).c_str());
}