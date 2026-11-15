/**
 * @file host.cpp
 * @brief Хост-приложение для динамической загрузки плагина.
 *
 * В рантайме загружает библиотеку plugin (.so / .dll) и вызывает
 * экспортированные функции публичного API.
 *
 * Platform-specific детали инкапсулированы в aw::example::platform.
 */

#include "plugin.h"
#include "platform.h"

#include <format>
#include <iostream>
#include <optional>
#include <string>
#include <tuple>

/**
 * @namespace aw::example::host
 * @brief Пространство имён хост-приложения.
 *
 * Содержит логику загрузки плагина и вызова его функций.
 */
namespace aw::example::host {

/**
 * @brief Типы функций плагина.
 */
using version_fn     = int(*)();
using compute_fn     = int(*)(int, int, int);
using version_str_fn = const char*(*)();
using op_name_fn     = const char*(*) (int);

/**
 * @brief Загружает плагин и резолвит все требуемые символы.
 *
 * @return std::pair<handle, symbols> при успехе, std::nullopt при ошибке.
 */
inline std::optional<std::pair<
    aw::example::platform::LibraryHandle,
    std::tuple<version_fn, compute_fn, version_str_fn, op_name_fn>
>> load_plugin() {
    auto lib_path = aw::example::platform::find_plugin();
    if (!lib_path.has_value()) {
        std::cerr << "[host] Cannot find plugin path\n";
        return std::optional<std::pair<
            aw::example::platform::LibraryHandle,
            std::tuple<version_fn, compute_fn, version_str_fn, op_name_fn>
        >>();
    }

    const auto& path = lib_path.value();
    if (path.empty()) {
        std::cout << "[host] Loading plugin from system path\n";
    } else {
        std::cout << std::format("[host] Loading plugin from: {}\n", path);
    }

    auto lib = aw::example::platform::load_library(path);
    if (!lib) {
        std::cerr << "[host] Failed to load plugin\n";
        return std::nullopt;
    }

    auto* raw_version     = aw::example::platform::resolve_symbol(lib.value(), "plugin_version");
    auto* raw_compute     = aw::example::platform::resolve_symbol(lib.value(), "plugin_compute");
    auto* raw_version_s   = aw::example::platform::resolve_symbol(lib.value(), "plugin_version_string");
    auto* raw_op_name     = aw::example::platform::resolve_symbol(lib.value(), "plugin_op_name");

    if (!raw_version || !raw_compute || !raw_version_s || !raw_op_name) {
        std::cerr << "[host] Failed to resolve plugin symbols\n";
        aw::example::platform::unload_library(lib.value());
        return std::nullopt;
    }

    auto fn_version     = reinterpret_cast<version_fn>(raw_version);
    auto fn_compute     = reinterpret_cast<compute_fn>(raw_compute);
    auto fn_version_s   = reinterpret_cast<version_str_fn>(raw_version_s);
    auto fn_op_name     = reinterpret_cast<op_name_fn>(raw_op_name);

    return std::make_pair(
        std::move(lib.value()),
        std::make_tuple(fn_version, fn_compute, fn_version_s, fn_op_name)
    );
}

/**
 * @brief Выполняет все операции плагина и выводит результаты.
 *
 * @param lib Дескриптор библиотеки.
 * @param symbols std::tuple<version_fn, compute_fn, version_str_fn, op_name_fn>.
 */
inline void run_plugin(
    aw::example::platform::LibraryHandle& lib,
    const std::tuple<version_fn, compute_fn, version_str_fn, op_name_fn>& symbols
) {
    auto& [fn_version, fn_compute, fn_version_s, fn_op_name] = symbols;

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

    std::cout << std::format("  unknown({}, {}, 99) = {}\n",
                              a, b, fn_compute(a, b, 99));

    aw::example::platform::unload_library(lib);
}

} // namespace aw::example::host

/**
 * @brief Точка входа хост-приложения.
 *
 * @param argc Аргументы командной строки.
 * @param argv Аргументы командной строки.
 * @return 0 при успехе, код ошибки при неудаче.
 */
int main(int argc, char* argv[]) {
    (void)argc;
    (void)argv;

    std::cout << "=== Plugin Host ===" << '\n';

    auto result = aw::example::host::load_plugin();
    if (!result) {
        return 1;
    }

    aw::example::host::run_plugin(result->first, result->second);

    std::cout << "\n=== Done ===\n";
    return 0;
}
