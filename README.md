# 🏗️ ai-warevo — Infrastructure

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
AI-скиллы для автоматизации разработки:

| Скилл | Назначение |
|-------|-----------|
| [analyst](skills/analyst/SKILL.md) | Сбор и формализация требований через интервью |
| [planner](skills/planner/SKILL.md) | Декомпозиция требований → OVERVIEW + task-файлы |
| [executor](skills/executor/SKILL.md) | Выполнение задач из todo-директорий |
| [skill-creator](skills/skill-creator/SKILL.md) | Создание новых скиллов с валидацией |
| [git-github-push](skills/git-github-push/SKILL.md) | Push коммитов в GitHub через SSH (обход read-only ФС контейнера) |

Полный каталог — [SKILLS.md](SKILLS.md)

### 📄 Шаблоны
Готовые шаблоны для проектов:

| Файл | Назначение |
|------|-----------|
| [overview.md](templates/overview.md) | OVERVIEW проекта с чекбоксами и прогрессом |
| [task_template.md](templates/task_template.md) | Файл отдельной задачи с критериями готовности |
| [readme_template.md](templates/readme_template.md) | README.md проекта |
| [changelog_template.md](templates/changelog_template.md) | CHANGELOG.md (Keep a Changelog + SemVer) |
| [contributing_template.md](templates/contributing_template.md) | CONTRIBUTING.md — правила вклада |

### ⚙️ Конфигурации
| Файл | Назначение |
|------|-----------|
| [.editorconfig](.editorconfig) | Единый стиль кода: utf-8, LF, отступы |

### 📋 CI/CD
Универсальные GitHub Actions шаблоны для копирования в проекты:

| Файл | Назначение |
|------|-----------|
| [ci/.github/workflows/ci.yml](ci/.github/workflows/ci.yml) | CI pipeline: build → lint → test |
| [ci/.github/workflows/test.yml](ci/.github/workflows/test.yml) | Расширенное тестирование: мультиплатформа, coverage |
| [ci/actions/badge/README.md](ci/actions/badge/README.md) | Генератор кастомных SVG-бейджей |
| [ci/README.md](ci/README.md) | Инструкция по использованию |

Поддерживаемые стеки: Node.js, Python, C#, C++, Go, Rust, Java

### 📚 Документация
- [SKILLS.md](SKILLS.md) — каталог всех скиллов с входом/выходом, сложностью и зависимостями

## Как использовать

### Для AI-агента
1. Загрузить нужный скилл из `skills/`
2. Следовать сценарию работы
3. Генерировать выходные файлы по шаблонам из `templates/`

### Для человека
Скопировать шаблоны в свой проект и адаптировать под контекст.

## Структура
```
.github/
├── .editorconfig
├── .gitignore
├── docker-compose.yml
├── README.llama-cpp.md
├── ci/
│   ├── README.md
│   ├── actions/
│   │   └── badge/
│   │       ├── action.yml
│   │       └── README.md
│   └── .github/workflows/
│       ├── ci.yml
│       └── test.yml
├── skills/
│   ├── analyst/SKILL.md
│   ├── executor/SKILL.md
│   ├── planner/SKILL.md
│   ├── skill-creator/SKILL.md
│   └── git-github-push/SKILL.md
├── templates/
│   ├── overview.md
│   ├── task_template.md
│   ├── readme_template.md
│   ├── changelog_template.md
│   └── contributing_template.md
├── SKILLS.md
└── README.md
```

## Лицензия
MIT
