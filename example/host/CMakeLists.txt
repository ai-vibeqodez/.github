# Host executable
set(host_sources src/host.cpp)

if(WIN32)
    list(APPEND host_sources src/platform_windows.cpp)
else()
    list(APPEND host_sources src/platform_unix.cpp)
endif()

add_executable(host ${host_sources})

target_include_directories(host
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
)

target_compile_features(host PRIVATE cxx_std_23)

# Linux: dynamic loading via dlopen requires -ldl
if(UNIX AND NOT APPLE)
    find_library(NEEDED_LIBRARIES dl)
    if(NEEDED_LIBRARIES)
        target_link_libraries(host PRIVATE ${NEEDED_LIBRARIES})
    endif()
endif()

# Copy library next to executable for convenience
add_custom_command(TARGET host POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:plugin>
        $<TARGET_FILE_DIR:host>
    COMMENT "Copying plugin library next to host executable"
)
