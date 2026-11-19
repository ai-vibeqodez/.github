---
name: ci-setup
description: Bootstrap the shared language-agnostic Makefile CI contract and reusable GitHub Actions workflows in a project repository.
inputs:
  repo_path:
    type: string
    required: true
    description: "Path to the repository root"
  stack:
    type: object
    required: false
    description: "Language, build system, test framework"
    properties:
      language: string
      build_system: string
      test_framework: string
outputs:
  makefile_targets:
    type: object
    properties:
      ci_fast: boolean
      ci_deep: boolean
      ci_coverage: boolean
      build_release: boolean
  workflow_files:
    type: file[]
    path_pattern: ".github/workflows/*.yml"
  coverage_svg:
    type: file
    path: "coverage.svg"
  dist_artifacts:
    type: file[]
    path_pattern: "dist/*"
---

# CI Setup

## Input Validation
1. Verify `repo_path` exists and is a git repository root
2. If `stack` is provided, verify at least `language` is specified
3. If validation fails, report error and stop

Use this skill when a repository needs PR checks, scheduled verification, and a gated release workflow based on `ai-warevo/.github`.

## Procedure

1. Inspect the repository before editing: read its README, build manifests, existing Makefile, tests, lint configuration, CHANGELOG, and all workflow files. Identify the actual stack, supported platforms, and existing CI behavior. Preserve valid project-specific jobs and avoid replacing workflows wholesale.
2. Add or extend the root Makefile with four public targets: `ci-fast`, `ci-deep`, `ci-coverage`, and `build-release`. Each target must invoke real project commands and return nonzero on failure. Do not put stack-specific commands in the shared reusable workflows.
3. Implement `ci-fast` with formatting/lint checks, a fast build, and unit tests. For C++, use AddressSanitizer plus UndefinedBehaviorSanitizer when supported. Keep the target suitable for every PR.
4. Implement `ci-deep` with slower stress, integration/E2E, security, or race checks. For C++, include ThreadSanitizer and strict UBSan configurations as supported. Keep duplicate work out of `ci-fast` where practical.
5. Implement `ci-coverage` to run tests with the repository's native coverage tooling and produce `coverage.svg` in the repository root. The SVG must be a complete, valid image suitable for publishing to the `badges` branch. Document the metric's source and threshold in the project if not obvious.
6. Implement `build-release` to create optimized production artifacts under `dist/`. Ensure `dist/` contains the files intended for attachment to a GitHub Release and no temporary build tree.
7. Copy and adapt the thin callers from `templates/github/workflows/`: PR calls `reusable-pr.yml`; schedule/manual calls `reusable-scheduled.yml`; a `v*` tag calls `reusable-release.yml`. Supply only necessary setup commands (for example, install a compiler/toolchain). Do not embed build/test commands in the callers. Enable `update-badge: true` only after confirming the repository has a `badges` branch and the workflow token can write contents.
8. Ensure tag releases use `vX.Y.Z` tags created by the project's `make release PUSH=1` flow. Keep `CHANGELOG.md` in Keep a Changelog format, with a heading `## [X.Y.Z] - YYYY-MM-DD`; the reusable release gate requires an exact matching section and blocks publication if it is missing or empty.
9. Review least-privilege permissions, concurrency behavior, action references, and existing status checks. Validate YAML syntax and run all four Makefile targets locally where feasible. Report any external services or credentials that prevent full validation.
10. Update README/CI documentation and the changelog as the repository requires. Summarize files changed, commands run, and unresolved setup requirements.

## Required Contract

| Target | Required behavior |
| --- | --- |
| `make ci-fast` | Fast lint/format, build, and unit checks |
| `make ci-deep` | Scheduled/release heavy verification |
| `make ci-coverage` | Coverage tests and root `coverage.svg` |
| `make build-release` | Optimized artifacts under `dist/` |

## Guardrails

- Preserve project-specific workflows and merge with them deliberately.
- Never report a placeholder/no-op target as implemented; targets must execute real checks.
- Do not store credentials in Makefiles or workflow files.
- Keep permissions minimal; badge publishing needs `contents: write` only in its publishing job.
- Do not publish a release unless both fast and deep gates pass and the exact changelog section exists.
