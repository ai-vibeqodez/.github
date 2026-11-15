# Example C++23 Plugin Project

Шаблонный проект, демонстрирующий динамическую загрузку библиотеки в C++23.

## Структура

```
example/
├── CMakeLists.txt          # Корневой CMake (Catch2 FetchContent + subdirectories)
├── include/
│   └── plugin.h            # Публичный API
├── plugin/
│   ├── CMakeLists.txt      # Shared library (.dll/.so)
│   ├── src/
│   │   └── plugin.cpp      # Реализация (C++23: std::format, source_location)
│   └── tests/
│       ├── CMakeLists.txt  # Тесты
│       └── plugin_tests.cpp  # Catch2 v3 тесты
└── host/
    ├── CMakeLists.txt      # Executable
    └── src/
        └── host.cpp        # Динамическая загрузка (dlopen/LoadLibrary)
```

## Сборка

```bash
cmake -S example -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

## Запуск

```bash
./build/host
```

Host автоматически найдёт `libplugin.so` / `plugin.dll` рядом с executable.

## Тесты

```bash
cd build
ctest --output-on-failure -C Release
```

## CI

GitHub Actions: `.github/workflows/example-ci.yml` — matrix build (Ubuntu + Windows).
