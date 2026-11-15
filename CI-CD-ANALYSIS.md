# CI/CD Composite Actions & Workflows — Structured Analysis

**Date:** 2026-11-15  
**Scope:** `/workspace/.github/` — all workflows and composite actions

---

## Inventory

### Production Workflows (2)
| File | Lines | Description |
|------|-------|-------------|
| `.github/.github/workflows/example-ci.yml` | 135 | C++ CI: tests, coverage, badge deploy, sanitizers |
| `.github/.github/workflows/release.yml` | 156 | Release: build, changelog, checksums, Docker |

### Template Workflows (3)
| File | Lines | Description |
|------|-------|-------------|
| `ci/.github/workflows/ci.yml` | 132 | Universal CI template (language stubs, placeholder steps) |
| `ci/.github/workflows/test.yml` | 158 | Universal test template (matrix, coverage, badge deploy) |
| `ci/.github/workflows/release.yml` | 156 | **Exact copy** of production `release.yml` |

### Composite Actions (10)
| Action | Used? | Description |
|--------|-------|-------------|
| `release-version` | ✅ Yes | Version resolver from tag / dispatch / run_number |
| `changelog-release` | ✅ Yes | Extracts CHANGELOG.md release notes by tag |
| `checksums` | ✅ Yes | Generates SHA256SUMS.txt |
| `checksums-verify` | ✅ Yes | Verifies SHA256 checksums |
| `coverage-parser` | ✅ Yes | Parses coverage.xml/lcov → percent + color |
| `badge` | ✅ Yes | Generates SVG badge |
| `download-artifacts` | ❌ Never | Wrapper around `actions/download-artifact@v4` with pattern+merge |
| `collect-release-assets` | ❌ Never | Downloads artifacts, organizes by version, generates checksums |
| `docker-save` | ❌ Never | `docker save` → `upload-artifact` |
| `docker-push-ghcr` | ❌ Never | `docker load` → `docker push` to GHCR |

---

## 1. Gap Analysis — Composite Actions That Should Be Created

### HIGH PRIORITY

#### a) `cmake-build` — Configure + Build
**Where it appears (inline):**
- `example-ci.yml` line 31–40: `cmake -S example -B build ... && cmake --build build --parallel`
- `example-ci.yml` line 127–132: same pattern with sanitizer flags
- `release.yml` line 53–55: `cmake -B build ... && cmake --build build`
- `ci.yml` template stub line 64
- `test.yml` template stub line 66

**Current inline pattern (repeated ~5 times across files):**
```yaml
run: |
  cmake -S example -B build \
    -DCMAKE_BUILD_TYPE=Debug \
    -DAW_EXAMPLE_BUILD_TESTS=ON \
    -DAW_EXAMPLE_ENABLE_COVERAGE=ON
  cmake --build build --parallel
```

**Proposed action inputs:** `source_dir`, `build_dir`, `build_type`, `extra_args`, `env (CC/CXX)`

---

#### b) `ctest-run` — Run CTest
**Where it appears (inline):**
- `example-ci.yml` line 43: `ctest --test-dir build -C Debug --output-on-failure`
- `example-ci.yml` line 135: `ctest --test-dir build --output-on-failure --timeout 120`
- `ci.yml` template stub line 129
- `test.yml` template stub line 66

**Current inline pattern (repeated ~4 times):**
```yaml
run: ctest --test-dir build -C Debug --output-on-failure
```

**Proposed action inputs:** `build_dir`, `config`, `flags` (output-on-failure, timeout)

---

#### c) `gcovr-report` — Install + Generate Coverage
**Where it appears (inline):**
- `example-ci.yml` lines 28–29: `sudo apt-get install -y gcovr`
- `example-ci.yml` lines 45–56: `gcovr -r build/ ... --xml coverage.xml --html-details htmlcov/index.html`

