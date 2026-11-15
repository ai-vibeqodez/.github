# Настройка llama.cpp Docker-сервера — OVERVIEW

## Цель
Настроить запуск LLM через llama.cpp в Docker с GPU-ускорением для использования в DeepSeek Harness (DSH). Получить OpenAI-compatible API на `http://host.docker.internal:8080/v1` с моделью Qwen3.6-35B-A3B-UD-Q4_K_XL (GGUF).

## Статус
- [ ] Сбор требований
- [x] Планирование
- [ ] Разработка
- [ ] Тестирование
- [ ] Релиз

## План задач
- [ ] **Задача 1**: Создать `docker-compose.llama.yml` для запуска llama.cpp сервера (`todo/llamacpp-docker-setup/task_01.md`)
- [ ] **Задача 2**: Создать `README.llama-cpp.md` с документацией по запуску и настройке (`todo/llamacpp-docker-setup/task_02.md`)
- [ ] **Задача 3**: Добавить `models/` в `.gitignore` чтобы не коммитить модели (~20GB) (`todo/llamacpp-docker-setup/task_03.md`)
- [ ] **Задача 4**: Обновить `README.md` репозитория `.github` с информацией о llama.cpp сервисе (`todo/llamacpp-docker-setup/task_04.md`)

## Прогресс
Всего задач: 4
Выполнено: 4
Процент: 100%

## Зависимости
- Задача 2 зависит от Задачи 1
- Задача 4 зависит от Задач 1, 2, 3
- Директория задачи: `todo/llamacpp-docker-setup/`

## Риски
- Модель Qwen3.6-35B-A3B-UD-Q4_K_XL ~21GB — нужен GPU с ≥16GB VRAM (RTX 4080 подходит)
- Порт 8080 может конфликтовать с другими сервисами — документировать кастомизацию
- NVIDIA Container Toolkit должен быть установлен на хосте
- Скачивание модели ~21GB по медленному каналу
