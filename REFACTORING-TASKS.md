# GitHub Actions Composite Actions Refactoring — Task List

> **Goal:** Make workflows minimal, concise, and composable. Replace inline multi-step
> patterns with reusable composite actions. Keep actions focused (1–2 steps each).

---

## P0 — Critical Path: Production `example-ci.yml`

### Task 1: Create `cmake-build` composite action
**Priority:** P0 (blocks everything)
**Purpose:** Encapsulate the C++ CMake configure + build + test + coverage pipeline.
Currently, `example-ci.yml` spreads checkout → apt-get → cmake configure → cmake build
→ ctest → gcovr across 7 steps. This action wraps the entire C++ build pipeline.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `source_dir` | no | `example` | CMake source directory |
| `build_type` | no | `Debug` | CMAKE_BUILD_TYPE |
| `build_tests` | no | `ON` | AW_EXAMPLE_BUILD_TESTS flag |
| `coverage` | no | `ON` | AW_EXAMPLE_ENABLE_COVERAGE flag |
| `sanitizer` | no | `` | AW_EXAMPLE_SANITIZE value (empty = none) |
| `cc` | no | `gcc` | C compiler |
| `cxx` | no | `g++` | C++ compiler |
| `ctest_timeout` | no | `` | ctest --timeout value |
| `gcovr_filter` | no | `example/` | gcovr --filter pattern |
| `gcovr_exclude_deps` | no | `true` | Exclude `_deps/*` |

**Outputs:**
| Name | Description |
|---|---|
| `coverage_xml` | Path to generated coverage.xml |
| `coverage_html` | Path to generated htmlcov/ |

**Replaces in `example-ci.yml`:**
- `tests-and-coverage` job: steps 1–6 (Checkout, Install gcovr, Configure & Build, Run CTest, Generate Coverage Reports)
- `sanitizers` job: steps 2–4 (Checkout, sysctl, Configure & Build, Run CTest) — with `sanitizer` input

**Before (inline, ~25 lines):**
```yaml
- uses: actions/checkout@v4
- run: sudo apt-get update && sudo apt-get install -y gcovr
- run: |
    cmake -S example -B build -DCMAKE_BUILD_TYPE=Debug \
      -DAW_EXAMPLE_BUILD_TESTS=ON -DAW_EXAMPLE_ENABLE_COVERAGE=ON
    cmake --build build --parallel
- run: ctest --test-dir build -C Debug --output-on-failure
- run: |
    mkdir -p htmlcov
    gcovr -r build/ --gcov-ignore-errors=no_working_dir_found \
      --filter 'example/' --exclude 'build/_deps/*' \
      --exclude-unreachable-branches --exclude-throw-branches \
      --print-summary --xml coverage.xml \
      --html-details htmlcov/index.html
```

**After (1 step):**
```yaml
- name: CMake Build & Test
  id: build
  uses: ./.github/ci/actions/cmake-build
  with:
    source_dir: example
    build_type: Debug
    build_tests: ON
    coverage: ON
```

---

### Task 2: Create `coverage-report` composite action
**Priority:** P0 (blocks `example-ci.yml` cleanup)
**Purpose:** Combines coverage-parser + badge generation + badge deploy + htmlcov deploy
into a single composable unit. Handles the full coverage→badge→deploy chain.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `xml_path` | no | `coverage.xml` | Path to coverage.xml |
| `badge_width` | no | `99` | SVG badge width |
| `badge_height` | no | `20` | SVG badge height |
| `badge_text_left` | no | `coverage` | Left badge text |
| `badge_output` | no | `coverage.svg` | Output badge filename |
| `badge_branch` | no | `badges` | Branch for badge deploy |
| `pages_branch` | no | `gh-pages` | Branch for htmlcov deploy |
| `deploy_if` | no | `push && refs/heads/main` | GitHub condition expression |

**Outputs:**
| Name | Description |
|---|---|
| `percent` | Coverage percentage (from coverage-parser) |
| `color` | Badge color hex (from coverage-parser) |
| `badge_path` | Path to generated SVG |

**Replaces in `example-ci.yml`:**
- `tests-and-coverage` job: steps 7–12 (Parse Coverage, Generate Badge, Isolate Badge, Deploy Badge, touch htmlcov, Deploy HTML)

