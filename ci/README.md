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
│   ├── clang-format/       — проверка форматирования C++ (clang-format-18)
│   ├── clang-tidy/         — статический анализ C++ (clang-tidy-18)
│   ├── cmake-build/        — CMake configure → build → install
│   ├── collect-release-assets/ — скачивание артефактов билда
│   ├── coverage-html-deploy/ — деплой HTML coverage на gh-pages
│   ├── coverage-parser/    — парсер coverage (XML/LCOV)
│   ├── ctest-run/          — запуск CTest для CMake проектов
│   ├── docker-build-push/  — сборка и push Docker image
│   ├── docker-push-ghcr/   — push Docker image в GHCR
│   ├── docker-save/        — сохранение Docker image в tarball
│   ├── download-artifacts/ — скачивание артефактов из других job
│   ├── gcovr-report/       — генерация coverage XML + HTML (gcovr)
│   ├── release-version/    — определение версии из CHANGELOG или workflow_dispatch
│   └── setup-toolchain/    — установка toolchain + CMake args (clang-18, gcc-15, MSVC)
├── .github/
│   └── workflows/
│       ├── ci.yml                  — универсальный CI (заглушки для всех стеков)
│       ├── ci-cpp-container.yml    — C++20 контейнерный CI (gcc-15, clang-18)
│       ├── release.yml             — автоматический релиз из CHANGELOG
│       ├── test.yml                — универсальное тестирование (заглушки)
│       └── test-cpp-container.yml  — C++20 контейнерный test + coverage + badge
```

## Container-first CI

Все C++ workflow'ы работают в Docker-образе **`ghcr.io/ai-warevo/ci-cpp20`**:

```
runs-on: ubuntu-latest
container:
  image: ghcr.io/ai-warevo/ci-cpp20
  options: --user root
```

Образ содержит:
- **gcc-15** (libstdc++) — по умолчанию (`g++` symlink)
- **clang-18** (libc++ + libstdc++)
- **cmake**, **ninja-build**
- **clang-tidy-18**, **clang-format-18**
- **gcovr** (forky/unstable)
- **gdb**, **lld-18**, ASan/TSan runtimes

В контейнере `setup-toolchain` — **no-op installer**, только вычисляет CMake args:
```yaml
- id: tc
  uses: ai-warevo/<repo>/ci/actions/setup-toolchain@main
  with:
    toolchain: clang18-libcxx
    container_mode: true
- uses: ai-warevo/<repo>/ci/actions/cmake-build@main
  with:
    extra_args: "${{ steps.tc.outputs.cmake_args }}"
```

## Как использовать

### Быстрый старт (копирование workflow)

1. Скопируй workflow в свой проект:
   ```bash
   cp ci/.github/workflows/ci-cpp-container.yml .github/workflows/ci.yml
   cp ci/.github/workflows/test-cpp-container.yml .github/workflows/test.yml
   ```

2. Для badge/deploy — на ветке `badges` нужен доступ через `GITHUB_TOKEN`.

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
gh workflow run test.yml --ref main -f version=1.0.0
```

## ci-cpp-container.yml — C++20 Container CI

Последовательный pipeline: **build → lint → test**.

- Запускается по `pull_request` к `main`/`master` и `merge_group`
- Отменяет старые запуски для одного и того же PR/ветки
- **Build**: матрица по toolchain (clang18-libcxx, gcc15)
- **Lint**: clang-format + clang-tidy (требует `compile_commands.json`)
- **Test**: ctest в Debug конфигурации

### Composite Actions

| Action | Назначение |
|--------|-----------|
| `setup-toolchain` | Вычисляет CMake args для toolchain (в контейнере — no-op) |
| `cmake-build` | CMake configure → build → install |
| `ctest-run` | Запуск ctest |
| `clang-format` | Проверка форматирования (--dry-run --Werror) |
| `clang-tidy` | Статический анализ (требует compile_commands.json) |

## test-cpp-container.yml — C++20 Container Test + Coverage

Запускается:
- **Вручную** (`workflow_dispatch`) — по кнопке в GitHub UI
- **По push** в `main`/`master`
- **По расписанию** — каждый понедельник в 06:00 UTC

- Матрица: 4 конфигурации (clang18-libcxx, gcc15, clang18-libstdcxx+TSan, gcc15+UBSan)
- **Coverage**: gcovr XML + HTML (только gcc-15)
- **Badge**: SVG-бейдж с процентом покрытия → деплой на ветку `badges`
- **HTML Report**: деплой на `gh-pages`

### Coverage Badge

После запуска на `main`/`master`:
1. Парсит `coverage.xml` от gcovr
2. Определяет цвет: 🔴 <50%, 🟡 50–80%, 🟢 ≥80%
3. Генерирует SVG-бейдж через `ai-warevo/<repo>/ci/actions/badge@main`
4. Деплоит бейдж на ветку `badges`
5. Деплоит HTML-отчёт на `gh-pages` (если `htmlcov/index.html` существует)

Для использования в `README.md`:
```markdown
![Coverage](https://raw.githubusercontent.com/your-org/your-repo/badges/coverage.svg)
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

## ci.yml — Universal Template (заглушки)

Универсальный шаблон с placeholder'ами для разных стеков.
Раскомментируй нужный стек и замени заглушки.

## Поддерживаемые стеки

| Стек     | ci.yml | test.yml | ci-cpp-container | test-cpp-container |
|----------|--------|----------|------------------|-------------------|
| C++      | ✅     | ✅       | ✅ (container)   | ✅ (container)    |
| Node.js  | ✅     | ✅       |                  |                   |
| Python   | ✅     | ✅       |                  |                   |
| C# (.NET)| ✅     | ✅       |                  |                   |
| Go       | ✅     | ✅       |                  |                   |
| Rust     | ✅     | ✅       |                  |                   |
| Java     | ✅     | ❌       |                  |                   |
