# Task 03: Composite action `docker-push-ghcr`

## Описание
Создать composite action `ci/actions/docker-push-ghcr/`, который выполняет login в GHCR, теггирует Docker image и пушит его с тегами `:vX.Y.Z` и `:latest`.

## Контекст
В production workflow Docker пушится так:
```yaml
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- run: |
    docker tag <image>:<tag> "${REPO}:${{ env.RELEASE_VERSION }}"
    docker push "${REPO}:${{ env.RELEASE_VERSION }}"
    docker tag <image>:<tag> "${REPO}:latest"
    docker push "${REPO}:latest"
```

Нужно объединить login + tag + push в один composite action.

## Критерии готовности
- [ ] Создана директория `ci/actions/docker-push-ghcr/` с `action.yml`
- [ ] Action принимает inputs: `registry`, `repository`, `image_name`, `image_tag`, `push_latest`
- [ ] Action выполняет `docker/login-action@v3` с GHCR credentials
- [ ] Action теггирует image как `${repository}:${image_tag}` и пушит
- [ ] Action теггирует image как `${repository}:latest` и пушит (если `push_latest=true`)
- [ ] Action использует `${{ secrets.GITHUB_TOKEN }}` для login
- [ ] README.md с примером использования

## Чек-лист выполнения
- [ ] Создать структуру action
- [ ] Реализовать login action (docker/login-action@v3)
- [ ] Реализовать tag + push для версии
- [ ] Реализовать tag + push для latest (опционально)
- [ ] Написать README.md с примером workflow
- [ ] Добавить input `push_latest` с дефолтом `true`

## Зависимости
- Нет

## Результат
(заполняется после выполнения)
