#pragma once

#include <string_view>

// ── Кроссплатформенный декоратор экспорта ────────────────────────────────
#if defined(_WIN32) || defined(__CYGWIN__)
    #ifdef PLUGIN_BUILDING_DLL
        #define PLUGIN_API __declspec(dllexport)
    #else
        #define PLUGIN_API __declspec(dllimport)
    #endif
#else
    #define PLUGIN_API __attribute__((visibility("default")))
#endif

/**
 * @namespace aw::example::plugin
 * @brief Пространство имён публичного API плагина.
 *
 * Все экспортируемые функции находятся в этом неймспейсе.
 * Функции экспортируются через extern "C" для совместимости
 * с динамическими загрузчиками (dlopen / LoadLibrary).
 */
namespace aw::example::plugin {

/**
 * @brief Возвращает текущую версию API.
 * @return Версия API (текущая: 1).
 */
extern "C" PLUGIN_API int plugin_version();

/**
 * @brief Возвращает строковое представление версии API.
 * @return Указатель на строку формата "plugin-api v<N>".
 */
extern "C" PLUGIN_API const char* plugin_version_string();

/**
 * @brief Вычисляет арифметическое выражение op(a, b).
 *
 * @param a Первое операнд.
 * @param b Второе операнд.
 * @param op Код операции: 0 = add, 1 = subtract, 2 = multiply.
 * @return Результат вычисления, либо -1 при неизвестной операции.
 */
extern "C" PLUGIN_API int plugin_compute(int a, int b, int op);

/**
 * @brief Возвращает строковое описание операции по её коду.
 *
 * @param op Код операции.
 * @return Указатель на строку: "add", "subtract", "multiply" или "unknown".
 */
extern "C" PLUGIN_API const char* plugin_op_name(int op);

} // namespace aw::example::plugin
