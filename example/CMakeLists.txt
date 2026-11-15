# ── Example C++23 Plugin Project ──────────────────────────────────────────
cmake_minimum_required(VERSION 3.20)
project(example LANGUAGES CXX)

# ── Catch2 v3 через FetchContent ──────────────────────────────────────────
include(FetchContent)

FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v3.7.1
    GIT_SHALLOW    ON
)

FetchContent_MakeAvailable(Catch2)

# ── Subprojects ───────────────────────────────────────────────────────────
add_subdirectory(plugin)
add_subdirectory(host)

# ── Tests ─────────────────────────────────────────────────────────────────
enable_testing()
add_subdirectory(plugin/tests)
