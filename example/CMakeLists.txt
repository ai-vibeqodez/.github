# ── Example C++23 Plugin Project ──────────────────────────────────────────
cmake_minimum_required(VERSION 3.20)
project(example LANGUAGES CXX)

# ── Catch2 v3: local third_party first, FetchContent fallback ─────────────
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/third_party/catch2/CMakeLists.txt")
    add_subdirectory(third_party/catch2)
else()
    include(FetchContent)
    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG        v3.7.1
        GIT_SHALLOW    ON
    )
    FetchContent_MakeAvailable(Catch2)
endif()

# ── Subprojects ───────────────────────────────────────────────────────────
add_subdirectory(plugin)
add_subdirectory(host)

# ── Tests ─────────────────────────────────────────────────────────────────
enable_testing()
add_subdirectory(plugin/tests)
