# CI/CD Templates

Универсальные шаблоны GitHub Actions workflow'ов для копирования в проекты.

## Структура

```
ci/
├── README.md
├── actions/
│   └── badge/          — SVG Badge Generator (кастомный экшен)
│       ├── action.yml
│       └── README.md
└── .github/
    └── workflows/
        ├── ci.yml      — основной CI pipeline (build → lint → test)
        └── test.yml    — расширенное тестирование (мультиплатформа, coverage, badge, release)
```

## Как использовать

1. Скопируй нужные файлы в свой проект:
   ```
   cp ci/.github/workflows/ci.yml .github/workflows/ci.yml
   cp ci/.github/workflows/test.yml .github/workflows/test.yml
   ```

2. Открой файл и раскомментируй секцию для своего стека.
3. Замени `echo "call real command to ..."` на реальные команды.
4. Настрой параметры матрицы (версии Node.js, Python и т.д.).

## ci.yml — Build, Lint, Test

Последовательный pipeline: **build → lint → test**.

- Запускается по push в `main`/`develop` и по PR
- Отменяет старые запуски для одного и того же PR/ветки
- Заглушки для стеков: Node.js, Python, C#, C++, Go, Rust, Java
- Node.js/Python: генерация coverage XML для badge

## test.yml — Расширенное тестирование

Запускается:
- **Вручную** (`workflow_dispatch`) — по кнопке в GitHub UI
- **По push** в `main`/`master`
- **По расписанию** — каждый понедельник в 06:00 UTC

- Мультиплатформенный тестинг: Linux, Windows, macOS
- Матрица по версиям (Node.js, Python — раскомментируй и настрой)
- Coverage report (заглушка — замени на codecov/coveralls)
- **Coverage Badge** — автоматическая генерация SVG-бейджа и деплой на ветку `badges`
- **Coverage HTML Report** — деплой отчёта на `gh-pages`
- **GitHub Release** — автоматическое создание релиза по тегу `vX.Y.Z`

### Coverage Badge

После запуска на `main`/`master` workflow:
1. Парсит `coverage.xml` или `coverage.lcov`
2. Определяет цвет: 🔴 <50%, 🟡 50–80%, 🟢 ≥80%
3. Генерирует SVG-бейдж через экшен `ai-warevo/.github/ci/actions/badge@main`
4. Деплоит бейдж на ветку `badges`
5. Деплоит HTML-отчёт на `gh-pages` (если `htmlcov/index.html` существует)

Для использования в `README.md`:
```markdown
![Coverage](https://raw.githubusercontent.com/your-org/your-repo/badges/coverage.svg)
```

### GitHub Release

При создании тега `vX.Y.Z` workflow:
1. Парсит CHANGELOG.md, извлекает секцию `## [X.Y.Z]`
2. Генерирует body с описанием изменений и quick-start инструкциями
3. Создаёт GitHub Release через `softprops/action-gh-release@v2`

Для создания релиза:
```bash
# 1. Заполни изменения в CHANGELOG.md под ## [Unreleased]
# 2. Запусти скрипт (Linux/macOS):
./scripts/release.sh --push
# или (Windows):
.\scripts\release.ps1 -Push
```

Скрипт автоматически:
- Определяет тип версии (major/minor/patch) по категориям в [Unreleased]
- Промоутит [Unreleased] → `## [X.Y.Z] - today`
- Обновляет VERSION
- Создаёт commit + annotated tag
- Пушит всё атомарно

Категории:
| Категория | Тип bump |
|-----------|----------|
| Breaking, Removed | major |
| Added, Deprecated | minor |
| Fixed, Changed, Security | patch |

## Поддерживаемые стеки

| Стек     | ci.yml | test.yml |
|----------|--------|----------|
| Node.js  | ✅     | ✅       |
| Python   | ✅     | ✅       |
| C# (.NET)| ✅     | ✅       |
| C++      | ✅     | ✅       |
| Go       | ✅     | ✅       |
| Rust     | ✅     | ✅       |
| Java     | ✅     | ❌       |