**Current inline pattern (unique to example-ci but complex enough to warrant extraction):**
```yaml
- run: sudo apt-get update && sudo apt-get install -y gcovr
- run: |
    mkdir -p htmlcov
    gcovr -r build/ \
      --gcov-ignore-errors=no_working_dir_found \
      --filter 'example/' \
      --exclude 'build/_deps/*' \
      --exclude-unreachable-branches \
      --exclude-throw-branches \
      --print-summary \
      --xml coverage.xml \
      --html-details htmlcov/index.html
```

**Proposed action inputs:** `source_root`, `build_dir`, `filter`, `exclude`, `output_dir`, `xml_path`, `html_path`

---

#### d) `badge-deploy` — Badge isolation + deploy to badges branch
**Where it appears (inline, duplicated):**
- `example-ci.yml` lines 77–92: `mkdir -p badge-upload && cp badge.svg badge-upload/` + `github-pages-deploy-action@v4`
- `test.yml` lines 133–146: identical `mkdir` + `cp` + `github-pages-deploy-action@v4`

**Current inline pattern (exact duplicate in 2 files):**
```yaml
- name: Isolate Badge for Deploy / Deploy Badge
  run: |
    mkdir -p badge-upload
    cp "${{ steps.badge_generator.outputs.badge_path }}" badge-upload/coverage.svg
- name: Deploy Badge
  uses: JamesIves/github-pages-deploy-action@v4
  with:
    branch: badges
    folder: badge-upload
    target-folder: .
    git-config-name: "github-actions[bot]"
    git-config-email: "github-actions[bot]@users.noreply.github.com"
    single-commit: true
```

**Proposed action inputs:** `badge_path`, `badge_filename`, `branch` (default: badges)

---

#### e) `coverage-html-deploy` — Coverage HTML deploy to gh-pages
**Where it appears (inline, duplicated):**
- `example-ci.yml` lines 94–105: `touch htmlcov/.nojekyll` + `github-pages-deploy-action@v4`
- `test.yml` lines 148–158: identical pattern with `if: hashFiles('htmlcov/index.html') != ''`

**Current inline pattern (duplicate in 2 files):**
```yaml
- name: Deploy Coverage Report to gh-pages
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  run: touch htmlcov/.nojekyll
- name: Deploy Coverage HTML
  uses: JamesIves/github-pages-deploy-action@v4
  with:
    branch: gh-pages
    folder: htmlcov
```

**Proposed action inputs:** `folder` (default: htmlcov), `branch` (default: gh-pages), `nojekyll` (default: true)

---

#### f) `github-pages-deploy` — Reusable Pages deploy wrapper
**Where it appears (inline, duplicated):**
- `example-ci.yml`: 2 calls (badge deploy + coverage deploy)
- `test.yml`: 2 calls (badge deploy + coverage deploy)
- Total: 4 identical invocations with same `git-config-name`, `git-config-email`, `single-commit` params

**Current inline pattern (4 identical calls):**
```yaml
uses: JamesIves/github-pages-deploy-action@v4
with:
  branch: <branch>
  folder: <folder>
  target-folder: .
  git-config-name: "github-actions[bot]"
  git-config-email: "github-actions[bot]@users.noreply.github.com"
  single-commit: true
```

**Proposed action inputs:** `branch`, `folder`, `target-folder`, `branch_name`, `branch_email`

---

### MEDIUM PRIORITY

#### g) `docker-build-push` — Docker Buildx + Login + Build-Push pipeline
**Where it appears (inline):**
- `release.yml` lines 138–155: `docker/setup-buildx-action@v3` + `docker/login-action@v3` + `docker/build-push-action@v5`
- `ci/release.yml` lines 138–156: exact same 3-step pipeline

**Current inline pattern (duplicate in 2 files):**
```yaml
- uses: docker/setup-buildx-action@v3
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
- uses: docker/build-push-action@v5
  with:
    context: ./example
    file: example/Dockerfile
    push: true
    tags: |
      ghcr.io/ai-warevo/example:${{ needs.release.outputs.release_version }}
      ghcr.io/ai-warevo/example:latest
```

