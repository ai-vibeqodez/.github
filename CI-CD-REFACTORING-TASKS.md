# GitHub Actions Composite Actions Refactoring — Prioritized Task List

> **Goal:** Replace inline multi-step patterns in CI/CD workflows with reusable composite actions.
> Make workflows minimal, composable, and easy to maintain.
>
> **Scope:** 2 production workflows, 3 template workflows, 10 existing composite actions.
> **Target:** Create 7 new composite actions, refactor 3 workflows, clean up 1 duplicate file.

---

## Priority Summary

| Priority | Count | What |
|----------|-------|------|
| **P0** | 5 | Create core composite actions (cmake-build, ctest-run, gcovr-report, badge-deploy, coverage-html-deploy) |
| **P1** | 3 | Create pipeline composite actions (docker-build-push, github-pages-deploy), delete duplicate ci/release.yml |
| **P2** | 3 | Refactor production workflows (example-ci.yml, release.yml), update template test.yml |
| **P3** | 4 | Clean up existing actions, update template ci.yml, deprecate unused actions, add READMEs |

---

## P0 — Create Core Composite Actions

These actions replace the most duplicated inline patterns and must exist before any workflow refactoring can begin.

### Task 1: Create `cmake-build` composite action

- **Priority:** P0 (blocks all workflow refactoring)
- **Dependencies:** None
- **Description:** Encapsulate CMake configure + build into a reusable composite action. Replaces 5 inline cmake patterns across `example-ci.yml`, `release.yml`, and both template workflows.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `source_dir` | no | `.` | CMake source directory |
| `build_dir` | no | `build` | Build output directory |
| `build_type` | no | `Debug` | CMAKE_BUILD_TYPE |
| `extra_args` | no | `` | Additional cmake flags (e.g., `-DAW_EXAMPLE_BUILD_TESTS=ON`) |
| `parallel_jobs` | no | `$(nproc)` | cmake --build parallelism |

**Outputs:**
| Name | Description |
|---|---|
| `build_dir` | Resolved build directory path |

**Replaces inline patterns:**
- `example-ci.yml` lines 31–40 (configure + build for tests)
- `example-ci.yml` lines 127–132 (configure + build for sanitizers)
- `release.yml` lines 53–55 (release build)
- `ci.yml` template stub line 64 (C++ stub)
- `test.yml` template stub line 66 (C++ stub)

**File to create:**
- `.github/ci/actions/cmake-build/action.yml`
- `.github/ci/actions/cmake-build/action.yaml` (optional alias)

**Implementation notes:**
- Use `env:` for CC/CXX compiler override (pass through as needed)
- Keep it focused: configure + build only (no ctest, no coverage)
- Use `working-directory` in the workflow, not inside the action, for flexibility

---

### Task 2: Create `ctest-run` composite action

- **Priority:** P0
- **Dependencies:** None (can be created in parallel with Task 1)
- **Description:** Encapsulate CTest execution into a reusable composite action. Replaces 4 inline ctest patterns.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `build_dir` | no | `build` | CTest test directory (`--test-dir`) |
| `config` | no | `Debug` | Test configuration (`-C`) |
| `timeout` | no | `` | ctest `--timeout` value |
| `extra_flags` | no | `` | Additional ctest flags |

**Outputs:** None

**Replaces inline patterns:**
- `example-ci.yml` line 43 (normal test run)
- `example-ci.yml` line 135 (sanitizer test run with timeout)
- `ci.yml` template stub line 129 (C++ test stub)
- `test.yml` template stub line 66 (C++ test stub)

**File to create:**
- `.github/ci/actions/ctest-run/action.yml`

**Implementation notes:**
- Simple wrapper: `ctest --test-dir <build_dir> -C <config> --output-on-failure`
- Pass `--timeout` and other flags via inputs

---

### Task 3: Create `gcovr-report` composite action

