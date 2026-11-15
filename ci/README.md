# CI/CD Templates

Универсальные шаблоны GitHub Actions workflow'ов для копирования в проекты.

## Структура

```
ci/
├── README.md
└── .github/
    └── workflows/
        ├── ci.yml   — основной CI pipeline (build → lint → test)
        └── test.yml — расширенное тестирование (мультиплатформа, coverage)
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

## test.yml — Расширенное тестирование

Запускается:
- **Вручную** (`workflow_dispatch`) — по кнопке в GitHub UI
- **По расписанию** — каждый понедельник в 06:00 UTC

- Мультиплатформенный тестинг: Linux, Windows, macOS
- Матрица по версиям (Node.js, Python — раскомментируй и настрой)
- Coverage report (заглушка — замени на codecov/coveralls)

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