**Note:** `docker-save` and `docker-push-ghcr` exist but implement a DIFFERENT pattern (`docker save → artifact → docker load → push`). This new composite would replace the direct `docker/build-push-action` pattern.

**Proposed action inputs:** `context`, `dockerfile`, `registry`, `image_name`, `tags`, `push` (default: true), `build_args`

---

## 2. Refactoring Opportunities — Workflow Simplifications

### Production `example-ci.yml` (135 lines → target: ~60 lines)

| Current | Refactored |
|---------|-----------|
| Lines 28–29: `apt-get install gcovr` | → `uses: ./.github/ci/actions/gcovr-report` |
| Lines 31–40: inline cmake configure+build | → `uses: ./.github/ci/actions/cmake-build` |
| Line 43: inline `ctest` | → `uses: ./.github/ci/actions/ctest-run` |
| Lines 45–56: inline gcovr generate | → `uses: ./.github/ci/actions/gcovr-report` |
| Lines 77–81: mkdir+cp badge | → `uses: ./.github/ci/actions/badge-deploy` |
| Lines 83–92: badge deploy action | → (merged into badge-deploy) |
| Lines 94–97: touch .nojekyll | → `uses: ./.github/ci/actions/coverage-html-deploy` |
| Lines 99–105: coverage deploy action | → (merged into coverage-html-deploy) |

### Production `release.yml` (156 lines → target: ~100 lines)

| Current | Refactored |
|---------|-----------|
| Lines 138–155: Docker Buildx + Login + Build-Push | → `uses: ./.github/ci/actions/docker-build-push` |
| Lines 89–101: Two separate `download-artifact` calls | → `uses: ./.github/ci/actions/download-artifacts` (existing, unused) |

### Template `test.yml` (158 lines → target: ~90 lines)

| Current | Refactored |
|---------|-----------|
| Lines 133–146: badge deploy inline | → `uses: ./.github/ci/actions/badge-deploy` |
| Lines 148–158: coverage HTML deploy inline | → `uses: ./.github/ci/actions/coverage-html-deploy` |

### Template `ci.yml` (132 lines)
- Language stubs are fine as-is (template purpose).
- C++ stub on line 64 (`mkdir build && cd build && cmake .. && cmake --build .`) should reference `cmake-build` composite.

---

## 3. Action Consolidation — Existing Actions That Could Be Merged or Replaced

### a) `download-artifacts` (unused) — should replace inline `download-artifact` calls
**Current state:** Exists but unused. Both `release.yml` and `ci/release.yml` use two separate `actions/download-artifact@v4` calls inline.

**Refactored release.yml release job:**
```yaml
- name: Download all release artifacts
  uses: ai-warevo/.github/ci/actions/download-artifacts@main
  with:
    pattern: 'libplugin-*'
    merge-multiple: true
    path: .

- name: Download host artifact
  uses: ai-warevo/.github/ci/actions/download-artifacts@main
  with:
    pattern: 'host-*'
    merge-multiple: true
    path: .
```

This reduces 12 lines of inline action calls to 8 lines using the composite.

---

### b) `collect-release-assets` (unused) — can replace `download-artifacts` + `checksums` + organize pattern
**Current state:** Exists but unused. It combines artifact download, version-based organization, and checksum generation in one step.

**When to use it:** If the release job needs artifacts from multiple build jobs organized by version, `collect-release-assets` replaces:
- 2× `download-artifact` calls
- 1× `checksums` call
- 1× `checksums-verify` call
- 1× manual `mv` step for version organization

**Current release.yml uses separate steps** (download → checksum → verify → release). `collect-release-assets` would collapse this to 1 step but loses per-step granularity. **Recommendation:** Keep separate for now (better debugging), but `collect-release-assets` is a valid convenience option for simpler projects.

