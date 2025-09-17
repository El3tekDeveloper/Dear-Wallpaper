#pragma once

#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <windows.h>

using namespace godot;

class DesktopWallpaperHelper : public Object {
    GDCLASS(DesktopWallpaperHelper, Object);

private:
    HWND hwndGodot = nullptr;
    HWND hwndDesktop = nullptr;
    DWORD originalStyle = 0;
    DWORD originalExStyle = 0;

public:
    DesktopWallpaperHelper() {}
    ~DesktopWallpaperHelper() {
        detach_from_desktop();
    }

    void attach_to_desktop() {
        if (!hwndGodot) {
            UtilityFunctions::printerr("No target window selected!");
            return;
        }

        hwndDesktop = get_workerw();
        if (!hwndDesktop) {
            UtilityFunctions::printerr("Failed to find WorkerW desktop window");
            return;
        }

        setup_window_for_wallpaper();
        UtilityFunctions::print("Target window attached to desktop successfully!");
    }


    void set_target_window_by_title(const String& title) {
        // تحويل Godot String إلى UTF-16
        Char16String c16 = title.utf16();
        const WCHAR* wtitle = reinterpret_cast<const WCHAR*>(c16.ptr());

        hwndGodot = FindWindowW(nullptr, wtitle);
        if (!hwndGodot) {
            UtilityFunctions::printerr("Cannot find window with title: " + title);
            return;
        }

        // حفظ الـ styles الأصلية
        originalStyle = GetWindowLongPtr(hwndGodot, GWL_STYLE);
        originalExStyle = GetWindowLongPtr(hwndGodot, GWL_EXSTYLE);

        UtilityFunctions::print("Window selected successfully: " + title);
    }


    void detach_from_desktop() {
        if (!hwndGodot) return;

        SetParent(hwndGodot, nullptr);
        SetWindowLongPtr(hwndGodot, GWL_STYLE, originalStyle);
        SetWindowLongPtr(hwndGodot, GWL_EXSTYLE, originalExStyle);
        
        SetWindowPos(hwndGodot, HWND_TOP, 100, 100, 800, 600, 
                     SWP_FRAMECHANGED | SWP_SHOWWINDOW);

        hwndGodot = nullptr;
        hwndDesktop = nullptr;
        
        UtilityFunctions::print("Godot window detached from desktop");
    }

    void update_position() {
        if (!hwndGodot || !hwndDesktop) return;

        int screenWidth = GetSystemMetrics(SM_CXSCREEN);
        int screenHeight = GetSystemMetrics(SM_CYSCREEN);

        SetWindowPos(hwndGodot, HWND_BOTTOM, 0, 0, screenWidth, screenHeight,
                     SWP_NOACTIVATE | SWP_FRAMECHANGED);
    }

    void refresh_wallpaper() {
        if (!hwndDesktop) return;
        
        hwndDesktop = get_workerw();
        if (hwndDesktop && hwndGodot) {
            SetParent(hwndGodot, hwndDesktop);
            update_position();
        }
    }

private:
    void setup_window_for_wallpaper() {
        if (!hwndGodot || !hwndDesktop) return;

        DWORD newStyle = WS_VISIBLE | WS_CHILD;
        DWORD newExStyle = WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW;

        SetWindowLongPtr(hwndGodot, GWL_STYLE, newStyle);
        SetWindowLongPtr(hwndGodot, GWL_EXSTYLE, newExStyle);

        SetParent(hwndGodot, hwndDesktop);

        int screenWidth = GetSystemMetrics(SM_CXSCREEN);
        int screenHeight = GetSystemMetrics(SM_CYSCREEN);

        SetWindowPos(hwndGodot, HWND_BOTTOM, 0, 0, screenWidth, screenHeight,
                     SWP_NOACTIVATE | SWP_FRAMECHANGED | SWP_SHOWWINDOW);

        SetWindowPos(hwndGodot, HWND_BOTTOM, 0, 0, 0, 0, 
                     SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);

        RedrawWindow(hwndGodot, nullptr, nullptr, 
                     RDW_INVALIDATE | RDW_UPDATENOW | RDW_ALLCHILDREN);
    }

    HWND get_workerw() {
        HWND progman = FindWindowW(L"Progman", nullptr);
        if (!progman) return nullptr;

        HWND workerw = nullptr;

        SendMessageTimeout(progman, 0x052C, 0, 0, SMTO_NORMAL, 1000, nullptr);

        EnumWindows([](HWND hwnd, LPARAM lParam) -> BOOL {
            HWND shellView = FindWindowExW(hwnd, nullptr, L"SHELLDLL_DefView", nullptr);
            if (shellView) {
                HWND* pWorkerW = reinterpret_cast<HWND*>(lParam);
                *pWorkerW = FindWindowExW(nullptr, hwnd, L"WorkerW", nullptr);
                return FALSE;
            }
            return TRUE;
        }, reinterpret_cast<LPARAM>(&workerw));

        return workerw;
    }

protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("attach_to_desktop"), &DesktopWallpaperHelper::attach_to_desktop);
        ClassDB::bind_method(D_METHOD("detach_from_desktop"), &DesktopWallpaperHelper::detach_from_desktop);
        ClassDB::bind_method(D_METHOD("update_position"), &DesktopWallpaperHelper::update_position);
        ClassDB::bind_method(D_METHOD("refresh_wallpaper"), &DesktopWallpaperHelper::refresh_wallpaper);
        ClassDB::bind_method(D_METHOD("set_target_window_by_title", "titel"), &DesktopWallpaperHelper::set_target_window_by_title);
    }
};