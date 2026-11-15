# Task 04: Composite action `download-artifacts` helper

## Описание
Создать composite action `ci/actions/download-artifacts/`, который скачивает артефакты GitHub Actions с поддержкой pattern matching и merge-multiple.

## Контекст
В production workflow используется:
```yaml
- uses: actions/download-artifact@v4
  with:
    path: release-assets
    pattern: "*-release"
    merge-multiple: true
```

Это повторяется в разных workflow. Нужно вынести в reusable composite action с поддержкой:
- Скачивания по pattern (несколько артефактов)
- Скачивания конкретного artifact по name
- Merge-multiple режим
- Custom path

## Критерии готовности
- [ ] Создана директория `ci/actions/download-artifacts/` с `action.yml`
- [ ] Action принимает inputs: `path`, `pattern`, `name`, `merge-multiple`, `remove-empty`
- [ ] Action поддерживает скачивание по `pattern` + `merge-multiple` (для нескольких артефактов)
- [ ] Action поддерживает скачивание по `name` (для одного конкретного артефакта)
- [ ] Action создаёт output: `downloaded_files` (список файлов)
- [ ] README.md с примерами использования (pattern + name)

## Чек-лист выполнения
- [ ] Создать структуру action
- [ ] Реализовать pattern-based download с merge-multiple
- [ ] Реализовать name-based download
- [ ] Добавить output с списком скачанных файлов
- [ ] Написать README.md с примерами
- [ ] Добавить обработку case когда ни pattern ни name не указан (error)

## Зависимости
- Нет

## Результат
(заполняется после выполнения)
