# 🏗️ ai-warevo — Infrastructure

> Скиллы, шаблоны, документация, CI/CD и настройки редакторов для всех проектов.

Общий репозиторий инфраструктуры **ai-warevo**. Содержит переиспользуемые артефакты, которые применяются в любых проектах — независимо от стека (C#, Python, JS, C++ и др.).

## Что внутри

### 🧠 Скиллы
AI-скиллы для автоматизации разработки:

| Файл | Назначение |
|------|-----------|
| [01_analyst.md](skills/01_analyst.md) | Сбор и формализация требований через интервью |
| [02_planner.md](skills/02_planner.md) | Декомпозиция требований → OVERVIEW + task-файлы |
| [03_skill_creator.md](skills/03_skill_creator.md) | Создание новых скиллов с валидацией |

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
├── skills/
│   ├── 01_analyst.md
│   ├── 02_planner.md
│   └── 03_skill_creator.md
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