- **Priority:** P0
- **Dependencies:** None (can be created in parallel with Tasks 1–2)
- **Description:** Install gcovr + generate coverage reports (XML + HTML) into a single composite action. Replaces 1 complex inline gcovr block in `example-ci.yml`.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `source_root` | no | `.` | gcovr `-r` source root |
| `build_dir` | no | `build` | Build directory for .gcda files |
| `filter` | no | `` | `--filter` pattern (e.g., `example/`) |
| `exclude` | no | `` | `--exclude` pattern (e.g., `build/_deps/*`) |
| `output_dir` | no | `htmlcov` | HTML output directory |
| `xml_path` | no | `coverage.xml` | XML output filename |
| `html_path` | no | `htmlcov/index.html` | HTML output path |
| `install_gcovr` | no | `true` | Whether to run `apt-get install gcovr` |

**Outputs:**
| Name | Description |
|---|---|
| `xml_path` | Absolute path to coverage.xml |
| `html_path` | Absolute path to HTML index |

**Replaces inline patterns:**
- `example-ci.yml` lines 28–29 (apt-get install gcovr)
- `example-ci.yml` lines 45–56 (gcovr generate XML + HTML)

**File to create:**
- `.github/ci/actions/gcovr-report/action.yml`

**Implementation notes:**
- Step 1: `sudo apt-get update && sudo apt-get install -y gcovr` (conditional on `install_gcovr`)
- Step 2: `mkdir -p <output_dir>`
- Step 3: Run gcovr with all filter/exclude flags, generate XML + HTML
- Keep gcovr installation inside the action (not every workflow needs it pre-installed)

---

### Task 4: Create `badge-deploy` composite action

- **Priority:** P0
- **Dependencies:** None (can be created in parallel with Tasks 1–3)
- **Description:** Isolate badge SVG + deploy to badges branch via `github-pages-deploy-action@v4`. Replaces 2 identical inline badge deploy blocks.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `badge_path` | yes | — | Path to the badge SVG file |
| `badge_filename` | no | `coverage.svg` | Filename in deploy folder |
| `branch` | no | `badges` | Target branch for badge deploy |

**Outputs:** None

**Replaces inline patterns:**
- `example-ci.yml` lines 77–92 (mkdir + cp + github-pages-deploy-action for badge)
- `test.yml` lines 133–146 (identical badge deploy pattern)

**File to create:**
- `.github/ci/actions/badge-deploy/action.yml`

**Implementation notes:**
- Step 1: `mkdir -p badge-upload && cp <badge_path> badge-upload/<badge_filename>`
- Step 2: `uses: JamesIves/github-pages-deploy-action@v4` with `branch`, `folder: badge-upload`, `target-folder: .`, `git-config-name`, `git-config-email`, `single-commit: true`
- The `if` condition (`github.event_name == 'push' && github.ref == 'refs/heads/main'`) stays in the workflow, not the action

---

### Task 5: Create `coverage-html-deploy` composite action

- **Priority:** P0
- **Dependencies:** None (can be created in parallel with Tasks 1–4)
- **Description:** Touch `.nojekyll` + deploy coverage HTML to gh-pages branch. Replaces 2 identical inline coverage deploy blocks.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `folder` | no | `htmlcov` | Source folder to deploy |
| `branch` | no | `gh-pages` | Target branch |
| `nojekyll` | no | `true` | Whether to create `.nojekyll` |

**Outputs:** None

**Replaces inline patterns:**
- `example-ci.yml` lines 94–105 (touch .nojekyll + github-pages-deploy-action for coverage)
- `test.yml` lines 148–158 (identical coverage deploy pattern)

**File to create:**
- `.github/ci/actions/coverage-html-deploy/action.yml`

**Implementation notes:**
- Step 1: `touch <folder>/.nojekyll` (conditional on `nojekyll == true`)
- Step 2: `uses: JamesIves/github-pages-deploy-action@v4` with `branch`, `folder`, `git-config-name`, `git-config-email`, `single-commit: true`
- The `if` condition stays in the workflow

---

## P1 — Create Pipeline Composite Actions & Clean Up Dead Code

These actions replace larger multi-step pipelines and remove maintenance burden.

### Task 6: Create `docker-build-push` composite action

- **Priority:** P1
- **Dependencies:** None
- **Description:** Wrap the Docker Buildx + Login + Build-Push pipeline into a single step. Replaces 2 identical Docker pipeline blocks (production release.yml and duplicate ci/release.yml).

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `context` | no | `.` | Docker build context |
| `dockerfile` | no | `Dockerfile` | Dockerfile path |
| `registry` | no | `ghcr.io` | Container registry |
| `image_name` | yes | — | Image name (e.g., `ghcr.io/org/repo`) |
| `tags` | yes | — | Docker image tags (multiline) |
| `push` | no | `true` | Whether to push to registry |
| `username` | no | `${{ github.actor }}` | Registry username |
| `password` | yes | — | Registry password (GITHUB_TOKEN) |

