# Task 01: Создать docker-compose.llama.yml

## Описание
Создать файл `docker-compose.llama.yml` для запуска llama.cpp сервера в Docker с GPU-ускорением.

## Контекст
DSH подключается к LLM через OpenAI-compatible API. llama.cpp предоставляет серверный режим с API, совместимым с OpenAI. Используем официальный образ `ghcr.io/ggml-org/llama.cpp:server-cuda` для CUDA-ускорения на RTX 4080.

## Критерии готовности
- [ ] Файл `docker-compose.llama.yml` создан в корне репозитория `.github/`
- [ ] Используется образ `ghcr.io/ggml-org/llama.cpp:server-cuda`
- [ ] Указаны GPU-ресурсы (NVIDIA, 1 GPU, все device capabilities)
- [ ] Порт 8080 маппингирован на хост
- [ ] Объём памяти для GPU: 16GB (16384m)
- [ ] Модель указывается через аргумент командной строки (`-model`, `-ngl 99`)
- [ ] Добавлен `extra_hosts: host.docker.internal:host-gateway` для доступа из DSH
- [ ] Порт 8080 задокументирован как потенциально конфликтующий

## Чек-лист выполнения
- [ ] Изучить пример из `ollama-fast-coder-4080/docker-compose.llama.yml`
- [ ] Создать файл с правильной структурой Docker Compose v3.8+
- [ ] Настроить GPU-ресурсы
- [ ] Настроить маппинг портов и volumes
- [ ] Добавить комментарии к конфигурации

## Зависимости
- Нет (первая задача в цепочке)

## Результат
Файл `docker-compose.llama.yml` готов к запуску llama.cpp сервера.