---

### c) `docker-save` + `docker-push-ghcr` (both unused) — consider deprecation
**Current state:** Both exist but neither is used. The production `release.yml` uses the direct `docker/build-push-action@v5` pattern instead.

**Analysis:**
- `docker-save` + `docker-push-ghcr` implement a two-phase pattern: build → save to artifact → load from artifact → push. This is useful when the build job and push job are on **different runners** (e.g., self-hosted build → GitHub-hosted push) or when you need to transfer images across workflow runs.
- The direct `docker/build-push-action` pattern (currently used) builds and pushes in one job, which is simpler and faster.

**Recommendation:** 
- **Deprecate** `docker-save` and `docker-push-ghcr` unless there's a documented use case requiring the artifact-transfer pattern.
- Create `docker-build-push` (see gap analysis) to replace the inline Docker pipeline.

---

### d) `checksums` + `checksums-verify` — keep as-is
Both are used correctly in production workflows and serve distinct purposes (generate vs verify). No consolidation needed.

---

## 4. Template Cleanup

### a) `ci/release.yml` — DELETE (exact duplicate)
This file is an **exact character-for-character copy** of `.github/.github/workflows/release.yml` (156 lines, identical content). It serves no purpose and creates maintenance burden.

**Action:** Remove `/workspace/.github/ci/.github/workflows/release.yml`. If it was intended as a template for other projects, rename it to `release-template.yml` and add instructions.

---

### b) `ci/test.yml` — needs badge/coverage deploy cleanup
After creating `badge-deploy` and `coverage-html-deploy` composites, this template should be updated to use them instead of inline steps. The badge deploy (lines 133–146) and coverage HTML deploy (lines 148–158) are **exact duplicates** of patterns in `example-ci.yml`.

**Action:** 
1. Replace inline badge deploy with `uses: ai-warevo/.github/ci/actions/badge-deploy@main`
2. Replace inline coverage HTML deploy with `uses: ai-warevo/.github/ci/actions/coverage-html-deploy@main`
3. Update the C++ test stub (line 66) to reference `cmake-build` and `ctest-run` composites

---

### c) `ci/ci.yml` — update C++ stubs
The C++ stub on line 64 (`mkdir build && cd build && cmake .. && cmake --build .`) should reference the new `cmake-build` composite action.

---

## Summary of Actions Required

| Priority | Action | Impact |
|----------|--------|--------|
| **P0** | Create `cmake-build` composite | Eliminates 5 inline cmake patterns |
| **P0** | Create `ctest-run` composite | Eliminates 4 inline ctest patterns |
| **P0** | Create `gcovr-report` composite | Eliminates 1 complex inline gcovr block |
| **P0** | Create `badge-deploy` composite | Eliminates 2 identical inline badge deploy blocks |
| **P0** | Create `coverage-html-deploy` composite | Eliminates 2 identical inline coverage deploy blocks |
| **P1** | Create `docker-build-push` composite | Eliminates 2 identical Docker pipeline blocks |
| **P1** | Create `github-pages-deploy` composite | Eliminates 4 identical deploy parameter blocks |
| **P1** | Delete `ci/release.yml` (exact duplicate) | Removes 156 lines of dead code |
| **P1** | Update `example-ci.yml` to use new composites | ~75 lines → ~30 lines |
| **P1** | Update `release.yml` to use `docker-build-push` | ~156 lines → ~110 lines |
| **P1** | Update `test.yml` to use new composites | ~158 lines → ~90 lines |
| **P2** | Deprecate `docker-save` + `docker-push-ghcr` | 2 unused actions, consider removing |
| **P2** | Update `ci/ci.yml` C++ stub to use `cmake-build` | Template accuracy |
| **P2** | Update `ci/test.yml` C++ stubs to use `cmake-build` + `ctest-run` | Template accuracy |