**Outputs:**
| Name | Description |
|---|---|
| `image` | Full image reference |

**Replaces inline patterns:**
- `release.yml` lines 138–155 (setup-buildx + login-action + build-push-action)
- `ci/release.yml` lines 138–156 (exact duplicate)

**File to create:**
- `.github/ci/actions/docker-build-push/action.yml`

**Implementation notes:**
- Step 1: `uses: docker/setup-buildx-action@v3`
- Step 2: `uses: docker/login-action@v3` with registry, username, password
- Step 3: `uses: docker/build-push-action@v5` with context, file, push, tags
- Keep it as 3 sequential steps (no benefit to collapsing further)

---

### Task 7: Create `github-pages-deploy` composite action

- **Priority:** P1
- **Dependencies:** None
- **Description:** Reusable wrapper around `github-pages-deploy-action@v4` with standard git config baked in. Replaces 4 identical deploy parameter blocks across workflows.

**Inputs:**
| Name | Required | Default | Description |
|---|---|---|---|
| `branch` | yes | — | Target branch |
| `folder` | yes | — | Source folder to deploy |
| `target_folder` | no | `/` | Target folder in deploy branch |
| `single_commit` | no | `true` | Use single-commit mode |
| `clean` | no | `true` | Clean untracked files before deploy |

**Outputs:** None

**Replaces inline patterns:**
- `example-ci.yml`: 2 calls (badge deploy + coverage deploy)
- `test.yml`: 2 calls (badge deploy + coverage deploy)
- Total: 4 identical invocations with same git config params

**File to create:**
- `.github/ci/actions/github-pages-deploy/action.yml`

**Implementation notes:**
- Single step: `uses: JamesIves/github-pages-deploy-action@v4`
- Bake in `git-config-name: "github-actions[bot]"` and `git-config-email: "github-actions[bot]@users.noreply.github.com"`
- This action is a thin wrapper — consider whether `badge-deploy` and `coverage-html-deploy` (Tasks 4–5) already make it redundant. If so, keep it only as a general-purpose fallback.

**Decision note:** Tasks 4–5 (`badge-deploy`, `coverage-html-deploy`) are more specific and already handle the deploy action internally. Task 7 (`github-pages-deploy`) is a general-purpose wrapper. **Recommendation:** Create Task 7 as a general-purpose deploy helper; Tasks 4–5 can optionally delegate to it internally.

---

### Task 8: Delete duplicate `ci/.github/workflows/release.yml`

- **Priority:** P1
- **Dependencies:** None (can be done immediately, no risk)
- **Description:** Remove the exact duplicate of the production `release.yml`. It is a character-for-character copy (156 lines, identical content) serving no purpose.

**File to delete:**
- `ci/.github/workflows/release.yml`

**Impact:** Removes 156 lines of dead code. No workflow depends on this file.

---

## P2 — Refactor Workflows to Use New Composites

These tasks apply the new composite actions to actual workflow files. They depend on the actions being created first.

### Task 9: Refactor production `example-ci.yml`

- **Priority:** P2
- **Dependencies:** Tasks 1, 2, 3, 4, 5 (all P0 composites must exist)
- **Description:** Replace inline CMake, CTest, gcovr, badge deploy, and coverage deploy steps with composite action calls.

**Before:** 135 lines, 2 jobs, 17 total steps
**After:** ~55 lines, 2 jobs, 2–3 total steps per job

**`tests-and-coverage` job changes:**

