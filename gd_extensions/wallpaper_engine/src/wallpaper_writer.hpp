#pragma once

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <windows.h>
#include <iostream>

extern "C" {
#include <libavformat/avformat.h>
}

using namespace godot;

class WallpaperRes : public Resource {
    GDCLASS(WallpaperRes, Resource);

private:
    String original_wallpaper;

public:
    void ChangeWallpaper(String path);
    void RestoreOriginalWallpaper();
    void TestFFmpeg();

protected:
    static inline void _bind_methods() {
        ClassDB::bind_method(D_METHOD("ChangeWallpaper", "path"), &WallpaperRes::ChangeWallpaper);
        ClassDB::bind_method(D_METHOD("RestoreOriginalWallpaper"), &WallpaperRes::RestoreOriginalWallpaper);
        ClassDB::bind_method(D_METHOD("TestFFmpeg"), &WallpaperRes::TestFFmpeg);
    }
};
