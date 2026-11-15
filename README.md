# 🏗️ ai-warevo — Infrastructure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<br />
[![CI](https://github.com/ai-warevo/.github/actions/workflows/example-ci.yml/badge.svg)](https://github.com/ai-warevo/.github/actions/workflows/example-ci.yml)
<br />
[![Coverage](https://raw.githubusercontent.com/ai-warevo/.github/refs/heads/badges/coverage.svg)](https://ai-warevo.github.io/.github/)

> Скиллы, шаблоны, документация, CI/CD и настройки редакторов для всех проектов.

Общий репозиторий инфраструктуры **ai-warevo**. Содержит переиспользуемые артефакты, которые применяются в любых проектах — независимо от стека (C#, Python, JS, C++ и др.).

## Что внутри

### 🐳 LLM Server
llama.cpp сервер для запуска LLM-моделей через Docker с GPU-ускорением:

| Файл | Назначение |
|------|-----------|
| [docker-compose.yml](docker-compose.yml) | Docker Compose для llama.cpp сервера (RTX 4080, CUDA, профиль `llamacpp`) |
| [README.llama-cpp.md](README.llama-cpp.md) | Документация по запуску и настройке |

- **API**: `http://host.docker.internal:8080/v1` (порт 8080, может конфликтовать)
- **Основная модель**: Qwen3.6-35B-A3B-UD-Q4_K_XL (~21 GB, MoE ~3B active params)
- **Fallback**: Qwen3-Coder-30B-A3B (~16.5 GB)

### 🧠 Скиллы
Полный каталог — [skills/README.md](skills/README.md)

### 📄 Шаблоны
Готовые шаблоны для проектов: [templates/](templates/)

### ⚙️ Конфигурации
| Файл | Назначение |
|------|-----------|
| [.editorconfig](.editorconfig) | Единый стиль кода: utf-8, LF, отступы |

### 📋 CI/CD
GitHub Actions шаблоны для CI/CD: [ci/README.md](ci/README.md)

## Как использовать

### Для AI-агента
1. Загрузить нужный скилл из `skills/`
2. Следовать сценарию работы
3. Генерировать выходные файлы по шаблонам из `templates/`

### Для человека
Скопировать шаблоны в свой проект и адаптировать под контекст.

## Релиз

Релиз режется автоматически из `CHANGELOG.md` по правилам [Keep a Changelog] + [SemVer].

1. Добавить изменения в `## [Unreleased]` в нужные категории: `Breaking`, `Added`, `Changed`, `Fixed` и т.д.
2. Проверить, что будет: `make release-dry-run`
3. Срезать релиз: `make release`
4. Запушить: `make release PUSH=1`

Категории определяют тип версии:
- `Breaking`, `Removed` → major
- `Added`, `Deprecated` → minor
- `Fixed`, `Changed`, `Security` → patch

[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/
[SemVer]: https://semver.org/spec/v2.0.0.html

## Структура

| Папка | Что внутри |
|-------|-----------|
| `ci/` | GitHub Actions: reusable workflows и composite-экшены |
| `scripts/` | Скрипты для автоматизации релизов |
| `skills/` | AI-скиллы для аналитики, планирования и выполнения задач |
| `templates/` | Шаблоны документов: OVERVIEW, задачи, README, CHANGELOG, CONTRIBUTING |
| `.editorconfig` | Единый стиль кода (utf-8, LF, отступы) |
| `docker-compose.yml` | llama.cpp сервер для локального запуска LLM |

## Лицензия
MIT
