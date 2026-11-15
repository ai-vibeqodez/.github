# Release Version Resolver

Composite GitHub Action для резолва версии релиза.

## Входные параметры (`inputs`)

| Параметр | Описание | Обязательный | По умолчанию |
| :--- | :--- | :---: | :--- |
| `version` | Ручная версия (например, `1.2.3`) | Нет | `''` |

## Выходные параметры (`outputs`)

| Параметр | Описание | Пример |
| :--- | :--- | :--- |
| `release_version` | Версия с `v` | `v1.2.3` |
| `release_version_stripped` | Версия без `v` | `1.2.3` |

## Логика резолва

1. **Тег** (`push: tags: v*`) → `github.ref_name`
2. **Workflow dispatch** с `version` инпутом → input без `v`
3. **Fallback** → `v0.0.<run_number>`

## Пример использования

```yaml
steps:
  - name: Resolve version
    id: version
    uses: ai-warevo/.github/ci/actions/release-version@main
    with:
      version: ${{ github.event.inputs.version }}
```
