# Требования к проекту: example/ — C++23 динамическая библиотека с хостом

## Цель
Шаблонный пример проекта на C++23 с динамической загрузкой библиотеки: shared library (.dll/.so) + хост-приложение, которое в рантайме загружает библиотеку через dlopen/LoadLibrary и вызывает её функции.

## Стейкхолдеры
- Разработчики, копирующие этот репо как шаблон
- Целевая аудитория: C/C++ разработчики, которым нужен готовый паттерн динамической загрузки

## Функциональные требования

1. **Библиотека (plugin)** — компилируется в shared library (.dll на Windows, .so на Linux)
   - Публичный API через `include/plugin.h`
   - Функции: `plugin_version()` → int, `plugin_compute(int a, int b)` → int
   - Сборка через CMake

2. **Хост-приложение (host)** — executable, динамически загружает библиотеку
   - В рантайме ищет библиотеку (relative path к executable или по env var `PLUGIN_PATH`)
   - Использует `dlopen`/`dlsym` (Linux) или `LoadLibrary`/`GetProcAddress` (Windows)
   - Вызывает функции из библиотеки и выводит результат

3. **Тесты** — юнит-тесты библиотеки
   - Тестирование `plugin_compute()` и `plugin_version()`
   - Без динамической загрузки (прямой вызов)

4. **CMakeLists.txt** — сборка всего проекта
   - Корневой CMakeLists.txt с `add_subdirectory`
   - Каждый модуль (plugin, host) со своим CMakeLists.txt
   - Поддержка Linux + Windows

5. **CI** — билд на Ubuntu и Windows
   - Matrix build: ubuntu-latest + windows-latest
   - Сборка библиотеки и хоста
   - Запуск тестов

## Нефункциональные требования
- C++23 стандарт (std::format, std::expected, std::source_location)
- CMake 3.20+
- Без внешних зависимостей (только стандартная библиотека)
- Кроссплатформенность: Linux (.so) + Windows (.dll)

## Ограничения
- Только C++23, без фреймворков
- CMake как единственная билд-система
- Без зависимостей от внешних библиотек

## Приоритеты
- Must have: plugin library + host binary + tests + CMake + CI
- Should have: C++23 features (std::format, std::expected)
- Nice to have: error handling via std::expected, env var override for plugin path

## MVP
Рабочий пример: компилируется, тесты проходят, хост грузит библиотеку и вызывает функции. CI билдит на двух платформах.
