# Coverage Parser Action

Composite GitHub Action для извлечения процента покрытия из `coverage.xml` или `coverage.lcov`.

## Входные параметры (`inputs`)

| Параметр | Описание | Обязательный | По умолчанию |
| :--- | :--- | :---: | :--- |
| `xml_path` | Путь к `coverage.xml` | Нет | `coverage.xml` |
| `lcov_path` | Путь к `coverage.lcov` | Нет | `coverage.lcov` |

## Выходные параметры (`outputs`)

| Параметр | Описание | Пример |
| :--- | :--- | :--- |
| `percent` | Процент покрытия | `87%` |
| `color` | Цвет бейджа (HEX) | `#44cc11` |

## Логика цветов

| Диапазон | Цвет |
| :--- | :--- |
| `< 50%` | `#e05d44` (красный) |
| `50–79%` | `#dfb317` (жёлтый) |
| `≥ 80%` | `#44cc11` (зелёный) |

## Пример использования

```yaml
- name: Parse Coverage
  id: coverage
  uses: ai-warevo/<repo>/ci/actions/coverage-parser@main

- name: Generate Badge
  uses: ai-warevo/<repo>/ci/actions/badge@main
  with:
    text_right: '${{ steps.coverage.outputs.percent }}'
    bg_color_right: '${{ steps.coverage.outputs.color }}'

- name: Create Release
  uses: softprops/action-gh-release@v2
  with:
    body: 'Coverage: ${{ steps.coverage.outputs.percent }}'
```
