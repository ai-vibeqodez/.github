# Plugin tests (Catch2 v3 via FetchContent)
add_executable(plugin_tests plugin_tests.cpp)

target_include_directories(plugin_tests
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/../include
)

target_compile_features(plugin_tests PRIVATE cxx_std_23)

# Catch2 подключается через FetchContent в корневом CMakeLists.txt
target_link_libraries(plugin_tests
    PRIVATE
        Catch2::Catch2WithMain
        plugin
)

# Копируем библиотеку рядом с тестами
add_custom_command(TARGET plugin_tests POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:plugin>
        $<TARGET_FILE_DIR:plugin_tests>
    COMMENT "Copying plugin library next to test executable"
)

add_test(NAME plugin_tests COMMAND plugin_tests)
