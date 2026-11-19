# SVG Badge Generator Action

Кастомный экшен для быстрой генерации независимых SVG-бейджей (баджиков) без использования сторонних API и тяжелых зависимостей.

## Входные параметры (`inputs`)

Вы можете настраивать внешний вид бейджа через блок `with`:


| Параметр | Описание | Обязательный | По умолчанию |
| :--- | :--- | :---: | :--- |
| `width` | Общая ширина SVG в пикселях | Нет | `120` |
| `height` | Высота SVG в пикселях | Нет | `20` |
| `text_left` | Текст на левой (серой) половине | Нет | `coverage` |
| `text_right` | Текст на правой (цветной) половине | Нет | `80%` |
| `bg_color_left` | Цвет фона левой части (HEX/название) | Нет | `#555` |
| `bg_color_right`| Цвет фона правой части (HEX/название)| Нет | `#44cc11` |
| `text_color` | Цвет шрифта | Нет | `#fff` |
| `filename` | Путь и имя для сохранения файла | Нет | `badge.svg` |

## Выходные параметры (`outputs`)


| Параметр | Описание | Пример значения |
| :--- | :--- | :--- |
| `badge_path` | Путь к созданному SVG файлу | `assets/coverage.svg` |

## Полный пример использования в проекте

Пример workflow, который генерирует бейдж и сразу сохраняет его в репозиторий вашего проекта:

```yaml
name: Update Project Status Badge

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  badge:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Generate Custom Badge
        id: generate_step
        uses: ai-warevo/<repo>/ci/actions/badge@main
        with:
          width: '150'
          text_left: 'production'
          text_right: 'up'
          bg_color_right: '#007fff'
          filename: 'status-badge.svg'

      - name: Commit and Push Badge
        run: |
          git config --global user.name "github-actions[bot]"
          git config --global user.email "github-actions[bot]@users.noreply.github.com"
          git add status-badge.svg
          if git diff --staged --quiet; then
            echo "Бейдж не изменился."
          else
            git commit -m "chore: update generated badge [skip ci]"
            git push
          fi
```

После выполнения воркфлоу вы сможете вставить бейдж в свой `README.md` вот так:
```markdown
![Status Badge](status-badge.svg)
```
