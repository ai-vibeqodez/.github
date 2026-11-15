#pragma once

#include <optional>
#include <string>
#include <string_view>

/**
 * @namespace aw::example::platform
 * @brief Кроссплатформенная абстракция для работы с динамическими библиотеками.
 *
 * Инкапсулирует все platform-specific детали:
 * - загрузка / выгрузка библиотек (LoadLibrary / dlopen)
 * - резолвинг символов (GetProcAddress / dlsym)
 * - поиск пути к библиотеке (GetModuleFileName + backslash / readlink + slash)
 */
namespace aw::example::platform {

/**
 * @brief Дескриптор загруженной динамической библиотеки.
 *
 * Унифицированный void* — HMODULE на Windows приводится к void*.
 */
struct LibraryHandle {
    void* handle = nullptr;
};

/**
 * @brief Загружает библиотеку по пути.
 *
 * @param path Путь к библиотеке (пустая строка = системный поиск).
 * @return Дескриптор при успехе, std::nullopt при ошибке.
 */
std::optional<LibraryHandle> load_library(const std::string& path);

/**
 * @brief Выгружает загруженную библиотеку.
 *
 * @param lib Дескриптор библиотеки (модифицируется, становится null).
 */
void unload_library(LibraryHandle& lib);

/**
 * @brief Резолвит символ из загруженной библиотеки.
 *
 * @param lib Дескриптор библиотеки.
 * @param name Имя символа.
 * @return Указатель на символ при успехе, nullptr при ошибке.
 */
void* resolve_symbol(LibraryHandle& lib, std::string_view name);

/**
 * @brief Ищет библиотеку плагина.
 *
 * Порядок: ENV PLUGIN_PATH → рядом с executable → системный путь.
 *
 * @return Путь к библиотеке или std::nullopt если не найдена.
 *         Пустая строка = системный поиск (delegate to loader).
 */
std::optional<std::string> find_plugin();

} // namespace aw::example::platform