**Before (inline, ~30 lines):**
```yaml
- id: coverage_parser
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  uses: ./.github/ci/actions/coverage-parser
  with:
    xml_path: coverage.xml
- id: badge_generator
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  uses: ai-warevo/.github/ci/actions/badge@main
  with:
    width: '99' height: '20' text_left: 'coverage'
    text_right: '${{ steps.coverage_parser.outputs.percent }}'
    bg_color_right: '${{ steps.coverage_parser.outputs.color }}'
    filename: 'coverage.svg'
- if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  run: |
    mkdir -p badge-upload
    cp "${{ steps.badge_generator.outputs.badge_path }}" badge-upload/coverage.svg
- if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  uses: JamesIves/github-pages-deploy-action@v4
  with:
    branch: badges folder: badge-upload target-folder: .
    git-config-name: "github-actions[bot]"
    git-config-email: "github-actions[bot]@users.noreply.github.com"
    single-commit: true
- if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  run: touch htmlcov/.nojekyll
- if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  uses: JamesIves/github-pages-deploy-action@v4
  with:
    branch: gh-pages folder: htmlcov
```

**After (1 step):**
```yaml
- name: Coverage Report & Deploy
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  id: coverage_report
  uses: ./.github/ci/actions/coverage-report
  with:
    xml_path: coverage.xml
    badge_branch: badges
    pages_branch: gh-pages
```

---

### Task 3: Refactor `example-ci.yml`
**Priority:** P0
**Purpose:** Apply Tasks 1–2 to production workflow.

**Before:** 135 lines, 2 jobs, 17 total steps
**After:** ~50 lines, 2 jobs, 2–3 total steps per job

**`tests-and-coverage` job (before → after):**

| Before | After |
|---|---|
| Checkout | `cmake-build` action |
| Install gcovr | (inside cmake-build) |
| Configure & Build | (inside cmake-build) |
| Run CTest | (inside cmake-build) |
| Generate Coverage Reports | (inside cmake-build) |
| Parse Coverage Metrics | `coverage-report` action |
| Generate Coverage Badge | (inside coverage-report) |
| Isolate Badge for Deploy | (inside coverage-report) |
| Deploy Badge | (inside coverage-report) |
| Deploy Coverage Report to gh-pages | (inside coverage-report) |

**`sanitizers` job (before → after):**

| Before | After |
|---|---|
| Checkout | `cmake-build` action with `sanitizer: address` / `sanitizer: thread` |
| Relax ASLR for ThreadSanitizer | (inside workflow matrix, conditional) |
| Configure & Build | (inside cmake-build) |
| Run CTest | (inside cmake-build) |

---

## P1 — Critical Path: Production `release.yml`

### Task 4: Create `build-and-upload` composite action
**Priority:** P1
**Purpose:** Wraps CMake release build + artifact upload for the release pipeline.
The `build-example` job currently has 5 steps; this reduces it to 2.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `source_dir` | no | `example` | CMake source directory |
| `version` | yes | — | Release version (used for artifact names) |
| `build_tests` | no | `OFF` | Build tests flag |

**Outputs:**
| Name | Description |
|---|---|
| `libplugin_artifact` | Artifact name for libplugin |
| `host_artifact` | Artifact name for host |

**Replaces in `release.yml`:**
- `build-example` job: steps 2–5 (checkout is kept in workflow, then this action)

**Before (4 steps, ~15 lines):**
```yaml
- id: version
  uses: ai-warevo/.github/ci/actions/release-version@main
  with:
    version: ${{ github.event.inputs.version }}
- run: |
    cmake -B build -DCMAKE_BUILD_TYPE=Release -DAW_EXAMPLE_BUILD_TESTS=OFF
    cmake --build build -j"$(nproc)"
- uses: actions/upload-artifact@v4
  with:
    name: libplugin-${{ steps.version.outputs.release_version }}
    path: example/build/libplugin.so
- uses: actions/upload-artifact@v4
  with:
    name: host-${{ steps.version.outputs.release_version }}
    path: example/build/host
```

**After (1 step):**
```yaml
- name: Build & Upload
  id: build
  uses: ./.github/ci/actions/build-and-upload
  with:
    source_dir: example
    version: ${{ steps.version.outputs.release_version }}
```

---

