/**
 * @file platform.cpp
 * @brief Реализация кроссплатформенной абстракции для динамических библиотек.
 *
 * Все platform-specific детали инкапсулированы здесь:
 * - Windows: LoadLibrary, FreeLibrary, GetProcAddress
 * - POSIX:   dlopen, dlclose, dlsym
 */

#include "platform.h"

#include <cstdlib>
#include <format>
#include <iostream>
#include <optional>
#include <string>

#if defined(_WIN32)
    #include <windows.h>
#else
    #include <dlfcn.h>
    #include <linux/limits.h>
    #include <unistd.h>
#endif

namespace aw::example::platform {

// ── load_library ─────────────────────────────────────────────────────────

std::optional<LibraryHandle> load_library(const std::string& path) {
    LibraryHandle lib;

#if defined(_WIN32)
    lib.handle = LoadLibraryA(path.c_str());
    if (!lib.handle) {
        auto err = GetLastError();
        std::cerr << std::format("[host] LoadLibrary failed: error code {} for '{}'",
                                  err, path) << '\n';
        return std::nullopt;
    }
#else
    lib.handle = dlopen(path.c_str(), RTLD_NOW | RTLD_LOCAL);
    if (!lib.handle) {
        std::cerr << std::format("[host] dlopen failed: {} for '{}'",
                                  dlerror(), path) << '\n';
        return std::nullopt;
    }
#endif

    return lib;
}

// ── unload_library ───────────────────────────────────────────────────────

void unload_library(LibraryHandle& lib) {
    if (!lib.handle) return;

#if defined(_WIN32)
    FreeLibrary(lib.handle);
#else
    dlclose(lib.handle);
#endif
    lib.handle = nullptr;
}

// ── resolve_symbol ───────────────────────────────────────────────────────

void* resolve_symbol(LibraryHandle& lib, std::string_view name) {
    if (!lib.handle) return nullptr;

#if defined(_WIN32)
    auto sym = GetProcAddress(lib.handle, name.data());
#else
    dlerror(); // Reset
    auto sym = dlsym(lib.handle, name.data());
    if (auto err = dlerror()) {
        std::cerr << std::format("[host] dlsym('{}') failed: {}", name, err) << '\n';
        return nullptr;
    }
#endif

    if (!sym) {
        std::cerr << std::format("[host] symbol '{}' not found", name) << '\n';
        return nullptr;
    }

    return sym;
}

// ── find_plugin ──────────────────────────────────────────────────────────

std::optional<std::string> find_plugin() {
    // 1. ENV var PLUGIN_PATH
    if (auto env = std::getenv("PLUGIN_PATH")) {
        return env;
    }

    // 2. Рядом с executable
#if defined(_WIN32)
    char exe_path[MAX_PATH] = {0};
    if (GetModuleFileNameA(nullptr, exe_path, MAX_PATH)) {
        std::string dir = exe_path;
        auto slash = dir.find_last_of('\\');
        if (slash != std::string::npos) {
            dir = dir.substr(0, slash) + "\\plugin.dll";
            return dir;
        }
    }
#else
    char exe_path[PATH_MAX] = {0};
    ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
    if (len > 0) {
        exe_path[len] = '\0';
        std::string dir = exe_path;
        auto slash = dir.find_last_of('/');
        if (slash != std::string::npos) {
            dir = dir.substr(0, slash) + "/libplugin.so";
            return dir;
        }
    }
#endif

    // 3. Системный путь
    return "";
}

} // namespace aw::example::platform
