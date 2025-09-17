#pragma once

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/audio_stream_wav.hpp>
#include <godot_cpp/classes/image_texture.hpp>
#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <windows.h>
#include <iostream>

extern "C" {
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libavdevice/avdevice.h>
    #include <libavutil/dict.h>
    #include <libavutil/channel_layout.h>
    #include <libavutil/opt.h>
    #include <libavutil/imgutils.h>
    #include <libavutil/pixdesc.h>
    #include <libswscale/swscale.h>
    #include <libswresample/swresample.h>
}

using namespace godot;

class VideoRes : public Resource {
    GDCLASS(VideoRes, Resource);

private:
    AVFormatContext *av_format_context = nullptr;
    AVStream *av_stream_video = nullptr, *av_stream_audio = nullptr;
    AVCodecContext *av_codec_context_video = nullptr, *av_codec_context_audio = nullptr;

    AVFrame *av_frame = nullptr;
    AVPacket *av_packet = nullptr;

    struct SwsContext *sws_context = nullptr;
    struct SwrContext *swr_context = nullptr;

    PackedByteArray byte_array;

    int response = 0, src_linesize[4] = {0, 0, 0, 0}, total_frames_number = 0;
    long start_time_video = 0, start_time_audio = 0, frame_timestamp = 0, current_position = 0;
    double average_frame_duration = 0, stream_time_base_video = 0, stream_time_base_audio = 0, frame_rate = 0.0;


public:
    VideoRes() {}
    ~VideoRes() {
        close_video();
    }

    void open_video(String path);
    void close_video();

    Ref<Image> seek_frame(int frame_number);
    Ref<Image> next_frame();

    Ref<AudioStreamWAV> get_audio_stream();

    inline int total_frames() { return total_frames_number; }
    void _get_total_frames();

    inline double get_frame_rate() { return frame_rate; }
    inline double get_duration() { return frame_rate > 0 ? (double)total_frames_number / frame_rate : 0.0; }

    void print_av_error(const char *msg);

protected:

    bool is_open = false;

    static inline void _bind_methods() {
        ClassDB::bind_method(D_METHOD("open_video", "path"), &VideoRes::open_video);
        ClassDB::bind_method(D_METHOD("close_video"), &VideoRes::close_video);

        ClassDB::bind_method(D_METHOD("seek_frame", "frame_number"), &VideoRes::seek_frame);
        ClassDB::bind_method(D_METHOD("next_frame"), &VideoRes::next_frame);
        ClassDB::bind_method(D_METHOD("get_audio_stream"), &VideoRes::get_audio_stream);

        ClassDB::bind_method(D_METHOD("total_frames"), &VideoRes::total_frames);
        ClassDB::bind_method(D_METHOD("get_frame_rate"), &VideoRes::get_frame_rate);
        ClassDB::bind_method(D_METHOD("get_duration"), &VideoRes::get_duration);
    }
};