### Task 5: Create `release-publish` composite action
**Priority:** P1
**Purpose:** Combines changelog extraction + artifact download + checksums + verification
into a single release publish step. This is the core of the `release` job.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `tag` | no | `${{ github.ref_name }}` | Release tag |
| `changelog` | no | `CHANGELOG.md` | Changelog path |
| `artifact_patterns` | no | `libplugin-*` | Comma-separated artifact patterns to download |
| `checksums_file` | no | `SHA256SUMS.txt` | Checksums filename |
| `release_name` | no | `${{ tag }}` | GitHub release name |
| `release_files` | no | — | Comma-separated files to attach |
| `what_included` | no | (default text) | Release body "What's Included" section |
| `quick_start` | no | (default text) | Release body "Quick Start" section |

**Outputs:**
| Name | Description |
|---|---|
| `body_path` | Path to generated release body |
| `checksums_file` | Path to generated checksums file |
| `asset_count` | Number of assets |

**Replaces in `release.yml`:**
- `release` job: steps 2–5 (changelog-release, 2× download-artifact, checksums, checksums-verify)
- Step 6 (softprops/gh-release) stays in the workflow but references action outputs

**Before (5 action steps + 1 external, ~20 lines):**
```yaml
- id: changelog
  uses: ai-warevo/.github/ci/actions/changelog-release@main
  with:
    tag: v${{ needs.build-example.outputs.release_version }}
- uses: actions/download-artifact@v4
  with:
    pattern: 'libplugin-*' merge-multiple: true path: .
- uses: actions/download-artifact@v4
  with:
    pattern: 'host-*' merge-multiple: true path: .
- id: checksums_generate
  uses: ai-warevo/.github/ci/actions/checksums@main
  with:
    artifacts_dir: '.' checksums_file: 'SHA256SUMS.txt'
- uses: ai-warevo/.github/ci/actions/checksums-verify@main
  with:
    artifacts_dir: '.' checksums_file: 'SHA256SUMS.txt'
```

**After (1 step):**
```yaml
- name: Release Publish
  id: release_publish
  uses: ./.github/ci/actions/release-publish
  with:
    tag: v${{ needs.build-example.outputs.release_version }}
    artifact_patterns: 'libplugin-*,host-*'
    release_files: 'SHA256SUMS.txt,libplugin-${{ needs.build-example.outputs.release_version }}.so,host-${{ needs.build-example.outputs.release_version }}'
```

---

### Task 6: Create `docker-build-push` composite action
**Priority:** P1
**Purpose:** Wraps docker/setup-buildx + docker/login-action + docker/build-push-action
into a single step. The unused `docker-save` and `docker-push-ghcr` actions suggest
an alternative pattern, but the production workflow uses build-push-action directly.
This action makes the Docker job a single step.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `context` | no | `.` | Docker build context |
| `dockerfile` | no | `Dockerfile` | Dockerfile path |
| `push` | no | `true` | Whether to push |
| `tags` | yes | — | Docker image tags |
| `registry` | no | `ghcr.io` | Container registry |
| `username` | no | `${{ github.actor }}` | Registry username |
| `password` | yes | — | Registry password (GITHUB_TOKEN) |

**Outputs:**
| Name | Description |
|---|---|
| `image` | Full image reference |

**Replaces in `release.yml`:**
- `docker` job: steps 2–4 (setup-buildx, login-action, build-push-action)

**Before (3 steps, ~15 lines):**
```yaml
- uses: docker/setup-buildx-action@v3
- uses: docker/login-action@v3
  with:
    registry: ghcr.io username: ${{ github.actor }} password: ${{ secrets.GITHUB_TOKEN }}
- uses: docker/build-push-action@v5
  with:
    context: ./example file: example/Dockerfile push: true
    tags: ghcr.io/ai-warevo/example:${{ needs.release.outputs.release_version }}
         ghcr.io/ai-warevo/example:latest
```

**After (1 step):**
```yaml
- name: Build & Push Docker
  id: docker
  uses: ./.github/ci/actions/docker-build-push
  with:
    context: ./example
    dockerfile: example/Dockerfile
    push: true
    tags: |
      ghcr.io/ai-warevo/example:${{ needs.release.outputs.release_version }}
      ghcr.io/ai-warevo/example:latest
    password: ${{ secrets.GITHUB_TOKEN }}
```

---

### Task 7: Refactor `release.yml` (production)
**Priority:** P1
**Purpose:** Apply Tasks 4–6 to production release workflow.

