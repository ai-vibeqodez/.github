/**
 * @file platform_unix.cpp
 * @brief POSIX implementation of the cross-platform dynamic library abstraction.
 *
 * Uses dlopen/dlclose/dlsym and /proc/self/exe:
 * - dlopen / dlclose — load/unload
 * - dlsym — symbol resolution
 * - readlink /proc/self/exe — executable path lookup
 */

#include "platform.h"

#include <array>
#include <dlfcn.h>
#include <format>
#include <iostream>
#include <linux/limits.h>
#include <string>
#include <unistd.h>

#if defined(__APPLE__)
#include <mach-o/dyld.h>
#include <libgen.h>
#endif

namespace aw::example::platform {

// ── load_library ─────────────────────────────────────────────────────────

std::optional<LibraryHandle> load_library(const std::string& path) {
    LibraryHandle lib;
    lib.handle = dlopen(path.c_str(), RTLD_NOW | RTLD_LOCAL);

    if (lib.handle == nullptr) {
        std::cerr << std::format("[host] dlopen failed: {} for '{}'", dlerror(), path) << '\n';
        return std::nullopt;
    }

    return lib;
}

// ── unload_library ───────────────────────────────────────────────────────

void unload_library(LibraryHandle& lib) {
    if (lib.handle == nullptr) {
        return;
    }
    dlclose(lib.handle);
    lib.handle = nullptr;
}

// ── resolve_symbol ───────────────────────────────────────────────────────

void* resolve_symbol(LibraryHandle& lib, std::string_view name) {
    if (lib.handle == nullptr) {
        return nullptr;
    }

    dlerror();
    auto* sym = dlsym(lib.handle, name.data());

    if (auto* err = dlerror()) {
        std::cerr << std::format("[host] dlsym('{}') failed: {}", name, err) << '\n';
        return nullptr;
    }

    if (sym == nullptr) {
        std::cerr << std::format("[host] symbol '{}' not found", name) << '\n';
        return nullptr;
    }

    return sym;
}

// ── find_plugin ──────────────────────────────────────────────────────────

std::optional<std::string> find_plugin() {
    // 1. ENV var PLUGIN_PATH
    if (auto* env = std::getenv("PLUGIN_PATH")) {
        return env;
    }

    // 2. Next to executable
#if defined(__APPLE__)
    char exe_path[MAXPATHLEN] = {0};
    uint32_t size = sizeof(exe_path);
    if (_NSGetExecutablePath(exe_path, &size) == 0) {
        std::string dir{exe_path};
        auto slash = dir.find_last_of('/');
        if (slash != std::string::npos) {
            dir = dir.substr(0, slash) + "/libplugin.so";
            return dir;
        }
    }
#else
    std::array<char, PATH_MAX> exe_path{};
    ssize_t len = readlink("/proc/self/exe", exe_path.data(), exe_path.size() - 1);
    if (len > 0) {
        exe_path[static_cast<size_t>(len)] = '\0';
        std::string dir{exe_path.data()};
        auto slash = dir.find_last_of('/');
        if (slash != std::string::npos) {
            dir = dir.substr(0, slash) + "/libplugin.so";
            return dir;
        }
    }
#endif

    // 3. System path
    return "";
}

} // namespace aw::example::platform