| Before (step) | After |
|---|---|
| Checkout (line 25–26) | `cmake-build` action (includes checkout internally? No — keep checkout in workflow) |
| Install gcovr (line 28–29) | (absorbed into `gcovr-report`) |
| Configure & Build (lines 31–40) | `uses: ./.github/ci/actions/cmake-build` with `source_dir: example`, `build_type: Debug`, `extra_args: -DAW_EXAMPLE_BUILD_TESTS=ON -DAW_EXAMPLE_ENABLE_COVERAGE=ON` |
| Run CTest (line 43) | `uses: ./.github/ci/actions/ctest-run` with `build_dir: build`, `config: Debug` |
| Generate Coverage Reports (lines 45–56) | `uses: ./.github/ci/actions/gcovr-report` with `source_root: .`, `build_dir: build`, `filter: example/`, `exclude: build/_deps/*` |
| Parse Coverage Metrics (lines 58–63) | Keep as-is (already uses `coverage-parser` action) |
| Generate Coverage Badge (lines 65–75) | Keep as-is (already uses `badge` action) |
| Isolate Badge for Deploy (lines 77–81) | `uses: ./.github/ci/actions/badge-deploy` with `badge_path: ${{ steps.badge_generator.outputs.badge_path }}` |
| Deploy Badge (lines 83–92) | (absorbed into `badge-deploy`) |
| Deploy Coverage Report to gh-pages (lines 94–105) | `uses: ./.github/ci/actions/coverage-html-deploy` with `folder: htmlcov` |

**`sanitizers` job changes:**

| Before (step) | After |
|---|---|
| Checkout (line 116–117) | Keep checkout in workflow |
| Relax ASLR (lines 119–121) | Keep as-is (sanitizer-specific) |
| Configure & Build (lines 123–132) | `uses: ./.github/ci/actions/cmake-build` with `build_type: RelWithDebInfo`, `extra_args: -DAW_EXAMPLE_BUILD_TESTS=ON -DAW_EXAMPLE_SANITIZE=${{ matrix.sanitizer }}`, `env: CC/CXX` |
| Run CTest (line 134–135) | `uses: ./.github/ci/actions/ctest-run` with `build_dir: build`, `timeout: 120` |

**Note on checkout:** Keep `actions/checkout@v4` in the workflow (not inside composites) since the workflow controls when/how checkout happens. The composites assume checkout is done.

---

### Task 10: Refactor production `release.yml`

- **Priority:** P2
- **Dependencies:** Tasks 6 (docker-build-push), 7 (github-pages-deploy — optional, or inline the deploy params)
- **Description:** Replace inline Docker pipeline with `docker-build-push` composite. Replace inline `download-artifact` calls with `download-artifacts` composite.

**Before:** 156 lines, 3 jobs
**After:** ~90 lines, 3 jobs

**`build-example` job changes:**

| Before | After |
|---|---|
| Lines 51–55: cmake build | `uses: ./.github/ci/actions/cmake-build` with `build_type: Release`, `extra_args: -DAW_EXAMPLE_BUILD_TESTS=OFF` |
| Lines 57–67: 2× upload-artifact | Keep as-is (artifact upload is workflow-specific, not a good composite candidate) |

**`release` job changes:**

| Before | After |
|---|---|
| Lines 89–101: 2× download-artifact | `uses: ./.github/ci/actions/download-artifacts` with `pattern: libplugin-*` then again for `host-*` |

**`docker` job changes:**

| Before | After |
|---|---|
| Lines 138–155: 3-step Docker pipeline | `uses: ./.github/ci/actions/docker-build-push` with `context: ./example`, `dockerfile: example/Dockerfile`, `image_name: ghcr.io/ai-warevo/example`, `tags`, `password: ${{ secrets.GITHUB_TOKEN }}` |

---

### Task 11: Refactor template `test.yml`

- **Priority:** P2
- **Dependencies:** Tasks 4, 5 (badge-deploy, coverage-html-deploy)
- **Description:** Replace inline badge deploy and coverage HTML deploy patterns with composite actions. Update C++ stub to reference `cmake-build` and `ctest-run`.

**Before:** 158 lines
**After:** ~80 lines

**`test` job changes:**
- Line 66 (C++ stub): Replace `mkdir build && cd build && cmake .. && cmake --build . && ctest --output-on-failure` with a comment referencing `cmake-build` + `ctest-run` composites

**`badge` job changes:**
- Lines 133–137 (mkdir + cp badge): Replace with `uses: ./.github/ci/actions/badge-deploy`
- Lines 138–146 (deploy badge): (absorbed into badge-deploy)

**`coverage` job changes:**
- Lines 148–158 (touch .nojekyll + deploy): Replace with `uses: ./.github/ci/actions/coverage-html-deploy`

