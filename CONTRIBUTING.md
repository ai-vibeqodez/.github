# Contributing to ai-warevo/.github

Thank you for your interest in contributing! This repository provides shared CI/CD infrastructure, AI skills, and templates for the [ai-warevo](https://github.com/ai-warevo) organization.

## Table of Contents

- [Development Setup](#development-setup)
- [Testing Composite Actions](#testing-composite-actions)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Adding a New CI Template](#adding-a-new-ci-template)
- [Adding a Composite Action](#adding-a-composite-action)
- [Creating a New Skill](#creating-a-new-skill)
- [Expanding Skeleton Templates](#expanding-skeleton-templates)
- [Code Style](#code-style)
- [Questions?](#questions)

## Development Setup

1. **Fork the repository** — work on your fork, never push directly to `ai-warevo/.github`.

2. **Clone your fork**:
   ```bash
   git clone git@github.com:<your-username>/.github.git
   cd .github
   ```

3. **Add remotes**:
   ```bash
   git remote add origin git@github.com:ai-warevo/.github.git
   git remote add dshagent git@github.com:<your-fork-username>/.github.git
   ```

4. **Install Docker and Docker Compose** — required for testing the LLM server and CI examples.
   ```bash
   docker --version
   docker compose version
   ```

5. **Install CMake and Ninja** — required for testing the example project.
   ```bash
   cmake --version
   ninja --version
   ```

## Testing Composite Actions

Composite actions are tested via the `example/` project:

```bash
# Build the example C++ project
cmake -B build/dev -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/dev --parallel

# Run tests
ctest --test-dir build/dev --output-on-failure --parallel 4

# Test coverage (requires gcovr)
cmake -B build/cov -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage"
cmake --build build/cov --parallel
ctest --test-dir build/cov --output-on-failure
gcovr -r build/cov/src --xml-pretty --output coverage.xml
```

To test the LLM server locally:

```bash
# Start llama.cpp server (requires GPU)
docker compose --profile llamacpp up -d
docker compose --profile llamacpp logs -f   # watch
docker compose --profile llamacpp down       # stop
```

## Commit Conventions

All commits follow [Conventional Commits](https://www.conventionalcommits.org):

```
type(scope): description

Closes #NNN
```

| Type | When to use | Example |
|------|-------------|---------|
| `feat` | New feature or capability | `feat(actions): add docker-save composite action` |
| `fix` | Bug fix | `fix(ci): correct SHA pinning for badge action` |
| `docs` | Documentation changes | `docs: expand readme_template.md` |
| `chore` | Maintenance, config changes | `chore: update VERSION to 1.2.0` |
| `refactor` | Code refactoring without behavior change | `refactor(actions): simplify docker-build-push logic` |
| `test` | Adding or fixing tests | `test: add coverage parser test` |
| `ci` | CI/CD workflow changes | `ci: add BYMINUTE guard to scheduled workflow` |
| `style` | Formatting, whitespace | `style: fix indentation in release.sh` |
| `perf` | Performance improvements | `perf(actions): parallelize artifact download` |

**Rules:**
- Subject line: max 88 characters
- Use imperative mood ("add" not "added" or "adds")
- Backticks for identifiers: `ci/`, `action.yml`, `CHANGELOG.md`
- Reference the issue: `Closes #NNN` in the body

## Pull Request Process

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feat/issue-NNN
   ```

2. **Make changes** — keep them focused and minimal. One issue = one PR.

3. **Update `CHANGELOG.md`** under `## [Unreleased]` with an appropriate category:
   - `Breaking`, `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`

4. **Commit your changes**:
   ```bash
   git add -A
   git commit -m "feat(#5): add CONTRIBUTING.md and expand templates

   Closes #5"
   ```

5. **Push to your fork**:
   ```bash
   git push dshagent feat/issue-NNN
   ```

6. **Open a Pull Request** targeting `ai-warevo/.github:main`.

7. **Wait for CI** — ensure all checks pass before requesting review.

8. **Do not merge** — merging is the repository maintainer's responsibility.

## Adding a New CI Template

1. Create the workflow file in `ci/.github/workflows/`.
2. Add a `ci/README.md` table entry documenting the workflow.
3. If it exercises a new capability, add an example in `example/`.
4. Update `CHANGELOG.md` under `## [Unreleased]`.

## Adding a Composite Action

1. Create the action in `ci/actions/<name>/action.yml` with a `README.md`.
2. **Pin to a 40-char commit SHA** in all workflows that reference it — never use `@main`.
3. Resolve the latest SHA:
   ```bash
   curl -s "https://api.github.com/repos/ai-warevo/.github/commits?path=ci/actions/<name>&per_page=1" \
     | jq -r '.[0].sha'
   ```
4. Add a `README.md` explaining inputs, outputs, and usage.
5. Register it in the `ci/README.md` action table.
6. Update `CHANGELOG.md` under `## [Unreleased]`.

## Creating a New Skill

1. Create `skills/<name>/SKILL.md` following the [metadata schema](AGENTS.md#skillmd-metadata-schema).
2. Include an `## Input Validation` section with concrete checks.
3. Update `skills/README.md` with a summary entry.
4. Update `AGENTS.md` skill catalog table.
5. Update `CHANGELOG.md` under `## [Unreleased]`.

## Expanding Skeleton Templates

Templates in `templates/` are consumed as-is by consumer projects. When expanding them:

1. Add meaningful placeholders with examples (not just `<placeholder>`).
2. Include bilingual comments (Russian/English) where helpful.
3. Keep templates self-contained — they must work without external references.
4. Update `CHANGELOG.md` under `## [Unreleased]`.

## Code Style

- **Shell scripts** (`*.sh`): `#!/usr/bin/env bash`, `set -euo pipefail`, POSIX-compatible syntax.
- **PowerShell scripts** (`*.ps1`): `param()`, `Write-Error` for failures, strict mode.
- **YAML**: 2-space indentation, no trailing whitespace.
- **Markdown**: Soft wraps at 120 characters, use ATX headings, include table of contents for long docs.
- **Inline comments**: Explain the *why*, not the *what*.

## Questions?

Open an issue on this repository or join the discussion in an existing issue thread.
