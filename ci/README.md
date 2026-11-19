# Language-Agnostic CI/CD

This repository provides reusable GitHub Actions workflows for projects in `ai-warevo`. The shared workflows orchestrate a small Makefile contract; each project owns its build, test, coverage, and release commands. This keeps the CI control plane language-agnostic across C++, C#, Python, JavaScript/TypeScript, Go, Rust, and other stacks.

## Three tiers

| Tier | Trigger | Purpose | Contract |
| --- | --- | --- | --- |
| PR | Pull request | Fast, repeatable feedback and commit subject validation | `make ci-fast` |
| Scheduled | Weekly/nightly cron or manual dispatch | Slow tests, stress, security, race checks, and coverage | `make ci-deep`, `make ci-coverage` |
| Release Gate | Push of a `v*` tag | Require fast and deep checks in parallel, then build and publish exact release notes and artifacts | `make ci-fast`, `make ci-deep`, `make build-release` |

A failed check prevents downstream release publication. No shared workflow assumes a particular compiler, package manager, or test framework.

## Makefile contract

Each consumer repository must define these targets at its root:

- `ci-fast`: quick lint/format checks, build, and unit tests. For C++, a common choice is ASan + UBSan.
- `ci-deep`: expensive stress, end-to-end/integration, security, or race-detection checks. For C++, this may include TSan and strict UBSan.
- `ci-coverage`: execute the coverage-enabled test suite and generate a valid `coverage.svg` at the repository root.
- `build-release`: create optimized production artifacts under `dist/`.

Targets should fail with a nonzero status if a required command fails. The reusable workflows invoke only these names. See [`templates/Makefile.ci`](../templates/Makefile.ci) for an intentionally unconfigured scaffold; replace its guard examples with real commands before adoption.

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

Reusable workflows live in `.github/workflows/` and are called by repositories in the organization using `workflow_call`:

| Workflow | Purpose | Inputs |
| --- | --- | --- |
| `reusable-pr.yml` | Validate Conventional Commit subjects and run `make ci-fast` | Optional `setup-command` |
| `reusable-scheduled.yml` | Run `make ci-deep` and `make ci-coverage`; optionally publish `coverage.svg` to `badges` | Optional `setup-command`; `update-badge` defaults to `false` |
| `reusable-release.yml` | Gate on fast and deep checks, build `dist/`, extract the exact tag section from CHANGELOG, create a GitHub Release | Optional `setup-command` |

The commit validator permits the standard types `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, and `revert`, with optional scope and breaking marker; maximum subject length is 88 characters. The generated `release vX.Y.Z` commit is exempt. A PR caller should run on pull requests; the release caller must trigger on `v*` tags. Scheduled callers should include both a cron and `workflow_dispatch` if manual operation is desired.

`setup-command` is an optional shell command for installing tools (for example, `sudo apt-get update && sudo apt-get install -y g++`). Keep it limited to trusted package installation. It executes in the caller repository's job context. Prefer a preinstalled runner toolchain or a maintained setup action where practical.

## Setup

1. Add real `ci-fast`, `ci-deep`, `ci-coverage`, and `build-release` recipes to the project Makefile. Use [`templates/Makefile.ci`](../templates/Makefile.ci) as a starting point, not as production-ready commands.
2. Ensure `ci-coverage` writes a valid root-level `coverage.svg`. Ensure `build-release` creates the intended release files inside `dist/`.
3. Copy the caller templates into the project at `.github/workflows/pr.yml`, `.github/workflows/scheduled.yml`, and `.github/workflows/release.yml`:

   ```sh
   mkdir -p .github/workflows
   cp path/to/ai-warevo/.github/templates/github/workflows/pr.yml .github/workflows/pr.yml
   cp path/to/ai-warevo/.github/templates/github/workflows/scheduled.yml .github/workflows/scheduled.yml
   cp path/to/ai-warevo/.github/templates/github/workflows/release.yml .github/workflows/release.yml
   ```

4. Configure `setup-command` only where the selected hosted runner lacks a required tool. Keep the caller thin; the target repository Makefile remains the source of stack-specific behavior.
5. Enable badge publication with `update-badge: true` only after creating the target repository's `badges` branch and granting its workflow token `contents: write` (Settings → Actions → General → Workflow permissions). The shared job requests write permission only for badge publication. Keep it `false` otherwise.
6. Verify that the changelog follows Keep a Changelog, and that the release commit from `make release PUSH=1` pushes the annotated `vX.Y.Z` tag. The tag must have an exact `## [X.Y.Z]` or `## [X.Y.Z] - YYYY-MM-DD` section in `CHANGELOG.md`; missing or empty notes fail the gate.
7. Run all four Makefile targets locally. Open a PR and verify the PR status check before relying on it as a branch protection rule.
8. Add the project's status and coverage badges to its README. The coverage image URL is `https://raw.githubusercontent.com/OWNER/REPOSITORY/badges/coverage.svg`.

## Permissions and security

Reusable workflows default to `contents: read`. Only the scheduled badge publication job and release publication job request `contents: write`. Callers should not grant broader permissions. Pin reusable workflow references to a reviewed ref; the copyable templates use `@main` as requested for easy adoption, while production consumers with stricter supply-chain requirements should replace it with a reviewed commit SHA. Third-party actions use modern major-version references in reusable workflows.

## Existing stack-specific CI

This shared repository also contains established C++ container workflows and composite actions under `ci/.github/` and `ci/actions/`. They remain available for consumers that need their specialized matrix/build behavior. The Makefile contract workflows are an additional simpler integration path, not a replacement for those existing workflows.
