# Architecture Overview

This document describes the architecture of the `ai-warevo/.github` repository — a shared infrastructure monorepo providing CI/CD workflows, composite actions, AI skills, and templates for the ai-warevo organization.

## Table of Contents

- [High-Level Overview](#high-level-overview)
- [Directory Structure](#directory-structure)
- [CI/CD Architecture](#cicd-architecture)
- [Composite Actions](#composite-actions)
- [Workflow Hierarchy](#workflow-hierarchy)
- [Release Pipeline](#release-pipeline)
- [AI Skills](#ai-skills)
- [Templates](#templates)
- [Example Project](#example-project)
- [LLM Server](#llm-server)
- [Data Flow](#data-flow)

## High-Level Overview

```
ai-warevo/.github/
│
├── ci/                          # CI/CD templates and composite actions
│   ├── .github/workflows/       # Reusable workflow definitions
│   └── actions/                 # Composite actions (19 total)
│
├── templates/                   # Reusable file skeletons
│   ├── github/workflows/        # Workflow templates for consumers
│   ├── readme_template.md
│   ├── overview.md
│   ├── contributing_template.md
│   ├── task_template.md
│   ├── changelog_template.md
│   └── Makefile.ci
│
├── skills/                      # AI agent skills
│   ├── ai-warevo-orchestrator/
│   ├── ai-warevo-issue-discoverer/
│   ├── ai-warevo-workspace-prepper/
│   ├── ai-warevo-code-impl/
│   ├── ai-warevo-pr-manager/
│   └── ...
│
├── example/                     # Reference C++23 CMake project
├── workflows/                   # Root-level workflow definitions
├── scripts/                     # Release and utility scripts
├── docker-compose.yml           # LLM server configuration
└── AGENTS.md                    # Developer guide
```

## Directory Structure

| Directory | Purpose | Consumers |
|-----------|---------|-----------|
| `ci/` | CI/CD workflows and composite actions | All ai-warevo projects |
| `templates/` | File skeletons copied into consumer repos | All ai-warevo projects |
| `skills/` | AI agent instruction sets | ai-warevo-analyst, planner, executor |
| `example/` | Reference C++23 project with CI | CI template validation |
| `scripts/` | Release automation scripts | Maintainers |
| `workflows/` | Root-level workflow definitions | Internal use |

## CI/CD Architecture

### Three-Tier CI Model

The CI system operates on three tiers, each with distinct triggers and purposes:

```
┌─────────────────────────────────────────────────────────────────┐
│                        CI/CD Tiers                              │
├──────────┬──────────────┬──────────────────┬────────────────────┤
│ Tier     │ Trigger      │ Purpose          │ Contract           │
├──────────┼──────────────┼──────────────────┼────────────────────┤
│ PR       │ Pull request │ Fast feedback    │ make ci-fast       │
│          │              │ Commit validation│                    │
├──────────┼──────────────┼──────────────────┼────────────────────┤
│ Scheduled│ Cron/Manual  │ Deep tests       │ make ci-deep       │
│          │              │ Coverage         │ make ci-coverage   │
├──────────┼──────────────┼──────────────────┼────────────────────┤
│ Release  │ v* tag push  │ Build + publish  │ make build-release │
│          │              │ Release notes    │                    │
└──────────┴──────────────┴──────────────────┴────────────────────┘
```

### Makefile Contract

Each consumer repository defines four targets at its root:

| Target | Purpose | Example Commands |
|--------|---------|-----------------|
| `ci-fast` | Quick lint, build, unit tests | `cmake --build`, `ctest` |
| `ci-deep` | Stress, integration, security tests | `TSan`, `UBSan` |
| `ci-coverage` | Coverage report generation | `gcovr` → `coverage.svg` |
| `build-release` | Production artifacts | `cmake --build --config Release` |

## Composite Actions

The repository provides 19 composite actions organized by function:

### Build Actions

| Action | Purpose |
|--------|---------|
| `cmake-build/` | CMake configure + build wrapper |
| `setup-toolchain/` | Compiler and toolchain setup |
| `clang-format/` | Code formatting check |
| `clang-tidy/` | Static analysis |

### Test Actions

| Action | Purpose |
|--------|---------|
| `ctest-run/` | Execute CTest suite |
| `coverage-parser/` | Parse coverage XML/LCOV |
| `gcovr-report/` | Generate gcovr HTML report |

### Release Actions

| Action | Purpose |
|--------|---------|
| `changelog-release/` | Extract release notes from CHANGELOG.md |
| `checksums/` | Generate SHA256SUMS |
| `checksums-verify/` | Verify SHA256SUMS |
| `collect-release-assets/` | Download build artifacts |
| `release-version/` | Resolve version from tag/input |

### Docker Actions

| Action | Purpose |
|--------|---------|
| `docker-build-push/` | Docker Buildx + login + push |
| `docker-push-ghcr/` | Push image to GHCR |
| `docker-save/` | Save image to tarball |

### Badge Actions

| Action | Purpose |
|--------|---------|
| `badge/` | Generate coverage SVG badge |
| `badge-deploy/` | Deploy badge to badges branch |
| `coverage-html-deploy/` | Deploy HTML report to gh-pages |

### Utility Actions

| Action | Purpose |
|--------|---------|
| `download-artifacts/` | Download artifacts from other jobs |

### SHA Pinning

All action references in workflows are pinned to 40-char commit SHAs:

```yaml
- uses: ai-warevo/.github/ci/actions/cmake-build@abc123def456...
```

## Workflow Hierarchy

```
Reusable Workflows (ci/.github/workflows/)
│
├── ci.yml              # PR tier: lint + build + test
├── test.yml            # Scheduled tier: deep tests + coverage
└── release.yml         # Release tier: build + release + publish
│
Consumer Workflows (templates/github/workflows/)
│
├── pr.yml              # Called by consumer: runs make ci-fast
├── scheduled.yml       # Called by consumer: runs make ci-deep
└── release.yml         # Called by consumer: runs make build-release
```

### Consumer Integration

Consumer repos copy template workflows and configure:

```yaml
# .github/workflows/pr.yml
name: PR
on: pull_request
jobs:
  pr:
    uses: ai-warevo/.github/ci/.github/workflows/ci.yml@<sha>
    with:
      setup-command: "sudo apt-get update && sudo apt-get install -y g++"
```

## Release Pipeline

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│  Tag Push   │────▶│  CI Release  │────▶│  Build Artifacts│
│  vX.Y.Z     │     │  (ci.yml)    │     │  (dist/)        │
└─────────────┘     └──────────────┘     └────────┬────────┘
                                                  │
                                          ┌───────▼────────┐
                                          │ Extract Changelog│
                                          │ (changelog-      │
                                          │  release/)       │
                                          └───────┬────────┘
                                                  │
                                          ┌───────▼────────┐
                                          │ Create GitHub   │
                                          │ Release         │
                                          └────────────────┘
```

### Release Process

1. **Local release** (maintainer):
   ```bash
   make release-dry-run   # Preview changes
   make release           # Create release commit + tag
   make release PUSH=1    # Push tag (triggers CI)
   ```

2. **CI release** (automatic on tag push):
   - Run `ci-fast` and `ci-deep` in parallel
   - Build release artifacts with `build-release`
   - Extract changelog section matching the tag
   - Create GitHub Release with exact notes
   - Publish Docker image (if applicable)

### Version Resolution

Version is derived from changelog categories (highest wins):

| Category | Bump Type |
|----------|-----------|
| `Breaking`, `Removed` | Major |
| `Added`, `Deprecated` | Minor |
| `Fixed`, `Changed`, `Security` | Patch |

## AI Skills

The repository provides 12 AI skills for autonomous issue resolution:

```
Orchestrator Pipeline
│
├── ai-warevo-issue-discoverer/    # Find & select issue
│       │
│       ▼
├── ai-warevo-workspace-prepper/   # Fork, clone, branch
│       │
│       ▼
├── ai-warevo-code-impl/           # Implement + test
│       │
│       ▼
└── ai-warevo-pr-manager/          # Push + PR + monitor
```

### Skill Categories

| Category | Skills |
|----------|--------|
| **Pipeline** | orchestrator, issue-discoverer, workspace-prepper, code-impl, pr-manager |
| **Support** | git-github-push, analyst, planner, executor |
| **Meta** | skill-creator, ci-infrastructure-integrator, ci-setup |

## Templates

Templates are self-contained files copied into consumer repositories:

```
templates/
│
├── github/workflows/          # Workflow skeletons
│   ├── pr.yml                 # PR CI workflow
│   ├── scheduled.yml          # Scheduled CI workflow
│   └── release.yml            # Release CI workflow
│
├── readme_template.md         # README skeleton
├── overview.md                # Project overview skeleton
├── contributing_template.md   # Contributing guide skeleton
├── task_template.md           # Task definition skeleton
├── changelog_template.md      # Changelog skeleton
└── Makefile.ci                # Makefile contract scaffold
```

### Template Consumption

Consumer projects copy templates during setup:

```bash
mkdir -p .github/workflows
cp templates/github/workflows/pr.yml .github/workflows/pr.yml
cp templates/github/workflows/scheduled.yml .github/workflows/scheduled.yml
cp templates/github/workflows/release.yml .github/workflows/release.yml
```

## Example Project

The `example/` directory contains a C++23 CMake project used to:

1. **Validate CI templates** — exercises all CI workflows
2. **Demonstrate composite actions** — uses cmake-build, ctest-run, coverage-parser
3. **Test release pipeline** — full build → test → coverage → release cycle

### Example Project Structure

```
example/
├── CMakeLists.txt             # CMake configuration
├── Dockerfile                 # Container for CI
├── README.md                  # Usage examples
├── src/                       # Source files
│   └── main.cpp
├── include/                   # Header files
├── plugin/                    # Plugin system (Catch2)
├── host/                      # Host application
└── build/                     # Build output (gitignored)
```

## LLM Server

The `docker-compose.yml` provides a local llama.cpp server for development:

```
┌─────────────────────────────────────────────┐
│              LLM Server                      │
│                                              │
│  Model: Qwen3.6-35B-A3B-UD-Q4_K_XL         │
│  GPU: RTX 4080 (16GB VRAM)                  │
│  API: http://host.docker.internal:8080/v1   │
│  Auth: API key required (LLAMACPP_API_KEY)  │
│                                              │
│  Hybrid GPU/CPU:                            │
│  - Attention + KV cache → GPU               │
│  - MoE experts overflow → CPU RAM           │
└─────────────────────────────────────────────┘
```

## Data Flow

### CI Data Flow

```
Developer Push
     │
     ▼
GitHub Actions Runner
     │
     ├── PR Tier ──▶ ci.yml ──▶ lint ──▶ build ──▶ test ──▶ Pass/Fail
     │
     ├── Scheduled ──▶ test.yml ──▶ deep test ──▶ coverage ──▶ badge deploy
     │
     └── Release ──▶ release.yml ──▶ gate ──▶ build ──▶ changelog ──▶ publish
```

### Release Data Flow

```
CHANGELOG.md (## [X.Y.Z] section)
        │
        ▼
changelog-release/ action
        │
        ▼
Release Notes (GitHub API)
        │
        ▼
GitHub Release (vX.Y.Z)
        │
        ├── Artifacts (dist/)
        ├── Docker Image (GHCR)
        └── Coverage Badge (badges branch)
```

### Skill Pipeline Data Flow

```
Issue (#NNN)
     │
     ▼
ai-warevo-issue-discoverer
     │  output: issue details, classification
     ▼
ai-warevo-workspace-prepper
     │  output: working directory, branch name
     ▼
ai-warevo-code-impl
     │  output: commit hash, test confirmation
     ▼
ai-warevo-pr-manager
     │  output: PR URL, CI status
     ▼
PR (targeting ai-warevo/.github:main)
```
