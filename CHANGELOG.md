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

[Unreleased]: https://github.com/ai-warevo/.github/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ai-warevo/.github/releases/tag/v0.1.0
