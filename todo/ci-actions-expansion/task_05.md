# Task 05: Обновить `release.yml` шаблон — permissions + concurrency

## Описание
Обновить шаблон `.github/workflows/release.yml` (в `ci/.github/workflows/release.yml`) с правильными permissions и concurrency для release workflow.

## Контекст
Текущий `ci/.github/workflows/release.yml` имеет:
```yaml
permissions:
  contents: write
```

Но production workflow (MimironsGoldOMatic Release) требует:
```yaml
permissions:
  contents: write
  packages: write      # для GHCR
  actions: write       # для artifacts

concurrency:
  group: mimirons-release-${{ github.repository }}
  cancel-in-progress: false   # НЕ отменять中途 релиз!
```

Также нужно добавить concurrency в `ci.yml` и `test.yml` шаблоны.

## Критерии готовности
- [ ] Обновлён `ci/.github/workflows/release.yml`:
  - [ ] Добавлен `packages: write` permission
  - [ ] Добавлен `actions: write` permission
  - [ ] Добавлена `concurrency` секция с `cancel-in-progress: false`
- [ ] Обновлён `ci/.github/workflows/ci.yml`:
  - [ ] Добавлена `concurrency` секция (если нет)
- [ ] Обновлён `ci/.github/workflows/test.yml`:
  - [ ] Добавлена `concurrency` секция (если нет)
- [ ] Обновлён `ci/README.md` с описанием новых настроек
- [ ] Все workflow файлы прошли валидацию (syntax check)

## Чек-лист выполнения
- [ ] Прочитать текущий release.yml
- [ ] Добавить permissions: packages: write, actions: write
- [ ] Добавить concurrency с cancel-in-progress: false
- [ ] Проверить ci.yml — добавить concurrency если нет
- [ ] Проверить test.yml — добавить concurrency если нет
- [ ] Обновить README.md в ci/
- [ ] Проверить что syntax валиден (yq lint или аналог)

## Зависимости
- Нет

## Результат
(заполняется после выполнения)
