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
└── README.md
```

## Лицензия
MIT
