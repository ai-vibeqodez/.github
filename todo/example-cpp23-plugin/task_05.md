# Task 05: host/CMakeLists.txt — сборка хоста

## Описание
CMakeLists.txt для сборки host executable.

## Контекст
Host линкуется с dl (Linux) для dlopen. На Windows стандартная библиотека.

## Критерии готовности
- [ ] Файл `example/host/CMakeLists.txt` создан
- [ ] `add_executable(host src/host.cpp)`
- [ ] Линковка с `dl` на Linux (`target_link_libraries`)
- [ ] C++23 стандарт
- [ ] Компилируется на Linux и Windows

## Чек-лист выполнения
- [ ] Создать `host/CMakeLists.txt`
- [ ] Настроить линковку с dl (conditionally)
- [ ] Проверить билд (после корневого CMake)

## Зависимости
- Зависит от: task_01 (API)

## Результат
(заполняется после выполнения)
