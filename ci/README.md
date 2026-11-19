# Language-Agnostic CI/CD

This repository provides reusable GitHub Actions workflows for projects in `ai-warevo`. The shared workflows orchestrate a small Makefile contract; each project owns its build, test, coverage, and release commands. This keeps the CI control plane language-agnostic across C++, C#, Python, JavaScript/TypeScript, Go, Rust, and other stacks.

## Three workflows

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `pr-fast.yml` | Pull request to main/master | Lint, build, unit tests — fast feedback |
| `weekly-deep.yml` | Weekly cron (Mon 00:00 UTC), PR, manual | E2E, integration, sanitizers (ASan, TSan, UBSan) |
| `release.yml` | Tag push (`v*`) or manual | Bump version, update changelog, publish tag, create release with artifacts |

A failed check prevents downstream release publication. No shared workflow assumes a particular compiler, package manager, or test framework.

## Makefile contract

Each consumer repository must define these targets at its root:

- `pr-fast` — quick lint/format checks, build, and unit tests. For C++, a common choice is ASan + UBSan.
- `weekly-deep` — expensive stress, end-to-end/integration, security, or race-detection checks. For C++, this may include TSan and strict UBSan.
- `release` — trigger the release workflow (changelog → version derivation → tag → release).

Targets should fail with a nonzero status if a required command fails. The reusable workflows invoke only these names.

Example sanitizer flags for C++:

```make
# Fast memory/undefined-behavior checks
-fsanitize=address,undefined -fno-omit-frame-pointer

# Separate deep race-detection build (do not combine with ASan)
-fsanitize=thread -fno-omit-frame-pointer

# Strict UBSan variant
-fsanitize=undefined -fno-sanitize-recover=all
```

## Workflows

Reusable workflows live in `.github/workflows/`:

| Workflow | Purpose | Trigger |
| --- | --- | --- |
| `pr-fast.yml` | Lint, build, unit tests | `pull_request` to main/master |
| `weekly-deep.yml` | E2E, integration, sanitizers | `schedule` (weekly), `pull_request`, `workflow_dispatch` |
| `release.yml` | Bump version, update changelog, publish tag, create release | `push` (v* tags), `workflow_dispatch` |

The commit validator permits the standard types `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, and `revert`, with optional scope and breaking marker; maximum subject length is 88 characters. The generated `release vX.Y.Z` commit is exempt.

## Setup

1. Copy the workflow files into the project at `.github/workflows/pr-fast.yml`, `.github/workflows/weekly-deep.yml`, and `.github/workflows/release.yml`.
2. Uncomment the language stack block for your project in each workflow and replace placeholder commands with real ones.
3. Add the four Makefile targets (`pr-fast`, `weekly-deep`, `release`, `release-dry-run`) to the project Makefile.
4. Configure `setup-command` only where the selected hosted runner lacks a required tool. Keep the caller thin; the target repository Makefile remains the source of stack-specific behavior.
5. Verify that the changelog follows Keep a Changelog, and that the release commit from `make release` pushes the annotated `vX.Y.Z` tag. The tag must have an exact `## [X.Y.Z]` or `## [X.Y.Z] - YYYY-MM-DD` section in `CHANGELOG.md`; missing or empty notes fail the gate.
6. Run all Makefile targets locally. Open a PR and verify the PR status check before relying on it as a branch protection rule.
7. Add the project's status and coverage badges to its README.

## Permissions and security

Reusable workflows default to `contents: read`. Only the release publication job requests `contents: write` and `packages: write`. Callers should not grant broader permissions. Pin reusable workflow references to a reviewed ref; the copyable templates use `@main` as requested for easy adoption, while production consumers with stricter supply-chain requirements should replace it with a reviewed commit SHA. Third-party actions use modern major-version references in reusable workflows.

## Composite Actions

All composite actions live in `ci/actions/` and are referenced by consumer workflows using `ai-warevo/.github/ci/actions/<name>@<40-char-SHA>`. Each action has its own `README.md` with inputs, outputs, and usage examples.

| Action | Purpose |
| --- | --- |
| `badge/` | Generate custom SVG badges |
| `changelog-generate/` | Generate [Unreleased] section from git log (conventional commits) |
| `changelog-promote/` | Promote [Unreleased] to a version heading and write VERSION file |
| `changelog-release/` | Extract release notes from CHANGELOG.md by tag |
| `checksums/` | Generate SHA256SUMS.txt for files in a directory |
| `checksums-verify/` | Verify SHA256 checksums against a checksums file |
| `cmake-build/` | Configure, build, and optionally install with CMake |
| `coverage-html-deploy/` | Deploy coverage HTML report to GitHub Pages |
| `coverage-parser/` | Extract coverage percentage from coverage.xml or LCOV |
| `docker-build-push/` | Build and push a Docker image to a container registry |
| `release-version/` | Resolve release version from tag, input, or run_number |
