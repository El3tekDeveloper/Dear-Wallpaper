#pragma once

#include <godot_cpp/classes/control.hpp>
#include <godot_cpp/classes/project_settings.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <windows.h>
#include <iostream>

using namespace godot;

class WallpaperRes : public Resource {
    GDCLASS(WallpaperRes, Resource);

private:
    String original_wallpaper;

public:
    void ChangeWallpaper(String path);
    void RestoreOriginalWallpaper();

protected:
    static inline void _bind_methods() {
        ClassDB::bind_method(D_METHOD("ChangeWallpaper", "path"), &WallpaperRes::ChangeWallpaper);
        ClassDB::bind_method(D_METHOD("RestoreOriginalWallpaper"), &WallpaperRes::RestoreOriginalWallpaper);
    }
};
