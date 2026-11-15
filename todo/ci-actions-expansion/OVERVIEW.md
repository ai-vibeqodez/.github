# CI/Actions Expansion — OVERVIEW

## Цель
Расширить набор composite actions и workflow шаблонов в `ci/` на основе production workflow (MimironsGoldOMatic Release), который использует параллельные билды (desktop, WoW addon, Twitch extension, Docker backend) и собирает артефакты в единый GitHub Release + GHCR image.

## Статус
- [x] Сбор требований
- [x] Планирование
- [ ] Разработка
- [ ] Тестирование
- [ ] Релиз

## План задач
- [ ] **Задача 1**: Composite action `collect-release-assets` (`todo/ci-actions-expansion/task_01.md`)
- [ ] **Задача 2**: Composite action `docker-save` (`todo/ci-actions-expansion/task_02.md`)
- [ ] **Задача 3**: Composite action `docker-push-ghcr` (`todo/ci-actions-expansion/task_03.md`)
- [ ] **Задача 4**: Composite action `download-artifacts` helper (`todo/ci-actions-expansion/task_04.md`)
- [ ] **Задача 5**: Обновить `release.yml` шаблон — permissions + concurrency (`todo/ci-actions-expansion/task_05.md`)
- [ ] **Задача 6**: Разделить `checksums` action на `generate` + `verify` (`todo/ci-actions-expansion/task_06.md`)

## Прогресс
Всего задач: 6
Выполнено: 0
Процент: 0%

## Зависимости
- Задача 1 зависит от: нет (но использует checksums)
- Задача 2: независима
- Задача 3 зависит от: нет (но использует login-action)
- Задача 4: независима
- Задача 5: независима
- Задача 6 зависит от: нет (модификация существующего)

## Риски
- Риск 1: Composite actions не поддерживают `needs` — артефакты из других jobs нужно скачивать в workflow, не в action
- Риск 2: `docker save/load` работает только на одном runner'е — нужно убедиться что save и load на одном job
