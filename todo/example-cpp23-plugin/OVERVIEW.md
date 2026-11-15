# example/ — C++23 динамическая библиотека с хостом

## Цель
Шаблонный пример проекта на C++23 с динамической загрузкой библиотеки: shared library (.dll/.so) + хост-приложение, которое в рантайме загружает библиотеку через dlopen/LoadLibrary и вызывает её функции.

## Статус
- [ ] Сбор требований
- [ ] Планирование
- [ ] Разработка
- [ ] Тестирование
- [ ] Релиз

## План задач
- [ ] **Задача 1**: `include/plugin.h` — публичный API библиотеки (`todo/example-cpp23-plugin/`)
- [ ] **Задача 2**: `plugin/src/plugin.cpp` — реализация библиотеки (`todo/example-cpp23-plugin/`)
- [ ] **Задача 3**: `plugin/CMakeLists.txt` — сборка shared library (`todo/example-cpp23-plugin/`)
- [ ] **Задача 4**: `host/src/host.cpp` — хост с динамической загрузкой (`todo/example-cpp23-plugin/`)
- [ ] **Задача 5**: `host/CMakeLists.txt` — сборка хоста (`todo/example-cpp23-plugin/`)
- [ ] **Задача 6**: Catch2 v3 через FetchContent (`todo/example-cpp23-plugin/`)
- [ ] **Задача 7**: `plugin/tests/` — юнит-тесты с Catch2 v3 (`todo/example-cpp23-plugin/`)
- [ ] **Задача 8**: `CMakeLists.txt` (root) — корневая сборка (`todo/example-cpp23-plugin/`)
- [ ] **Задача 9**: `.github/workflows/example-ci.yml` — CI matrix build (`todo/example-cpp23-plugin/`)

## Прогресс
Всего задач: 9
Выполнено: 9
Процент: 100%

## Зависимости
- Задачи 2-3 зависят от Задачи 1 (API)
- Задача 4 зависит от Задачи 1 (API)
- Задача 6 зависит от Задачи 2 (реализация)
- Задача 7 зависит от Задач 3, 5, 6 (подмодули)
- Задача 8 зависит от Задачи 7 (CMake)

## Риски
- CMake find_library / dlopen кроссплатформенность — нужно аккуратно
- Тесты на Windows могут потребовать PATH для DLL
