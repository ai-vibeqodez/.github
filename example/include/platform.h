#ifndef AW_GITHUB_PLATFORM_H
#define AW_GITHUB_PLATFORM_H

#include <optional>
#include <string>
#include <string_view>

/**
 * @namespace aw::example::platform
 * @brief Cross-platform abstraction for dynamic library operations.
 *
 * Encapsulates all platform-specific details:
 * - library loading / unloading (LoadLibrary / dlopen)
 * - symbol resolution (GetProcAddress / dlsym)
 * - library path lookup (GetModuleFileName + backslash / readlink + slash)
 */
namespace aw::example::platform {

/**
 * @brief Handle for a loaded dynamic library.
 *
 * Unified void* — HMODULE on Windows is cast to void*.
 */
struct LibraryHandle {
    void* handle = nullptr;
};

/**
 * @brief Loads a library by path.
 *
 * @param path Library path (empty string = system search).
 * @return Handle on success, std::nullopt on error.
 */
std::optional<LibraryHandle> load_library(const std::string& path);

/**
 * @brief Unloads the loaded library.
 *
 * @param lib Library handle (modified, becomes null).
 */
void unload_library(LibraryHandle& lib);

/**
 * @brief Resolves a symbol from the loaded library.
 *
 * @param lib Library handle.
 * @param name Symbol name.
 * @return Pointer to symbol on success, nullptr on error.
 */
void* resolve_symbol(LibraryHandle& lib, std::string_view name);

/**
 * @brief Searches for the plugin library.
 *
 * Order: ENV PLUGIN_PATH → next to executable → system path.
 *
 * @return Library path or std::nullopt if not found.
 *         Empty string = system search (delegate to loader).
 */
std::optional<std::string> find_plugin();

} // namespace aw::example::platform

#endif  // AW_GITHUB_PLATFORM_H
