# Host executable
add_executable(host src/host.cpp)

target_include_directories(host
    PRIVATE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../include>
)

target_compile_features(host PRIVATE cxx_std_23)

# Linux: динамическая загрузка через dlopen требует -ldl
if(UNIX AND NOT APPLE)
    find_library(NEEDED_LIBRARIES dl)
    if(NEEDED_LIBRARIES)
        target_link_libraries(host PRIVATE ${NEEDED_LIBRARIES})
    endif()
endif()

# Копируем библиотеку рядом с executable для удобства
add_custom_command(TARGET host POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:plugin>
        $<TARGET_FILE_DIR:host>
    COMMENT "Copying plugin library next to host executable"
)
