# Task 02: Composite action `docker-save`

## Описание
Создать composite action `ci/actions/docker-save/`, который сохраняет Docker image как tar-артефакт для последующей передачи между jobs.

## Конcontext
В production workflow Docker image сохраняется так:
```yaml
- run: docker save <image> -o backend-image.tar
- uses: actions/upload-artifact@v4
  with:
    name: backend-docker-image
    path: backend-image.tar
    retention-days: 7
```

Это повторяется в разных workflow. Нужно вынести в reusable composite action.

## Критерии готовности
- [ ] Создана директория `ci/actions/docker-save/` с `action.yml`
- [ ] Action принимает inputs: `image_name`, `image_tag`, `artifact_name`, `artifact_path`, `retention_days`
- [ ] Action выполняет `docker save` и сохраняет как tar
- [ ] Action загружает tar как artifact через `actions/upload-artifact@v4`
- [ ] Action создаёт output: `artifact_name`, `artifact_path`
- [ ] README.md с примером использования

## Чек-лист выполнения
- [ ] Создать структуру action
- [ ] Реализовать docker save + upload artifact
- [ ] Написать README.md с примером workflow
- [ ] Проверить что artifact name и path корректны

## Зависимости
- Нет

## Результат
(заполняется после выполнения)
