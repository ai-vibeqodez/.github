# Changelog Release Action

Composite GitHub Action для извлечения release notes из `CHANGELOG.md` и генерации release body для GitHub Release.

## Входные параметры (`inputs`)

| Параметр | Описание | Обязательный | По умолчанию |
| :--- | :--- | :---: | :--- |
| `tag` | Релизный тег (например, `v1.2.3`) | Нет | `${{ github.ref_name }}` |
| `changelog` | Путь к `CHANGELOG.md` | Нет | `CHANGELOG.md` |
| `release-body` | Имя файла для release body | Нет | `release_body.md` |
| `what-included` | Раздел "What's Included" | Нет | — |
| `quick-start` | Раздел "Quick Start" | Нет | — |

## Выходные параметры (`outputs`)

| Параметр | Описание | Пример |
| :--- | :--- | :--- |
| `body_path` | Путь к файлу release body | `release_body.md` |
| `version` | Версия без префикса `v` | `1.2.3` |
| `notes` | Извлечённые release notes | (multiline) |

## Пример использования

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Generate Release Body
        id: changelog
        uses: ai-warevo/.github/ci/actions/changelog-release@main
        with:
          tag: ${{ github.ref_name }}
          changelog: 'CHANGELOG.md'
          release-body: 'release_body.md'

      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          body_path: ${{ steps.changelog.outputs.body_path }}
```

## Формат CHANGELOG.md

Action парсит [Keep a Changelog](https://keepachangelog.com/) формат:

```markdown
## [1.2.3] - 2024-01-15
### Added
- New feature X
### Fixed
- Bug Y

[1.2.3]: https://github.com/...
```

Notes извлекаются между `## [version]` и следующим `## [` или блоком ссылок.
