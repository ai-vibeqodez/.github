/**
 * @file platform_windows.cpp
 * @brief Windows implementation of the cross-platform dynamic library abstraction.
 *
 * Uses Win32 API:
 * - LoadLibrary / FreeLibrary — load/unload
 * - GetProcAddress — symbol resolution
 * - GetModuleFileName — executable path lookup
 */

#include "platform.h"

#include <format>
#include <iostream>
#include <optional>
#include <string>
#include <windows.h>

namespace aw::example::platform {

// ── load_library ─────────────────────────────────────────────────────────

std::optional<LibraryHandle> load_library(const std::string& path) {
    LibraryHandle lib;
    lib.handle = LoadLibraryA(path.c_str());

    if (lib.handle == nullptr) {
        auto err = GetLastError();
        std::cerr << std::format("[host] LoadLibrary failed: error code {} for '{}'", err, path) << '\n';
        return std::nullopt;
    }

    return lib;
}

// ── unload_library ───────────────────────────────────────────────────────

void unload_library(LibraryHandle& lib) {
    if (lib.handle == nullptr) {
        return;
    }
    FreeLibrary(static_cast<HMODULE>(lib.handle));
    lib.handle = nullptr;
}

// ── resolve_symbol ───────────────────────────────────────────────────────

void* resolve_symbol(LibraryHandle& lib, std::string_view name) {
    if (lib.handle == nullptr) {
        return nullptr;
    }

    auto sym = GetProcAddress(static_cast<HMODULE>(lib.handle), name.data());

    if (sym == nullptr) {
        std::cerr << std::format("[host] symbol '{}' not found", name) << '\n';
        return nullptr;
    }

    return sym;
}

// ── find_plugin ──────────────────────────────────────────────────────────

std::optional<std::string> find_plugin() {
    // 1. ENV var PLUGIN_PATH
    char buf[MAX_PATH] = {0};
    if (GetEnvironmentVariableA("PLUGIN_PATH", buf, MAX_PATH) > 0) {
        return buf;
    }

    // 2. Next to executable
    char exe_path[MAX_PATH] = {0};
    if (GetModuleFileNameA(nullptr, exe_path, MAX_PATH)) {
        std::string dir = exe_path;
        auto slash = dir.find_last_of('\\');
        if (slash != std::string::npos) {
            dir = dir.substr(0, slash) + "\\plugin.dll";
            return dir;
        }
    }

    // 3. System path
    return "";
}

} // namespace aw::example::platform
