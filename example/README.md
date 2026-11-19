# Example C++23 Plugin Project

A template project demonstrating dynamic library loading in C++23.

## Architecture

The project is divided into three components with clear separation of responsibilities:

- **`aw::example::plugin`** — shared library (`libplugin.so` / `plugin.dll`) with public API
- **`aw::example::host`** — host application with dynamic loader
- **`aw::example::tests`** — unit tests (Catch2 v3)

## Structure

```
example/
├── CMakeLists.txt          # Root CMake (Catch2 FetchContent + subdirectories)
├── include/
│   └── plugin.h            # Public API (aw::example::plugin)
├── plugin/
│   ├── CMakeLists.txt      # Shared library (.dll/.so)
│   ├── src/
│   │   └── plugin.cpp      # Implementation (C++23: std::format, source_location)
│   └── tests/
│       ├── CMakeLists.txt  # Tests
│       └── plugin_tests.cpp  # Catch2 v3 tests
└── host/
    ├── CMakeLists.txt      # Executable
    └── src/
        └── host.cpp        # Dynamic loading (dlopen/LoadLibrary)
```

## Build

```bash
cmake -S example -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```

## Running

```bash
./build/host
```

The host will automatically find `libplugin.so` / `plugin.dll` next to the executable.

## Tests

```bash
cd build
ctest --output-on-failure -C Release
```

## CI

GitHub Actions: `.github/workflows/example-ci.yml` — matrix build (Ubuntu + Windows).
