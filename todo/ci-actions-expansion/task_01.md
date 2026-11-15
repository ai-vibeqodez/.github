# Task 01: Composite action `collect-release-assets`

## Описание
Создать composite action `ci/actions/collect-release-assets/`, который собирает артефакты релиза: скачивает ZIP-артефакты по паттерну, Docker image tar, генерирует SHA256SUMS.txt и создаёт release notes из CHANGELOG.md.

## Контекст
В production workflow (MimironsGoldOMatic Release) есть inline bash-скрипт `.github/scripts/collect-release-assets.sh`, который:
1. Скачивает артефакты с pattern `*-release`
2. Скачивает Docker image tar
3. Собирает всё в `upload/` директорию
4. Генерирует SHA256SUMS.txt
5. Создаёт release body из CHANGELOG.md

Этот скрипт дублирует логику существующих composite actions (`download-artifact`, `checksums`, `changelog-release`). Нужно объединить в один composite action.

## Критерии готовности
- [ ] Создана директория `ci/actions/collect-release-assets/` с `action.yml`
- [ ] Action принимает inputs: `artifacts_pattern`, `artifacts_merge`, `docker_image_name`, `docker_image_artifact_name`, `changelog_tag`, `changelog_changelog_path`
- [ ] Action скачивает ZIP артефакты через `actions/download-artifact@v4` с pattern + merge-multiple
- [ ] Action скачивает Docker image tar (если указан `docker_image_artifact_name`)
- [ ] Action генерирует SHA256SUMS.txt через существующий `checksums` action (или inline)
- [ ] Action создаёт release body из CHANGELOG.md через `changelog-release` action (или inline)
- [ ] Action собирает всё в `upload/` директорию
- [ ] Action создаёт output: `release_body_path`, `checksums_path`, `upload_dir`
- [ ] README.md с примером использования в workflow

## Чек-лист выполнения
- [ ] Изучить существующие composite actions (checksums, changelog-release)
- [ ] Посмотреть collect-release-assets.sh для понимания логики
- [ ] Создать action.yml с inputs/outputs
- [ ] Реализовать скачивание артефактов с pattern
- [ ] Реализовать генерацию checksums
- [ ] Реализовать создание release body
- [ ] Собрать всё в upload/
- [ ] Написать README.md
- [ ] Протестировать локально (если возможно)

## Зависимости
- Зависит от: нет (но использует логику checksums и changelog-release)

## Результат
(заполняется после выполнения)
