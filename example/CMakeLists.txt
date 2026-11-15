# ── Example C++23 Plugin Project ──────────────────────────────────────────
cmake_minimum_required(VERSION 3.20)
project(example LANGUAGES CXX)

if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(AW_EXAMPLE_IS_TOP_LEVEL ON)
else()
    set(AW_EXAMPLE_IS_TOP_LEVEL OFF)
endif()

# ── Subprojects ───────────────────────────────────────────────────────────
add_subdirectory(plugin)
add_subdirectory(host)

# ── Coverage ────────────────────────────────────────────────────────────────
option(AW_EXAMPLE_ENABLE_COVERAGE "Enable code coverage instrumentation" OFF)

# ── Sanitizers ──────────────────────────────────────────────────────────────
set(AW_EXAMPLE_SANITIZE "none" CACHE STRING "Sanitizer to enable: none, address (ASan+UBSan) or thread (TSan)")
set_property(CACHE AW_EXAMPLE_SANITIZE PROPERTY STRINGS none address thread)

# ── Tests (opt-in, off when consumed as a subproject) ──────────────────────
option(AW_EXAMPLE_BUILD_TESTS "Build example unit tests" ${AW_EXAMPLE_IS_TOP_LEVEL})

if(AW_EXAMPLE_BUILD_TESTS)
    enable_testing()

    # ── Catch2 v3: local third_party first, FetchContent fallback ─────────
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/third_party/catch2/CMakeLists.txt")
        add_subdirectory(third_party/catch2)
    else()
        include(FetchContent)
        FetchContent_Declare(
            Catch2
            GIT_REPOSITORY https://github.com/catchorg/Catch2.git
            GIT_TAG        v3.16.1
            GIT_SHALLOW    TRUE
        )
        FetchContent_MakeAvailable(Catch2)
    endif()

    add_subdirectory(plugin/tests)
endif()

# ── Apply coverage / sanitizer flags to all targets ─────────────────────────
if(AW_EXAMPLE_ENABLE_COVERAGE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    # --coverage adds -lgcov automatically
    add_compile_options(--coverage -O0 -g -fprofile-update=atomic)
    add_link_options(--coverage)
endif()

if(NOT AW_EXAMPLE_SANITIZE STREQUAL "none")
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(FATAL_ERROR "AW_EXAMPLE_SANITIZE requires GCC or Clang")
    endif()
    if(AW_EXAMPLE_ENABLE_COVERAGE)
        message(FATAL_ERROR "AW_EXAMPLE_SANITIZE cannot be combined with AW_EXAMPLE_ENABLE_COVERAGE")
    endif()
    if(AW_EXAMPLE_SANITIZE STREQUAL "address")
        set(AW_EXAMPLE_SANITIZE_FLAGS "address,undefined")
    elseif(AW_EXAMPLE_SANITIZE STREQUAL "thread")
        set(AW_EXAMPLE_SANITIZE_FLAGS "thread")
    else()
        message(FATAL_ERROR "AW_EXAMPLE_SANITIZE must be one of: none, address, thread")
    endif()
    add_compile_options(-fsanitize=${AW_EXAMPLE_SANITIZE_FLAGS} -fno-omit-frame-pointer -g)
    add_link_options(-fsanitize=${AW_EXAMPLE_SANITIZE_FLAGS})
endif()
