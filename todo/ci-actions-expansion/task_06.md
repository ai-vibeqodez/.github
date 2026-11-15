# Task 06: Разделить `checksums` action на `generate` + `verify`

## Описание
Разделить composite action `ci/actions/checksums/` на два отдельных action: `checksums-generate` и `checksums-verify`.

## Контекст
Текущий `ci/actions/checksums/action.yml` делает два действия в одном:
1. Генерирует SHA256SUMS.txt для артефактов
2. Верифицирует checksums

Проблема: в production workflow checksums генерируются **до** upload артефактов, а верифицируются **после** download артефактов. Эти два шага не могут быть в одном composite action, потому что они выполняются в разных контекстах (разные jobs).

Текущий action:
```yaml
# Step 1: Generate checksums
# Step 2: Verify checksums (сразу после генерации)
```

Нужно разделить:
- `checksums-generate`: генерирует SHA256SUMS.txt для файлов в директории
- `checksums-verify`: верифицирует SHA256SUMS.txt для файлов в директории

## Критерии готовности
- [ ] Создана директория `ci/actions/checksums-generate/` с `action.yml`
- [ ] `checksums-generate` принимает inputs: `artifacts_dir`, `checksums_file`
- [ ] `checksums-generate` генерирует SHA256SUMS.txt
- [ ] `checksums-generate` создаёт output: `checksums_file`
- [ ] Создана директория `ci/actions/checksums-verify/` с `action.yml`
- [ ] `checksums-verify` принимает inputs: `artifacts_dir`, `checksums_file`
- [ ] `checksums-verify` верифицирует SHA256SUMS.txt
- [ ] Старый `ci/actions/checksums/` помечен как deprecated (README + warning в action.yml)
- [ ] Обновлён `ci/README.md` с описанием двух новых actions
- [ ] Обновлены `ci/.github/workflows/release.yml` — использовать новые actions

## Чек-лист выполнения
- [ ] Создать `checksums-generate/` с extract-ированной логикой генерации
- [ ] Создать `checksums-verify/` с extract-ированной логикой verify
- [ ] Пометить старый `checksums/` как deprecated
- [ ] Обновить release.yml шаблон — использовать generate + verify отдельно
- [ ] Обновить ci/README.md
- [ ] Проверить что все ссылки обновлены

## Зависимости
- Нет

## Результат
(заполняется после выполнения)
