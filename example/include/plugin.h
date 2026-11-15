#pragma once

#include <cstdio>
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

// ── Публичный API ────────────────────────────────────────────────────────
// Возвращает версию API (текущая: 1).
extern "C" PLUGIN_API int plugin_version();

// Возвращает строковое представление версии API.
extern "C" PLUGIN_API const char* plugin_version_string();

// Вычисляет арифметическое выражение: op(a, b).
// op: 0 = add, 1 = subtract, 2 = multiply.
// Возвращает результат или -1 при неизвестной операции.
extern "C" PLUGIN_API int plugin_compute(int a, int b, int op);

// Возвращает строковое описание операции по её коду.
extern "C" PLUGIN_API const char* plugin_op_name(int op);