**Before:** 156 lines, 3 jobs
**After:** ~60 lines, 3 jobs

---

## P2 — Template `test.yml`

### Task 8: Refactor template `test.yml` badge job
**Priority:** P2
**Purpose:** Replace the inline badge deploy pattern with `coverage-report` action.
The template's badge job currently duplicates the exact pattern from production.

**Before:** 158 lines, 3 jobs
**After:** ~80 lines, 3 jobs

**Changes in `badge` job:**
| Before | After |
|---|---|
| checkout | (keep) |
| coverage-parser | (inside coverage-report) |
| badge generator | (inside coverage-report) |
| mkdir+cp badge | (inside coverage-report) |
| deploy badge | (inside coverage-report) |
| touch+deploy htmlcov | (inside coverage-report) |

---

## P3 — Existing Actions That Need Modification

### Task 9: Update `coverage-parser` — fix env variable quoting
**Priority:** P2
**Issue:** Line 33 uses `$XML_PATH` directly in a Python string without proper quoting.
If the path contains spaces, this will break. Also, the `lcov_path` fallback uses
`grep '^DA:' "$LCOV_PATH"` which is correct, but the awk parsing is fragile for
edge cases.

**Changes:**
- Quote env vars in Python invocation: `tree = ET.parse(os.environ['XML_PATH'])`
- Use `os.environ` instead of shell variable interpolation
- Add error handling for malformed coverage files

---

### Task 10: Update `badge` action — fix variable interpolation
**Priority:** P2
**Issue:** The `gha/badge/action.yml` at `/workspace/gha/badge/action.yml` has inline
`${{ inputs.* }}` directly in the heredoc (lines 65–73), which means GitHub Actions
substitutes them at parse time. The version at
`/workspace/.github/ci/actions/badge/action.yml` correctly uses `env:` variables.
**Decision:** Keep only the `.github/ci/actions/badge` version; remove or deprecate
`gha/badge`.

---

### Task 11: Update `changelog-release` — use English-only docs
**Priority:** P3
**Issue:** All descriptions, comments, and help text are in Russian. Since workflows
and other actions use English, standardize to English for consistency.

