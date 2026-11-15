# Task 07: CMakeLists.txt (root) + tests/CMakeLists.txt — корневая сборка

## Описание
Корневой CMakeLists.txt с `add_subdirectory` для plugin и host. tests/ — для интеграционных тестов.

## Контекст
Корневой CMakeLists.txt — точка входа. Собирает все подмодули. Опционально: `enable_testing()` + `add_test()`.

## Критерии готовности
- [ ] Файл `example/CMakeLists.txt` создан
- [ ] `cmake_minimum_required(VERSION 3.20)`
- [ ] `project(example LANGUAGES CXX)`
- [ ] `add_subdirectory(plugin)` + `add_subdirectory(host)`
- [ ] `enable_testing()` + `add_test()` для plugin/tests
- [ ] Файл `example/tests/CMakeLists.txt` создан (если нужен)
- [ ] `cmake . && make` собирает всё

## Чек-лист выполнения
- [ ] Создать `example/CMakeLists.txt`
- [ ] Создать `example/tests/CMakeLists.txt` (если нужно)
- [ ] Проверить сборку `cmake . && make`
- [ ] Проверить `ctest`

## Зависимости
- Зависит от: task_03, task_05, task_06 (подмодули)

## Результат
(заполняется после выполнения)
