---
name: ai-warevo-ci-infrastructure-integrator
description: Merge selected CI/CD infrastructure from a catalog repository into an existing project while preserving project-specific logic
inputs:
  target_project_path:
    type: string
    required: true
    description: "Path to the target project directory"
  catalog_repo_path:
    type: string
    required: true
    description: "Path to the catalog repository"
  project_type:
    type: string
    required: false
    description: "Language, build system, test framework (auto-detected if not specified)"
outputs:
  workflow_files:
    type: file[]
    path_pattern: ".github/workflows/*.yml"
  build_config:
    type: file
    path: "CMakeLists.txt or equivalent"
  documentation:
    type: file[]
    path_pattern: "README.md|CHANGELOG.md|CONTRIBUTING.md"
  validation_result:
    type: object
    properties:
      yaml_valid: boolean
      uses_references_valid: boolean
      no_existing_logic_lost: boolean
---

# Skill: CI/CD Infrastructure Integrator

## Input Validation
1. Verify `target_project_path` exists and is a directory
2. Verify `catalog_repo_path` exists and is a directory
3. If validation fails, report error and stop

## Purpose
Merge selected CI/CD artifacts from a catalog repository into a project that already has CI/CD or needs only a subset of the catalog. This skill owns comparison, conflict resolution, and preservation of existing project-specific workflows and build logic. Use `ai-warevo-ci-setup` instead when the repository needs the complete standard Makefile contract and the three baseline workflows from scratch.

## When to Use
- Use this skill for selective adoption or migration where existing workflows, Makefile targets, build options, or documentation must be compared and merged.
- Use `ai-warevo-ci-setup` for a new or incomplete CI setup that should receive the full standard Makefile contract and baseline workflows.
- If both are needed, run `ai-warevo-ci-setup` first, then use this skill to merge project-specific or additional catalog artifacts.

## Workflow

### 1. Catalog Repository Exploration
- Traverse the structure of the catalog repository and determine what it contains:
  - CI/CD reusable workflows (`.github/workflows/reusable-*.yml`) and templates (`templates/workflows/`)
  - Composite actions / reusable actions (`.github/actions/` or similar)
  - Documentation templates (`templates/`)
  - Example projects (`example/` or similar)
- Do not rely on assumptions — explore the catalog repository as a living repository; it may evolve
- Build a map of available artifacts

### 2. Target Project Analysis
- Determine the project structure: language, build system, test framework, dependencies
- Check what already exists: `.github/workflows/`, `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `CMakeLists.txt` (or equivalent)
- Identify gaps: what is missing, what needs to be added

### 3. Smart Merge of Workflow Files
**Do NOT overwrite files entirely.** For each workflow file:

- **If the file does not exist in the project** — create it from the catalog repository template, adapting it to the project stack
- **If the file already exists** — perform a diff-merge:
  - What from the template is not yet implemented → add it
  - What exists in the project but not in the template → preserve (if reasonable)
  - Where semantics differ → adapt the template to the project, not the other way around
  - Replace placeholders with real project commands
  - Replace composite action stubs with `uses:` references to the catalog repository

### 4. Build System Configuration
Compare the current build configuration with the example from the catalog repository (`example/` or equivalent):
- First identify the project's declared language standard, compiler/toolchain, build presets, test framework, and existing options. For this catalog's C++23 reference profile, use the project's CMake configuration as the model, not as a mandate for non-C++ projects.
- Add options for tests, code coverage, sanitizers (if present in the template)
- Integrate the test framework (via FetchContent, vcpkg, Conan, or equivalent)
- Configure sanitizers for Debug builds where supported by the compiler and project
- Configure code coverage for generating coverage reports
- Preserve existing targets, options, compiler choices, and toolchain behavior; add or merge configuration rather than replacing it

### 5. Composite Actions Integration
- **DO NOT COPY** composite actions into the project
- Composite actions live in the catalog repository and are used via `uses:`:
  ```yaml
  - name: Configure & Build
    uses: <repo-path>/.github/actions/<name>@main
    with:
      source_dir: .
      build_type: Release
  ```
- Replace stubs in workflow files with real `uses:` references

### 6. Documentation
- **README.md**: if it does not exist — create from the template. If it exists — add missing sections (badges, CI status, usage) without removing existing content
- **CHANGELOG.md**: if it does not exist — create from the template. If it exists — add a `## [Unreleased]` section with current changes, preserving the history
- **CONTRIBUTING.md**: if it does not exist — create from the template. If it exists — add missing content

### 7. Validation
- Check syntactic validity of all workflow files
- Verify that the build configuration matches the project structure
- Ensure that no existing logic was lost during the merge
- Verify that all `uses:` references point to existing composite actions in the catalog repository

## Rules
- **Smart merge, not dummy copy** — never overwrite files entirely
- **Uses, not copy** — use composite actions via `uses:`, do not copy `action.yml` into the project
- **Preserve existing** — do not delete existing code, targets, or workflow files
- **Adapt template to project, not the other way around** — the template adapts to the project, not the project to the template
- **Explore the catalog repository** — it is alive and evolving; do not rely on assumptions
- **One step at a time** — analysis first, then merge, then validation
- **Document changes** — commit with meaningful Conventional Commits

## Output Files
- `.github/workflows/*.yml` — integrated workflow files (smart merge)
- `CMakeLists.txt` (or equivalent) — updated build configuration
- `README.md` — updated documentation
- `CHANGELOG.md` — updated changelog
- `CONTRIBUTING.md` — updated contributing guide

## What NOT to Do
- ❌ Do not overwrite files entirely
- ❌ Do not delete existing workflow files, targets, or options
- ❌ Do not write workflow files from scratch — take the template and adapt it
- ❌ Do not copy composite actions as `action.yml` into the project
- ❌ Do not invent a CHANGELOG structure — follow the template
- ❌ Do not rely on memory about the catalog repository contents — explore it
