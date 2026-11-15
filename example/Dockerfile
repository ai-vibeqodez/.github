# ── Example C++23 Plugin — Docker image ──────────────────────────────────
#
# Многоэтапная сборка:
#   stage1 (builder) — cmake + make, C++23 на Alpine
#   stage2 (runtime) — только бинарники host + libplugin
#
# Сборка:
#   docker build -t ghcr.io/ai-warevo/example -f example/Dockerfile .
#
# Запуск:
#   docker run --rm ghcr.io/ai-warevo/example

# ── Builder ───────────────────────────────────────────────────────────────
FROM gcc:13-alpine AS builder

RUN apk add --no-cache cmake make pkgconfig

WORKDIR /build

# Копируем CMakeLists.txt и исходники
COPY CMakeLists.txt .
COPY include/ include/
COPY plugin/ plugin/
COPY host/ host/

RUN mkdir -p build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DAW_EXAMPLE_BUILD_TESTS=OFF && \
    make -j"$(nproc)"

# ── Runtime ───────────────────────────────────────────────────────────────
FROM alpine:3.20

RUN apk add --no-cache libstdc++

WORKDIR /app

COPY --from=builder /build/build/host ./host
COPY --from=builder /build/build/libplugin.so ./libplugin.so

ENTRYPOINT ["/app/host"]
