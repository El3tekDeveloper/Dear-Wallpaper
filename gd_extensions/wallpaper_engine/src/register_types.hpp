#pragma once

#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;

void initialize_wallpaper_engine_library_init_module(ModuleInitializationLevel p_level);
void uninitialize_wallpaper_engine_library_init_module(ModuleInitializationLevel p_level);