# Task 03: plugin/CMakeLists.txt — сборка shared library

## Описание
CMakeLists.txt для сборки plugin как shared library (.dll/.so).

## Контекст
Библиотека собирается с C++23 стандартом. Имя: `plugin` (CMake добавит префикс и суффикс автоматически).

## Критерии готовности
- [ ] Файл `example/plugin/CMakeLists.txt` создан
- [ ] `add_library(plugin SHARED src/plugin.cpp)`
- [ ] `target_include_directories` с PUBLIC для include/
- [ ] C++23 стандарт: `set(CMAKE_CXX_STANDARD 23)`
- [ ] Компилируется на Linux и Windows

## Чек-лист выполнения
- [ ] Создать `plugin/CMakeLists.txt`
- [ ] Настроить C++23 и include directories
- [ ] Проверить билд (после корневого CMake)

## Зависимости
- Зависит от: task_01 (include/plugin.h)

## Результат
(заполняется после выполнения)
