#include "plugin.h"

#include <cstdlib>
#include <filesystem>
#include <format>
#include <iostream>
#include <optional>
#include <string>
#include <system_error>

#if defined(_WIN32)
    #include <windows.h>
#else
    #include <dlfcn.h>
#endif

namespace fs = std::filesystem;

// ── Кроссплатформенный загрузчик библиотеки ──────────────────────────────

struct LibraryHandle {
#if defined(_WIN32)
    HMODULE handle = nullptr;
#else
    void* handle = nullptr;
#endif
};

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

void unload_library(LibraryHandle& lib) {
    if (!lib.handle) return;

#if defined(_WIN32)
    FreeLibrary(lib.handle);
#else
    dlclose(lib.handle);
#endif
    lib.handle = nullptr;
}

template <typename T>
std::optional<T> resolve_symbol(LibraryHandle& lib, const std::string& name) {
    if (!lib.handle) return std::nullopt;

#if defined(_WIN32)
    auto sym = GetProcAddress(lib.handle, name.c_str());
#else
    // Сбрасываем ошибку dlerror перед вызовом
    dlerror();
    auto sym = dlsym(lib.handle, name.c_str());
    if (auto err = dlerror()) {
        std::cerr << std::format("[host] dlsym('{}') failed: {}", name, err) << '\n';
        return std::nullopt;
    }
#endif

    if (!sym) {
        std::cerr << std::format("[host] symbol '{}' not found", name) << '\n';
        return std::nullopt;
    }

    return reinterpret_cast<T>(sym);
}

// ── Поиск библиотеки ─────────────────────────────────────────────────────

std::optional<std::string> find_plugin() {
    // 1. ENV var PLUGIN_PATH
    if (auto env = std::getenv("PLUGIN_PATH")) {
        return env;
    }

    // 2. Relative to executable
    auto exe_path = fs::canonical(fs::path(argv[0]).remove_filename());
#if defined(_WIN32)
    auto candidate = (exe_path / "plugin.dll").string();
#else
    auto candidate = (exe_path / "libplugin.so").string();
#endif
    if (fs::exists(candidate)) {
        return candidate;
    }

    // 3. System path — вернём пустую, dlopen/LoadLibrary попробует сам
    return "";
}

// ── Main ──────────────────────────────────────────────────────────────────

int main(int argc, char* argv[]) {
    std::cout << "=== Plugin Host ===" << '\n';

    // Находим библиотеку
    auto lib_path = find_plugin();
    if (!lib_path.has_value()) {
        std::cerr << "[host] Cannot find plugin path\n";
        return 1;
    }

    const auto& path = lib_path.value();
    if (path.empty()) {
        std::cout << "[host] Loading plugin from system path\n";
    } else {
        std::cout << std::format("[host] Loading plugin from: {}\n", path);
    }

    // Загружаем библиотеку
    auto lib = load_library(path);
    if (!lib) {
        std::cerr << "[host] Failed to load plugin\n";
        return 1;
    }

    // Резолвим символы
    using version_fn   = int(*)();
    using compute_fn   = int(*)(int, int, int);
    using version_str_fn = const char*(*)();
    using op_name_fn   = const char*(*)();

    auto fn_version   = resolve_symbol<version_fn>(lib.value(), "plugin_version");
    auto fn_compute   = resolve_symbol<compute_fn>(lib.value(), "plugin_compute");
    auto fn_version_s = resolve_symbol<version_str_fn>(lib.value(), "plugin_version_string");
    auto fn_op_name   = resolve_symbol<op_name_fn>(lib.value(), "plugin_op_name");

    if (!fn_version || !fn_compute || !fn_version_s || !fn_op_name) {
        std::cerr << "[host] Failed to resolve plugin symbols\n";
        unload_library(lib.value());
        return 1;
    }

    // Вызываем функции
    std::cout << "\n--- Plugin Info ---\n";
    std::cout << std::format("  version:     {}\n", fn_version());
    std::cout << std::format("  version_str: {}\n", fn_version_s());

    std::cout << "\n--- Operations ---\n";
    int a = 42, b = 13;
    for (int op = 0; op <= 2; ++op) {
        std::cout << std::format("  {}({}, {})\n",
                                  fn_op_name(op), a, b)
                  << std::format("    = {}\n", fn_compute(a, b, op));
    }

    // Тестируем неизвестную операцию
    std::cout << std::format("  unknown({}, {}, 99) = {}\n",
                              a, b, fn_compute(a, b, 99));

    // Очищаем
    unload_library(lib.value());
    std::cout << "\n=== Done ===\n";
    return 0;
}