---

## P3 — Clean Up Existing Actions & Add Documentation

These are polish tasks: improve existing actions, update templates, deprecate unused code, add documentation.

### Task 12: Fix `coverage-parser` — quote env variables in Python invocation

- **Priority:** P3
- **Dependencies:** None (can be done in parallel with any task)
- **Description:** The Python invocation on line 33 of `coverage-parser/action.yml` uses `ET.parse('$XML_PATH')` which embeds the shell variable directly in the Python string. If the path contains spaces, this breaks.

**Current (fragile):**
```python
PERCENTAGE=$(python3 -c "import xml.etree.ElementTree as ET; tree = ET.parse('$XML_PATH'); ...")
```

**Fixed:**
```bash
python3 -c "
import xml.etree.ElementTree as ET
import os
tree = ET.parse(os.environ['XML_PATH'])
root = tree.getroot()
print(int(float(root.attrib['line-rate']) * 100))
"
```

**File to modify:** `.github/ci/actions/coverage-parser/action.yml`

---

### Task 13: Translate `changelog-release` — English documentation

- **Priority:** P3
- **Dependencies:** None (can be done in parallel with any task)
- **Description:** All `description` fields and comments in `changelog-release/action.yml` are in Russian. Standardize to English for consistency with other actions.

**Changes:**
- Translate `description` field: "Извлекает release notes из CHANGELOG.md по тегу и генерирует release body" → "Extracts release notes from CHANGELOG.md by tag and generates a release body"
- Translate all input descriptions to English
- Translate inline comments in the bash script
- Keep `what-included` and `quick-start` defaults as-is (they are content, not documentation)

**File to modify:** `.github/ci/actions/changelog-release/action.yml`

---

### Task 14: Translate `badge` action — English documentation

- **Priority:** P3
- **Dependencies:** None
- **Description:** The `badge/action.yml` has Russian descriptions. Standardize to English.

**Changes:**
- Translate `description`: "Генерирует кастомные SVG бейджики" → "Generates custom SVG badges"
- Translate all input descriptions

**File to modify:** `.github/ci/actions/badge/action.yml`

---

### Task 15: Update template `ci.yml` — reference composite actions

- **Priority:** P3
- **Dependencies:** Tasks 1, 2 (cmake-build, ctest-run must exist)
- **Description:** The C++ stub in `ci.yml` (lines 61–64) shows inline cmake commands. Update the comment to reference the new composite actions.

**Current stub (lines 61–64):**
```yaml
# ── C++ (CMake) ──
# - name: Install dependencies
#   run: sudo apt-get update && sudo apt-get install -y cmake build-essential
# - run: mkdir build && cd build && cmake .. && cmake --build .
```

**Updated stub:**
```yaml
# ── C++ (CMake) ──
# - name: Install dependencies
#   run: sudo apt-get update && sudo apt-get install -y cmake build-essential gcovr ctest
# - uses: ./.github/ci/actions/cmake-build
#   with:
#     source_dir: .
#     build_type: Release
# - uses: ./.github/ci/actions/ctest-run
#   with:
#     build_dir: build
```

**File to modify:** `ci/.github/workflows/ci.yml`

**Also translate:** All Russian comments in the file header to English (lines 1–10).

---

### Task 16: Mark unused actions as deprecated

- **Priority:** P3
- **Dependencies:** None
- **Description:** The following actions are never used and are superseded by new composites or direct action calls. Mark them clearly.

| Action | Superseded By | Action |
|---|---|---|
| `docker-save` | `docker-build-push` (new P1 action) | Add `deprecated: true` comment in action.yml, add UNUSED note in description |
| `docker-push-ghcr` | `docker-build-push` (new P1 action) | Same treatment |
| `download-artifacts` | Direct `actions/download-artifact@v4` with `pattern` + `merge-multiple` | Add UNUSED note — the direct action is simpler and already used |
| `collect-release-assets` | Inline `download-artifact` + `checksums` + `checksums-verify` | Add UNUSED note — the modular approach is preferred for debugging |

**Files to modify:**
- `.github/ci/actions/docker-save/action.yml`
- `.github/ci/actions/docker-push-ghcr/action.yml`
- `.github/ci/actions/download-artifacts/action.yml`
- `.github/ci/actions/collect-release-assets/action.yml`

