# Task 02: Добавить SCRIPT_VERSION в changelog-update.sh и release.sh

## Описание
Добавить строку `# SCRIPT_VERSION=1.0.0` в начало каждого скрипта `changelog-update.sh` и `release.sh` в центральном репозитории и во всех downstream-проектах.

## Контекст
Каждый скрипт должен содержать метку версии для сравнения с удалённой версией. Версия обновляется автоматически апдейтором при синхронизации.

## Критерии готовности
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `.github/scripts/changelog-update.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `.github/scripts/release.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `tpl/scripts/changelog-update.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `tpl/scripts/release.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `tobus/scripts/changelog-update.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `tobus/scripts/release.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `template-cpp/scripts/changelog-update.sh`
- [x] `# SCRIPT_VERSION=1.0.0` добавлен в `template-cpp/scripts/release.sh`
- [x] Версия синхронизирована во всех проектах
- [x] Скрипты остались рабочими после добавления комментария

## Чек-лист выполнения
- [x] Определить место для вставки `SCRIPT_VERSION` (сразу после shebang, перед основным комментарием)
- [x] Добавить `# SCRIPT_VERSION=1.0.0` в `.github/scripts/changelog-update.sh`
- [x] Добавить `# SCRIPT_VERSION=1.0.0` в `.github/scripts/release.sh`
- [x] Скопировать обновлённые скрипты в `tpl/scripts/`
- [x] Скопировать обновлённые скрипты в `tobus/scripts/`
- [x] Скопировать обновлённые скрипты в `template-cpp/scripts/`
- [x] Проверить, что скрипты остались рабочими (`bash -n` syntax check)

## Зависимости
- Зависит от: task_01 (базовая структура скриптов)

## Результат
Что было сделано (заполняется после выполнения)
