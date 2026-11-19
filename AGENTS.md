# AGENTS.md

Guidance for working on an `ai-warevo/<repo>`. Read `README.md` for the user-facing API; this file is about *how to change the repo*.

## Identity & philosophy

`ai-warevo/<repo>` is a **shared infrastructure monorepo** for the ai-warevo organisation. It contains reusable artefacts that any project consumes regardless of stack (C#, Python, JS, C++, Go, Rust, Java):

- **AI skills** (`skills/`) — agent-facing tool definitions for analyst, planner, executor, skill-creator, git-github-push.
- **Templates** (`templates/`) — OVERVIEW, task, README, CHANGELOG, CONTRIBUTING markdown skeletons.
- **CI/CD** (`ci/`) — GitHub Actions reusable workflows (`ci.yml`, `test.yml`, `release.yml`) and composite actions (`badge/`, `changelog-release/`, `checksums/`, `coverage-parser/`, `docker-build-push/`, etc.).
- **LLM server** (`docker-compose.yml`) — llama.cpp Docker Compose for local GPU-accelerated inference (RTX 4080, Qwen3.6-35B-A3B).
- **Example** (`example/`) — C++23 CMake project (Catch2 v3, sanitizers, coverage) used as smoke-test for CI templates and as a reference for projects adopting the CI workflow.

When designing a feature:
- Start from the **existing pattern** in the repo (templates, CI jobs, composite actions). Mirror naming and structure.
- Artefacts are **copied into consumer repos** — they must be self-contained and well-documented.
- A new CI template or composite action also needs a `ci/README.md` entry and an example in `example/` if it exercises a new capability.

## Build & test (fast local loop)

```sh
# CI example project: build + test
cmake -B build/dev -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/dev --parallel
ctest --test-dir build/dev --output-on-failure --parallel 4

# Coverage (requires gcovr)
cmake -B build/cov -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage"
cmake --build build/cov --parallel
ctest --test-dir build/cov --output-on-failure
gcovr -r build/cov/src --xml-pretty --output coverage.xml

# Docker Compose (llama.cpp server)
docker compose --profile llamacpp up -d    # start
docker compose --profile llamacpp logs -f  # watch
docker compose --profile llamacpp down     # stop
```

- **Leave to CI:** multi-platform builds (Linux/Windows/macOS), sanitizer runs (ASan/UBSan/TSan), coverage badge deploy, gh-pages HTML deploy, Docker build-push to GHCR. Don't run them locally unless debugging.
- Adding a composite action? Register it in `ci/README.md` table. Adding a workflow? Add it to `ci/.github/workflows/` and update `ci/README.md`.

## Changelog & releases

`CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com) and SemVer. It is the single source of release notes: the CI `release` job (`.github/workflows/release.yml`) extracts the `## [X.Y.Z]` section matching the pushed tag.

- **Every user-visible change adds a bullet under `## [Unreleased]` in the same commit** (public API, behaviour, build options, CI/tooling users see). Skip pure refactors and tests with no visible effect. One line per change, imperative, backticks for identifiers.
- **Categories** (omit empty ones, spell exactly): `Breaking`, `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
- **Version bump** is derived from the categories that have entries, highest wins: `Breaking`/`Removed` → major, `Added`/`Deprecated` → minor, `Fixed`/`Changed`/`Security` → patch.

Release helpers (run from anywhere inside the repo):

```sh
scripts/release.sh [--dry-run] [--push]          # Linux/macOS (bash >= 3.2)
./scripts/release.ps1 [-DryRun] [-Push]          # Windows PowerShell 5.1+ / pwsh
make release-dry-run                              # picks the right script per OS
make release [PUSH=1]
```

They print the detected categories and next `vX.Y.Z`, then promote `[Unreleased]` to `## [X.Y.Z] - <today>`, write the bare `X.Y.Z` to the root `VERSION` file, commit **only** `CHANGELOG.md` + `VERSION` as `release vX.Y.Z`, and create the annotated tag `vX.Y.Z`. They refuse to run with an empty `[Unreleased]`, an existing tag, or uncommitted tracked files other than those two.

## AI skills (how they work)

Each skill lives in `skills/<name>/SKILL.md`. A skill is a self-contained instruction set for the agent.

| Skill | Role |
|-------|------|
| `ai-warevo-orchestrator/` | Full pipeline: discover → prepare → impl → PR |
| `ai-warevo-issue-discoverer/` | Find & select issues from org repos |
| `ai-warevo-workspace-prepper/` | Fork, clone, create branch |
| `ai-warevo-code-impl/` | Implement changes, run tests |
| `ai-warevo-pr-manager/` | Push to fork, create PR, monitor CI |
| `git-github-push/` | Low-level git push via SSH |
| `analyst/` | Requirements gathering |
| `planner/` | Plan creation |
| `executor/` | Task execution |
| `skill-creator/` | Create new skills |

Skills are loaded via the `skill` tool. When editing a skill, keep it concise — agent context window is precious.

### Git workflow (shared rules)

All skills share these rules — see `git-github-push/` for the full reference:

- **Never commit to `main`** — always use a feature/fix branch.
- **Never push to `origin`** (`ai-warevo/...`) — read-only. Push only to `dshagent` (your fork).
- **If `dshagent` remote is missing** — fork first, then add it.
- **Always use SSH** — never HTTPS (rate limits).
- **Merging is the user's responsibility** — agent creates PR, monitors CI, never merges.

For details: [`git-github-push/SKILL.md`](skills/git-github-push/SKILL.md)

## CI/CD architecture

### Workflow hierarchy

```
ci/
├── .github/workflows/
│   ├── ci.yml          # build → lint → test (push/PR to main/develop)
│   ├── test.yml        # extended test (manual, push to main)
│   └── release.yml     # build → release → docker (tag push or workflow_dispatch)
└── actions/
    ├── badge/              # SVG coverage badge generation
    ├── changelog-release/  # release body from CHANGELOG.md
    ├── checksums/          # SHA256SUMS generation
    ├── checksums-verify/   # SHA256SUMS verification
    ├── collect-release-assets/  # download build artifacts
    ├── coverage-parser/    # parse coverage XML/LCOV
    ├── coverage-html-deploy/  # deploy HTML report to gh-pages
    ├── docker-build-push/  # Docker Buildx + login + push
    ├── docker-push-ghcr/   # push image to GHCR
    ├── docker-save/        # save image to tarball
    ├── download-artifacts/ # download artifacts from other jobs
    ├── release-version/    # resolve version from tag/input/run_number
    └── cmake-build/        # CMake configure + build wrapper
```

### Composite action conventions

- Each action lives in `ci/actions/<name>/action.yml` with a `README.md`.
- Actions accept inputs, produce outputs (via `$GITHUB_OUTPUT`).
- Always pin to a **40-char commit SHA** (not `@main` or a branch tag) in workflows that reference them.
- Actions should be **idempotent** and **self-healing** (retry on transient failures).

### SHA pinning convention

Pinning to `@main` is a supply-chain risk: a compromised branch can inject malicious code into any consumer workflow. Always resolve the latest commit SHA for the target directory:

```sh
# Composite action: resolve SHA for a directory
curl -s "https://api.github.com/repos/ai-warevo/<repo>/commits?path=ci/actions/<name>&per_page=1" \
  | jq -r '.[0].sha'

# Third-party action: resolve SHA for a tagged ref
curl -s "https://api.github.com/repos/<owner>/<repo>/git/ref/tags/<tag>" \
  | jq -r '.object.sha'
```

Update the SHA whenever the upstream action receives a meaningful update. Add a `Fixed` or `Changed` bullet to `CHANGELOG.md` under `## [Unreleased]` when bumping.

## Workflow conventions

- Use `concurrency` blocks to cancel stale runs on the same branch/PR.
- Use `needs` to establish job dependencies; keep the graph shallow.
- Matrix jobs for multi-platform/multi-version testing; single jobs for release.
- All workflows reference shared composite actions from `ai-warevo/<repo>/ci/actions/<name>@<40-char-SHA>`.

## Documentation & comments

- **README.md** is the user-facing entry point. Keep it focused on *what* and *how to use*.
- **AGENTS.md** (this file) is the developer-facing guide. Focus on *how to change the repo*.
- **ci/README.md** documents CI/CD templates — keep the action table and workflow descriptions up to date.
- Inline comments in scripts (`scripts/`) are minimal: explain the *why*, not the *what*.
- Template files (`templates/`) are consumed as-is — keep them clean and well-structured.

## Script conventions

- Shell scripts (`*.sh`) use `#!/usr/bin/env bash`, `set -euo pipefail`, and POSIX-compatible syntax where possible.
- PowerShell scripts (`*.ps1`) use `param()`, `Write-Error` for failures, and strict mode.
- Both scripts must produce equivalent behaviour; test both on CI.
- Scripts never edit files outside the repo; they operate on local paths.

## LLM server (docker-compose.yml)

- Runs llama.cpp server with CUDA on RTX 4080 (16GB VRAM).
- Primary model: **Qwen3.6-35B-A3B-UD-Q4_K_XL** (~21 GB, MoE ~3B active params).
- Hybrid GPU/CPU split: attention + KV on GPU, MoE experts overflow to CPU RAM.
- API: `http://host.docker.internal:8080/v1` (port 8080, may conflict).
- Model loaded from `./models/` volume (read-only).
- Health check polls `/health` every 15s; start period 180s.
- The API key must match `LLAMACPP_API_KEY` in `dsh-home/.credentials.yaml`.

## Contributing

1. Fork the repo (or work on a branch).
2. Make changes following the patterns above.
3. Update `CHANGELOG.md` under `## [Unreleased]` with the appropriate category.
4. Test locally if applicable (CMake build, docker compose).
5. Commit with [Conventional Commits](https://www.conventionalcommits.org) format.
6. Push and open a PR.

Release process:
```sh
make release-dry-run   # preview what will happen
make release           # create tag + release commit
make release PUSH=1    # push tag (triggers CI release workflow)
```
