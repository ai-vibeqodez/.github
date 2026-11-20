---
name: ai-warevo-ci-setup
description: Bootstrap the standard Makefile CI contract and baseline reusable GitHub Actions workflows in a project repository
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
      ci_pr_fast: boolean
      ci_weekly_deep: boolean
      release: boolean
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

Use this skill when a repository lacks the standard CI contract or needs the complete baseline setup: `make pr-fast`, `make weekly-deep`, `make release`, and the three corresponding workflows. It owns bootstrap and baseline conformance; use `ai-warevo-ci-infrastructure-integrator` for selective catalog adoption or conflict-aware merging into an already configured project.

## Procedure

1. Inspect the repository before editing: read its README, build manifests, existing Makefile, tests, lint configuration, CHANGELOG, and all workflow files. Identify the actual stack, supported platforms, and existing CI behavior. Preserve valid project-specific jobs and avoid replacing workflows wholesale.
2. Add or extend the root Makefile with three public targets: `pr-fast`, `weekly-deep`, and `release`. Each target must invoke real project commands and return nonzero on failure. Do not put stack-specific commands in the shared reusable workflows.
3. Implement `pr-fast` with formatting/lint checks, a fast build, and unit tests. For C++ projects, use the project's configured language standard (C++23 is the reference profile here), build system, compiler, and test framework; prefer existing CMake presets/targets and do not assume a particular compiler or test library. Use AddressSanitizer plus UndefinedBehaviorSanitizer when supported. Keep the target suitable for every PR.
4. Implement `weekly-deep` with slower stress, integration/E2E, security, or race checks. For C++, include ThreadSanitizer and strict UBSan configurations as supported by the compiler and project. Keep duplicate work out of `pr-fast` where practical. Coverage and badge generation belong in this target.
5. Implement `release` to trigger the release workflow via `gh workflow run release.yml --ref main`. Support optional `VERSION` override (`make release VERSION=1.2.3`). The workflow handles changelog derivation, version bump, tag creation, and GitHub Release publication.
6. Copy the reusable workflows from `templates/workflows/` into the project at `.github/workflows/pr-fast.yml`, `.github/workflows/weekly-deep.yml`, and `.github/workflows/release.yml`. Customize `name`, `on:`, and `with:` inputs. Replace `@main` in the `uses:` line with a pinned SHA for stricter supply-chain requirements. Supply only necessary setup commands (for example, install a compiler/toolchain). Enable `update-badge: true` only after confirming the repository has a `badges` branch and the workflow token can write contents.
8. Ensure tag releases use `vX.Y.Z` tags created by the project's `make release PUSH=1` flow. Keep `CHANGELOG.md` in Keep a Changelog format, with a heading `## [X.Y.Z] - YYYY-MM-DD`; the reusable release gate requires an exact matching section and blocks publication if it is missing or empty.
9. Review least-privilege permissions, concurrency behavior, action references, and existing status checks. Validate YAML syntax and run all four Makefile targets locally where feasible. Report any external services or credentials that prevent full validation.
10. Update README/CI documentation and the changelog as the repository requires. Summarize files changed, commands run, and unresolved setup requirements.

## Required Contract

| Target | Required behavior |
| --- | --- |
| `make pr-fast` | Fast lint/format, build, and unit checks |
| `make weekly-deep` | Scheduled/deep verification with coverage and badge |
| `make release` | Trigger release workflow (changelog → version → tag → release) |

## Guardrails

- Preserve project-specific workflows and merge with them deliberately.
- Never report a placeholder/no-op target as implemented; targets must execute real checks.
- Do not store credentials in Makefiles or workflow files.
- Keep permissions minimal; badge publishing needs `contents: write` only in its publishing job.
- Do not publish a release unless both fast and deep gates pass and the exact changelog section exists.
