# ── Example C++23 Plugin — Docker image ──────────────────────────────────
#
# Многоэтапная сборка:
#   stage1 (builder) — cmake + make, C++23 на Debian bookworm
#   stage2 (runtime) — только бинарники host + libplugin
#
# Сборка:
#   docker build -t ghcr.io/ai-warevo/example -f example/Dockerfile .
#
# Запуск:
#   docker run --rm ghcr.io/ai-warevo/example

# ── Builder ───────────────────────────────────────────────────────────────
FROM gcc:14-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake make pkg-config \
    && rm -rf /var/lib/apt/lists/*

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
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /build/build/host/host ./host
COPY --from=builder /build/build/host/libplugin.so ./libplugin.so

ENTRYPOINT ["/app/host"]