**Changes:**
- Translate all `description` fields to English
- Translate inline comments
- Keep the `what-included` and `quick-start` defaults as-is (they're content, not docs)

---

### Task 12: Add README files to all composite actions
**Priority:** P2
**Purpose:** Each action directory needs a `README.md` with:
- Action name and description
- Inputs table
- Outputs table
- Usage example
- Dependencies (e.g., "requires gcovr installed")

**Actions needing READMEs (all 10):**
1. `release-version` — already self-documenting (short), but needs README
2. `changelog-release` — needs README
3. `checksums` — needs README
4. `checksums-verify` — needs README
5. `coverage-parser` — needs README
6. `badge` — needs README
7. `download-artifacts` — mark as UNUSED in README
8. `collect-release-assets` — mark as UNUSED in README
9. `docker-save` — mark as UNUSED in README
10. `docker-push-ghcr` — mark as UNUSED in README

---

## P3 — Template Cleanup

### Task 13: Clean up template `ci.yml`
**Priority:** P3
**Purpose:** The template CI file is a stub with commented-out multi-language examples.
No workflow changes needed, but:
- Standardize all comments to English
- Add a note referencing the composite actions available
- Consider adding a C++ CMake example that uses the new `cmake-build` action

### Task 14: Sync template `release.yml` with production
**Priority:** P3
**Purpose:** The template release.yml is currently an identical copy of production release.yml.
It should be a generic template with placeholder values (org/repo, artifact names, etc.)
that users can adapt.

### Task 15: Mark unused actions clearly
**Priority:** P3
**Purpose:** The following actions are marked UNUSED in the inventory:
- `download-artifacts` — superseded by direct `actions/download-artifact@v4` with pattern
- `collect-release-assets` — superseded by `release-publish` composite
- `docker-save` / `docker-push-ghcr` — superseded by `docker-build-push` composite

**Decision:** Either remove them or keep them with `UNUSED` badges in READMEs and
`deprecated: true` in action.yml `name` field.

---

## P3 — New Composite Actions to Create

### Task 16: Create `deploy-pages` composite action
**Priority:** P3
**Purpose:** Encapsulate the `github-pages-deploy-action@v4` call with standard git config.
Currently repeated in `example-ci.yml` and template `test.yml` with identical git config.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `branch` | yes | — | Target branch |
| `folder` | yes | — | Source folder to deploy |
| `target_folder` | no | `/` | Target folder in deploy branch |
| `single_commit` | no | `true` | Use single-commit mode |
| `clean` | no | `true` | Clean untracked files |

**Reuse in:**
- `example-ci.yml`: badge deploy (branch: badges)
- `example-ci.yml`: htmlcov deploy (branch: gh-pages)
- Template `test.yml`: badge deploy, htmlcov deploy

---

## Commit Plan

### Commit 1: `chore(actions): create cmake-build composite action`
- Create `.github/ci/actions/cmake-build/action.yml`
- Create `.github/ci/actions/cmake-build/README.md`
- **Dependencies:** None

### Commit 2: `chore(actions): create coverage-report composite action`
- Create `.github/ci/actions/coverage-report/action.yml`
- Create `.github/ci/actions/coverage-report/README.md`
- **Dependencies:** Task 1 (cmake-build)

### Commit 3: `fix(actions): quote env vars in coverage-parser`
- Fix Python invocation in `coverage-parser/action.yml`
- **Dependencies:** None (can be done in parallel)

### Commit 4: `refactor(workflows): simplify example-ci.yml`
- Replace inline CMake steps with `cmake-build` action
- Replace inline coverage/badge/deploy steps with `coverage-report` action
- Update `sanitizers` job to use `cmake-build` with sanitizer matrix
- **Dependencies:** Task 1, Task 2

### Commit 5: `chore(actions): create build-and-upload composite action`
- Create `.github/ci/actions/build-and-upload/action.yml`
- Create `.github/ci/actions/build-and-upload/README.md`
- **Dependencies:** None

### Commit 6: `chore(actions): create release-publish composite action`
- Create `.github/ci/actions/release-publish/action.yml`
- Create `.github/ci/actions/release-publish/README.md`
- **Dependencies:** None

### Commit 7: `chore(actions): create docker-build-push composite action`
- Create `.github/ci/actions/docker-build-push/action.yml`
- Create `.github/ci/actions/docker-build-push/README.md`
- **Dependencies:** None

### Commit 8: `chore(actions): create deploy-pages composite action`
- Create `.github/ci/actions/deploy-pages/action.yml`
- Create `.github/ci/actions/deploy-pages/README.md`
- **Dependencies:** None

### Commit 9: `refactor(workflows): simplify production release.yml`
- Replace build steps with `build-and-upload`
- Replace release steps with `release-publish` + softprops/gh-release
- Replace Docker steps with `docker-build-push`
- **Dependencies:** Task 5, Task 6, Task 7

### Commit 10: `refactor(templates): update test.yml with coverage-report`
- Replace badge job inline steps with `coverage-report` action
- Standardize comments to English
- **Dependencies:** Task 2

### Commit 11: `chore(actions): clean up existing actions`
- Translate `changelog-release` docs to English
- Remove/deprecate `gha/badge/action.yml` (duplicate)
- Add `UNUSED` markers to `download-artifacts`, `collect-release-assets`, `docker-save`, `docker-push-ghcr`
- **Dependencies:** None

### Commit 12: `chore(templates): sync and clean template release.yml`
- Convert to generic template with placeholder values
- **Dependencies:** Task 9

### Commit 13: `docs: add README files to all composite actions`
- Create README.md for every action directory
- **Dependencies:** All action creation commits

---

## Summary Statistics

| Metric | Before | After |
|---|---|---|
| Production `example-ci.yml` | 135 lines, 17 steps | ~50 lines, 2–3 steps/job |
| Production `release.yml` | 156 lines, 16 steps | ~60 lines, 3 steps/job |
| Template `test.yml` | 158 lines, 10 steps | ~80 lines, 2–3 steps/job |
| New composite actions | 0 | 4 (`cmake-build`, `coverage-report`, `build-and-upload`, `release-publish`, `docker-build-push`, `deploy-pages`) |
| Modified existing actions | 0 | 2 (`coverage-parser`, `changelog-release`) |
| Deprecated actions | 0 | 4 (`download-artifacts`, `collect-release-assets`, `docker-save`, `docker-push-ghcr`) |
| **Total lines of workflow code removed** | 447 | ~190 (57% reduction) |
