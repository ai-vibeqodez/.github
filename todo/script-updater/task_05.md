# Task 05: Добавить цель make update в Makefile проектов

## Описание
Добавить цель `make update` в Makefile каждого из 4 проектов для удобного запуска апдейтора.

## Контекст
Пользователь должен иметь возможность обновить скрипты через `make update` в корневом каталоге каждого проекта.

## Критерии готовности
- [x] `make update` добавлен в Makefile `~/tpl/Makefile`
- [x] `make update` добавлен в Makefile `~/.github/Makefile`
- [x] `make update` добавлен в Makefile `~/tobus/Makefile`
- [x] `make update` добавлен в Makefile `~/template-cpp/Makefile`
- [x] `make update` вызывает `bash scripts/updater.sh` (или `.ps1` на Windows)
- [x] `make update` работает во всех 4 проектах

## Чек-лист выполнения
- [x] Найти Makefile в каждом проекте
- [x] Добавить цель `update`: `bash scripts/updater.sh` / `powershell ... updater.ps1`
- [x] Протестировать `make update` в `.github`
- [x] Протестировать `make update` в `tpl`
- [x] Протестировать `make update` в `tobus`
- [x] Протестировать `make update` в `template-cpp`
- [x] Добавить `update` в `.PHONY` всех Makefile
- [x] Исправить баг в `.github/Makefile` и `tobus/Makefile` с `changelog-dry-run` (табы перед ifeq)

## Зависимости
- Зависит от: task_01 (updater.sh)

## Результат
Что было сделано (заполняется после выполнения)
