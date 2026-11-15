# Task 06: Catch2 v3 через FetchContent

## Описание
Подключить Catch2 v3 через CMake FetchContent — без внешних зависимостей, без submodule. CMake сам скачает и соберёт.

## Контекст
FetchContent — нативный CMake механизм для подтягивания зависимостей. Catch2 v3 header-only, собирается как `Catch2::Catch2WithMain` (для `main()` в тестах).

## Критерии готовности
- [ ] `FetchContent` блок в CMakeLists.txt
- [ ] Catch2 v3 скачивается и собирается автоматически
- [ ] `Catch2::Catch2WithMain` доступен для линковки
- [ ] Тесты линкуются с `Catch2::Catch2WithMain`

## Чек-лист выполнения
- [ ] Добавить FetchContent блок в `plugin/tests/CMakeLists.txt` или корневой
- [ ] Проверить что `find_package(Catch2)` работает после FetchContent
- [ ] Линковка с `Catch2::Catch2WithMain`

## Зависимости
Не зависит от других задач.

## Результат
(заполняется после выполнения)