**Note:** Do NOT delete these — they may be useful for specific use cases. Just mark them clearly.

---

### Task 17: Add README.md to all composite actions

- **Priority:** P3
- **Dependencies:** All action creation tasks (Tasks 1–7) must be complete
- **Description:** Every composite action directory needs a `README.md` with:
  - Action name and one-line description
  - Inputs table (name, required, default, description)
  - Outputs table (name, description)
  - Usage example (YAML snippet)
  - Dependencies (e.g., "requires gcovr installed on the runner")

**Actions needing READMEs (all 17 total):**

| # | Action | Status |
|---|--------|--------|
| 1 | `cmake-build` | NEW — create README |
| 2 | `ctest-run` | NEW — create README |
| 3 | `gcovr-report` | NEW — create README |
| 4 | `badge-deploy` | NEW — create README |
| 5 | `coverage-html-deploy` | NEW — create README |
| 6 | `docker-build-push` | NEW — create README |
| 7 | `github-pages-deploy` | NEW — create README |
| 8 | `release-version` | EXISTING — create README |
| 9 | `changelog-release` | EXISTING — create README |
| 10 | `checksums` | EXISTING — create README |
| 11 | `checksums-verify` | EXISTING — create README |
| 12 | `coverage-parser` | EXISTING — create README |
| 13 | `badge` | EXISTING — create README |
| 14 | `download-artifacts` | EXISTING — create README (mark UNUSED) |
| 15 | `collect-release-assets` | EXISTING — create README (mark UNUSED) |
| 16 | `docker-save` | EXISTING — create README (mark UNUSED) |
| 17 | `docker-push-ghcr` | EXISTING — create README (mark UNUSED) |

---

## Commit Plan

Organize work into logical, reviewable commits. Each commit should be self-contained and buildable.

### Commit 1: `chore(actions): create cmake-build composite action`
- Create `.github/ci/actions/cmake-build/action.yml`
- Create `.github/ci/actions/cmake-build/README.md`
- **Dependencies:** None
- **Impact:** New reusable action, no workflow changes yet

### Commit 2: `chore(actions): create ctest-run composite action`
- Create `.github/ci/actions/ctest-run/action.yml`
- Create `.github/ci/actions/ctest-run/README.md`
- **Dependencies:** None (parallel with Commit 1)

### Commit 3: `chore(actions): create gcovr-report composite action`
- Create `.github/ci/actions/gcovr-report/action.yml`
- Create `.github/ci/actions/gcovr-report/README.md`
- **Dependencies:** None (parallel with Commits 1–2)

### Commit 4: `chore(actions): create badge-deploy composite action`
- Create `.github/ci/actions/badge-deploy/action.yml`
- Create `.github/ci/actions/badge-deploy/README.md`
- **Dependencies:** None (parallel with Commits 1–3)

### Commit 5: `chore(actions): create coverage-html-deploy composite action`
- Create `.github/ci/actions/coverage-html-deploy/action.yml`
- Create `.github/ci/actions/coverage-html-deploy/README.md`
- **Dependencies:** None (parallel with Commits 1–4)

### Commit 6: `chore(actions): create docker-build-push composite action`
- Create `.github/ci/actions/docker-build-push/action.yml`
- Create `.github/ci/actions/docker-build-push/README.md`
- **Dependencies:** None (parallel with Commits 1–5)

### Commit 7: `chore(actions): create github-pages-deploy composite action`
- Create `.github/ci/actions/github-pages-deploy/action.yml`
- Create `.github/ci/actions/github-pages-deploy/README.md`
- **Dependencies:** None (parallel with Commits 1–6)

### Commit 8: `chore(ci): delete duplicate ci/release.yml`
- Delete `ci/.github/workflows/release.yml`
- **Dependencies:** None
- **Impact:** Removes 156 lines of dead code

### Commit 9: `fix(actions): quote env vars in coverage-parser`
- Fix Python invocation in `.github/ci/actions/coverage-parser/action.yml`
- **Dependencies:** None (can be done in parallel with any commit)

