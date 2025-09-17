#ifndef MY_EXTENSION_REGISTER_TYPES_H
#define MY_EXTENSION_REGISTER_TYPES_H

#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "wallpaper_writer.hpp"
#include "video_writer.hpp"
#include "desktop_wallpaper_helper.cpp"

using namespace godot;

void initialize_wallpaper_engine_library_init_module(ModuleInitializationLevel p_level);
void uninitialize_wallpaper_engine_library_init_module(ModuleInitializationLevel p_level);

#endif