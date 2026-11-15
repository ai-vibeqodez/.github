# CI/CD Templates

Универсальные шаблоны GitHub Actions workflow'ов для копирования в проекты.

## Структура

```
ci/
├── README.md
├── actions/
│   ├── badge/              — SVG Badge Generator (coverage бейдж)
│   │   ├── action.yml
│   │   └── README.md
│   ├── changelog-release/  — генерация body релиза из CHANGELOG.md
│   ├── checksums/          — генерация SHA256SUMS.txt из артефактов
│   ├── checksums-verify/   — верификация SHA256SUMS.txt
│   ├── collect-release-assets/ — скачивание артефактов билда
│   ├── coverage-parser/    — парсер coverage (XML/LCOV)
│   ├── docker-push-ghcr/   — push Docker image в GHCR
│   ├── docker-save/        — сохранение Docker image в tarball
│   ├── download-artifacts/ — скачивание артефактов из других job
│   └── release-version/    — определение версии из CHANGELOG или workflow_dispatch
├── .github/
│   └── workflows/
│       ├── ci.yml          — основной CI pipeline (build → lint → test)
│       ├── release.yml     — автоматический релиз из CHANGELOG (build → release → docker)
│       └── test.yml        — расширенное тестирование (мультиплатформа, coverage)
```

## Как использовать

### Быстрый старт (копирование workflow)

1. Скопируй workflow в свой проект:
   ```bash
   cp ci/.github/workflows/release.yml .github/workflows/release.yml
   ```

2. Добавь изменения в `CHANGELOG.md` под `## [Unreleased]`.

3. Создай релиз:
   ```bash
   make release-dry-run   # проверить, что будет
   make release           # создать тег и коммит
   ```

4. Запушь тег (SSH ключ нужен):
   ```bash
   GIT_SSH_COMMAND="ssh -i /tmp/ssh/id_ed25519 -o UserKnownHostsFile=/tmp/ssh/known_hosts -o StrictHostKeyChecking=no" \
     git push origin v0.7.0
   ```

### Ручной запуск (workflow_dispatch)

```bash
gh workflow run release.yml --ref main -f version=1.0.0
```

## release.yml — Build → Release → Docker

Автоматический pipeline из трёх job:

1. **build-example** — билд проекта (CMake) и загрузка артефактов
2. **release** — парсит CHANGELOG, генерирует checksums, создаёт GitHub Release с артефактами
3. **docker** — собирает и пушит Docker image в GHCR

### Composite Actions

| Action | Назначение |
|--------|-----------|
| `release-version` | Определяет версию из CHANGELOG.md или input |
| `changelog-release` | Генерирует body релиза из секции CHANGELOG |
| `checksums` | Генерирует SHA256SUMS.txt для артефактов |
| `checksums-verify` | Верифицирует checksums артефактов |
| `download-artifacts` | Скачивает артефакты из других job (pattern match) |
| `docker-push-ghcr` | Push Docker image в GitHub Container Registry |
| `docker-save` | Сохраняет Docker image в tarball |
| `collect-release-assets` | Скачивает артефакты билда |

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
