#include "wallpaper_writer.hpp"

void WallpaperRes::ChangeWallpaper(String path) {
    if (original_wallpaper.is_empty()) {
        wchar_t buffer[MAX_PATH];
        SystemParametersInfoW(SPI_GETDESKWALLPAPER, MAX_PATH, buffer, 0);
        original_wallpaper = String(buffer);
    }

    String full_path = ProjectSettings::get_singleton()->globalize_path(path);
    const wchar_t* imagePath = (const wchar_t*)full_path.utf16().get_data();

    BOOL result = SystemParametersInfoW(
        SPI_SETDESKWALLPAPER,
        0,
        (PVOID)imagePath,
        SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
    );

    if (result) {
        UtilityFunctions::print_rich("[b]Wallpaper changed successfully.[/b]");
    } else {
        UtilityFunctions::print_rich("[b]Failed to change wallpaper.[/b]");
    }
}

void WallpaperRes::RestoreOriginalWallpaper() {
    if (!original_wallpaper.is_empty()) {
        const wchar_t* imagePath = (const wchar_t*)original_wallpaper.utf16().get_data();
        BOOL result = SystemParametersInfoW(
            SPI_SETDESKWALLPAPER,
            0,
            (PVOID)imagePath,
            SPIF_UPDATEINIFILE | SPIF_SENDCHANGE
        );

        if (result) {
            UtilityFunctions::print_rich("[b]Wallpaper restored successfully.[/b]");
        } else {
            UtilityFunctions::print_rich("[b]Failed to restore wallpaper.[/b]");
        }
    } else {
        UtilityFunctions::print_rich("[b]No original wallpaper saved.[/b]");
    }
}

void WallpaperRes::TestFFmpeg() {
    HMODULE h = LoadLibraryW(L"C:\\Users\\youel\\OneDrive\\Desktop\\Projects\\C++\\Wallpaper-Engine\\gd_extensions\\wallpaper_engine\\ffmpeg\\bin\\bin\\avformat-58.dll");
    if (!h) {
        UtilityFunctions::printerr("Failed to load avformat-58.dll");
        return;
    }
    int version = 0.0;
    UtilityFunctions::print("FFmpeg version: " + String::num_int64(version));
} 
