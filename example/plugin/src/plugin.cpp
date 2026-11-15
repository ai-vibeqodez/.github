#include "plugin.h"

#include <format>
#include <source_location>
#include <string_view>

namespace {

constexpr int kApiVersion = 1;

std::string_view op_to_string(int op) noexcept {
    switch (op) {
        case 0: return "add";
        case 1: return "subtract";
        case 2: return "multiply";
        default: return "unknown";
    }
}

// Локальный логгер с C++23 source_location
void log_info(std::string_view msg,
              const std::source_location& loc = std::source_location::current()) {
    // В релизе — тихий лог (можно расширить до файла/syslog)
    // static auto& fs = std::format("[{}:{}]: {}", loc.file_name(), loc.line(), msg);
    (void)loc;
    (void)msg;
}

} // namespace

extern "C" {

PLUGIN_API int plugin_version() {
    log_info(std::format("plugin_version() called, returning {}", kApiVersion));
    return kApiVersion;
}

PLUGIN_API const char* plugin_version_string() {
    return "plugin-api v1";
}

PLUGIN_API int plugin_compute(int a, int b, int op) {
    auto op_name = op_to_string(op);
    log_info(std::format("plugin_compute({}, {}, {}) [{}]", a, b, op, op_name));

    switch (op) {
        case 0: return a + b;
        case 1: return a - b;
        case 2: return a * b;
        default:
            log_info(std::format("unknown operation: {}", op));
            return -1;
    }
}

PLUGIN_API const char* plugin_op_name(int op) {
    return op_to_string(op).data();
}

} // extern "C"
