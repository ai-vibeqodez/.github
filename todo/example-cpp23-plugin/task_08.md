# Task 08: .github/workflows/example-ci.yml — CI matrix build

## Описание
GitHub Actions workflow для билда example проекта на Ubuntu и Windows.

## Контекст
Matrix build: ubuntu-latest + windows-latest. CMake + make/ninja. Запуск тестов на Ubuntu.

## Критерии готовности
- [ ] Файл `.github/workflows/example-ci.yml` создан
- [ ] Триггер: `pull_request` + `push` на main/master
- [ ] Matrix: ubuntu-latest + windows-latest
- [ ] CMake build для example/
- [ ] Запуск `ctest` на Ubuntu
- [ ] Успешный билд на обеих платформах

## Чек-лист выполнения
- [ ] Создать workflow
- [ ] Настроить matrix build
- [ ] Добавить step для cmake + build
- [ ] Добавить step для ctest (Ubuntu)
- [ ] Запушить и проверить

## Зависимости
- Зависит от: task_07 (CMake)

## Результат
(заполняется после выполнения)
