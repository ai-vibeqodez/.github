# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--
Maintainer notes:
- Add every user-visible change under `## [Unreleased]` in the same commit that makes it.
- Categories: Breaking, Added, Changed, Deprecated, Removed, Fixed, Security. Omit empty ones.
- scripts/release.sh / scripts/release.ps1 derive the next version from those categories.
-->

## [Unreleased]

### Added

- Composite action `cmake-build`: CMake configure + build wrapper
- Composite action `ctest-run`: CTest execution wrapper
- Composite action `gcovr-report`: gcovr install + coverage report generation (XML + HTML)
- Composite action `badge-deploy`: SVG badge isolation + GitHub Pages deploy
- Composite action `coverage-html-deploy`: Coverage HTML deploy to gh-pages
- Composite action `docker-build-push`: Docker Buildx + login + build-push pipeline

### Changed

- `example-ci.yml`: simplified from 135 to 95 lines using new composite actions
- `release.yml`: simplified from 156 to 148 lines using `docker-build-push`
- `test.yml`: simplified using `badge-deploy` and `coverage-html-deploy`, added C++ stubs
- `ci.yml`: C++ stubs updated to reference `cmake-build` and `ctest-run`

### Removed

- `ci/.github/workflows/release.yml`: deleted (exact duplicate of production release.yml)

## [0.7.10] - 2026-11-15

### Fixed

- Release workflow: checkout main instead of tag so changelog-release can find release notes

## [0.7.9] - 2026-11-15

### Fixed

- Changelog release action: add release notes for v0.7.8

## [0.7.8] - 2026-11-15

### Fixed

- Release workflow: build artifacts before creating release so they attach to GitHub Release

## [0.7.7] - 2026-11-15

### Changed

- Docker build: remove debug step, keep only build-and-push job

## [0.7.6] - 2026-11-15

### Fixed

- Docker build: use `context: ./example` with `file: example/Dockerfile` (context scoped to example/, Dockerfile path relative to repo root)

## [0.7.5] - 2026-11-15

### Fixed

- Docker build: fix `file` path in `build-push-action` to `example/Dockerfile` with repository root context

## [0.7.4] - 2026-11-15

### Fixed

- Docker build: fix `context` and `file` paths in `build-push-action` to use `./example` context with correct Dockerfile reference
- Docker build: add debug step to verify example directory contents before build

## [0.7.3] - 2026-11-15

### Fixed

- Docker build: fix `context` and `file` paths in `build-push-action` to use `./example` context with correct Dockerfile reference

## [0.7.2] - 2026-11-15

### Fixed

- Docker image build: replace removed `gcc:13-alpine` with `gcc:14-bookworm`, runtime with `debian:trixie-slim`, fix COPY paths for built artifacts, add `.dockerignore`

## [0.7.1] - 2026-11-15

### Fixed

- Docker image tag: replace invalid `.` in path (`ghcr.io/ai-warevo/.github/example` → `ghcr.io/ai-warevo/example`)

## [0.7.0] - 2026-11-15

### Added

- `build-example` job: cmake build of plugin + host, upload as release artifacts
- `docker` job: `docker/build-push-action` to build and push to GHCR (was broken docker-save)
- Release assets: `libplugin.so` and `host` binaries included in release

## [0.6.2] - 2026-11-15

### Fixed

- YAML parsing error in `changelog-release` action (nested quotes in `description`)

## [0.6.0] - 2026-11-15

### Added

- `make release` / `make release-dry-run` targets for automated SemVer bumps from CHANGELOG
- `scripts/release.sh` and `scripts/release.ps1` — parse [Unreleased] categories, bump version, commit + tag
- Release workflow deployed to `.github/workflows/` for this repo (not just `ci/` templates)
- Docker build + GHCR push job in release workflow

## [0.5.0] - 2026-11-15

### Added

- Release workflow deployed to `.github/workflows/` for this repo
- Docker build + GHCR push job in release workflow

### Changed

- Composite actions pinned to commit SHA instead of `@main`

## [0.4.0] - 2026-11-15

### Added

- Composite actions: `collect-release-assets`, `docker-save`, `docker-push-ghcr`, `download-artifacts`, `checksums-verify`
- Docker build + GHCR push job in release workflow
- Multi-stage Dockerfile for example (C++23, Alpine, gcc13)

### Changed

- Split `checksums` action into generate-only + `checksums-verify` for reusability
- `release.yml`: added `packages: write, actions: write` permissions, `concurrency` block
- `ci.yml`, `test.yml`: added `packages: write` + `concurrency`
- Removed stale todo directories

## [0.3.0] - 2026-11-15

### Added

- `example/` CMake project with C++23, Catch2 v3, per-test discovery, sanitizer and coverage support
- CI workflow for example: tests + coverage reports (gcovr, XML + HTML) + coverage badge deploy
- Sanitizer CI jobs: AddressSanitizer + UBSan, ThreadSanitizer (with ASLR relaxation)
- README badges: License, CI, Coverage (from tpl pattern)

### Changed

- `.gitignore`: added `build` to exclude CMake build directories

## [0.2.0] - 2026-11-15

### Added

- Composite action `release-version`: resolves version from tag, workflow_dispatch input, or run_number
- Composite action `checksums`: generates and verifies SHA256SUMS for release artifacts
- `workflow_dispatch` trigger with optional `version` input in `release.yml`
- `softprops/action-gh-release` with `generate_release_notes: false`
- `SHA256SUMS.txt` included in release assets

### Changed

- `release.yml` refactored: version resolution extracted to composite action
- `release.yml` uses `fetch-depth: 0` for full changelog history

## [0.1.0] - 2026-11-15

### Added

- Infrastructure template repository: skills, templates, CI/CD configs, editor settings
- LLM server (llama.cpp) with Docker Compose and GPU support
- AI skills: analyst, planner, executor, skill-creator, git-github-push
- Project templates: overview, task, README, CHANGELOG, CONTRIBUTING
- Universal CI/CD workflow templates (ci.yml, test.yml) for Node.js, Python, C#, C++, Go, Rust, Java
- Custom GitHub Action: SVG Badge Generator
- Coverage badge generation and deployment to `badges` branch
- Coverage HTML report deployment to `gh-pages`

[0.3.0]: https://github.com/ai-warevo/.github/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/ai-warevo/.github/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/ai-warevo/.github/releases/tag/v0.1.0
