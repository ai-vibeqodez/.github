# 🏗️ ai-warevo — Infrastructure

> Скиллы, шаблоны, документация, CI/CD и настройки редакторов для всех проектов.

Общий репозиторий инфраструктуры **ai-warevo**. Содержит переиспользуемые артефакты, которые применяются в любых проектах — независимо от стека (C#, Python, JS, C++ и др.).

## Что внутри

### 🧠 Скиллы
AI-скиллы для автоматизации разработки:

| Скилл | Назначение |
|-------|-----------|
| [analyst](skills/analyst/SKILL.md) | Сбор и формализация требований через интервью |
| [planner](skills/planner/SKILL.md) | Декомпозиция требований → OVERVIEW + task-файлы |
| [executor](skills/executor/SKILL.md) | Выполнение задач из todo-директорий |
| [skill-creator](skills/skill-creator/SKILL.md) | Создание новых скиллов с валидацией |

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

### 🐳 LLM Server
llama.cpp сервер для запуска LLM-моделей через Docker с GPU-ускорением:

| Файл | Назначение |
|------|-----------|
| [docker-compose.llama.yml](docker-compose.llama.yml) | Docker Compose для llama.cpp сервера (RTX 4080, CUDA) |
| [README.llama-cpp.md](README.llama-cpp.md) | Документация по запуску и настройке |

- **API**: `http://host.docker.internal:8080/v1` (порт 8080, может конфликтовать)
- **Основная модель**: Qwen3.6-35B-A3B-UD-Q4_K_XL (~21 GB, MoE ~3B active params)
- **Fallback**: Qwen3-Coder-30B-A3B (~16.5 GB)
- **Статус**: ✅ Готово

### ⚙️ Конфигурации
| Файл | Назначение |
|------|-----------|
| [.editorconfig](.editorconfig) | Единый стиль кода: utf-8, LF, отступы |

### 📋 CI/CD
Планируется: GitHub Actions workflow'и для build, test, deploy.

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
├── docker-compose.llama.yml
├── README.llama-cpp.md
├── skills/
│   ├── analyst/SKILL.md
│   ├── executor/SKILL.md
│   ├── planner/SKILL.md
│   └── skill-creator/SKILL.md
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