### Commit 10: `refactor(workflows): simplify example-ci.yml`
- Replace inline cmake/ctest/gcovr/badge/coverage steps with composite actions
- Update sanitizers job to use `cmake-build` + `ctest-run`
- **Dependencies:** Commits 1–5 (cmake-build, ctest-run, gcovr-report, badge-deploy, coverage-html-deploy)
- **Impact:** 135 lines → ~55 lines

### Commit 11: `refactor(workflows): simplify release.yml`
- Replace Docker pipeline with `docker-build-push`
- Replace inline download-artifact calls with `download-artifacts` composite
- **Dependencies:** Commits 6–7 (docker-build-push, github-pages-deploy)
- **Impact:** 156 lines → ~90 lines

### Commit 12: `refactor(templates): update test.yml with composites`
- Replace badge deploy inline steps with `badge-deploy`
- Replace coverage deploy inline steps with `coverage-html-deploy`
- Update C++ stub comments to reference `cmake-build` + `ctest-run`
- **Dependencies:** Commits 4–5 (badge-deploy, coverage-html-deploy)

### Commit 13: `refactor(templates): update ci.yml C++ stub`
- Update C++ stub to reference `cmake-build` + `ctest-run` composites
- Translate Russian comments to English
- **Dependencies:** Commits 1–2 (cmake-build, ctest-run)

### Commit 14: `chore(actions): translate changelog-release docs to English`
- Translate all `description` fields and comments in `changelog-release/action.yml`
- **Dependencies:** None

### Commit 15: `chore(actions): translate badge docs to English`
- Translate all `description` fields in `badge/action.yml`
- **Dependencies:** None

### Commit 16: `chore(actions): mark unused actions as deprecated`
- Add UNUSED/deprecated markers to `docker-save`, `docker-push-ghcr`, `download-artifacts`, `collect-release-assets`
- **Dependencies:** None

### Commit 17: `docs: add README.md to all composite actions`
- Create README.md for every action directory (17 total)
- **Dependencies:** All action creation commits (Commits 1–7)

---

## Summary Statistics

| Metric | Before | After |
|--------|--------|-------|
| Production `example-ci.yml` | 135 lines, 17 steps | ~55 lines, ~4 steps |
| Production `release.yml` | 156 lines, 16 steps | ~90 lines, ~6 steps |
| Template `test.yml` | 158 lines | ~80 lines |
| Duplicate `ci/release.yml` | 156 lines (DELETED) | 0 lines |
| New composite actions | 0 | 7 (`cmake-build`, `ctest-run`, `gcovr-report`, `badge-deploy`, `coverage-html-deploy`, `docker-build-push`, `github-pages-deploy`) |
| Modified existing actions | 0 | 3 (`coverage-parser`, `changelog-release`, `badge`) |
| Deprecated actions | 0 | 4 (`docker-save`, `docker-push-ghcr`, `download-artifacts`, `collect-release-assets`) |
| README files added | 0 | 17 (one per action) |
| **Total workflow lines removed** | 447 | ~240 (54% reduction in workflow code) |
| **Total commits** | — | 17 |

---

## Execution Order (Critical Path)

```
Commit 1  ─┐
Commit 2  ─┤
Commit 3  ─┼─┐
Commit 4  ─┤ │    Commit 9 (coverage-parser fix — independent)
Commit 5  ─┤ │    Commit 8 (delete duplicate — independent)
Commit 6  ─┤ │    Commit 14 (changelog-release translate — independent)
Commit 7  ─┘ │    Commit 15 (badge translate — independent)
             │    Commit 16 (deprecate unused — independent)
Commit 9  ───┘
             │
Commit 10 ───┘ (refactor example-ci.yml — needs Commits 1–5)
Commit 11 ───┘ (refactor release.yml — needs Commits 6–7)
Commit 12 ───┘ (refactor test.yml — needs Commits 4–5)
Commit 13 ───┘ (refactor ci.yml — needs Commits 1–2)
             │
Commit 17 ───┘ (READMEs — needs all action creation commits)
```

**Parallelizable groups:**
- **Group A (all independent):** Commits 1, 2, 3, 4, 5, 6, 7, 8, 9, 14, 15, 16
- **Group B (depends on A):** Commits 10, 11, 12, 13
- **Group C (depends on all):** Commit 17

**Estimated effort:** ~2–3 hours total (action creation: 1h, workflow refactoring: 1h, cleanup/docs: 30min)
