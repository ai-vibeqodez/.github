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
