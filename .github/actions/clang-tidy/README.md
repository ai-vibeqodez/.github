# Clang-Tidy Lint Action

A composite GitHub Action for running `clang-tidy` on C++ source and header files, failing on any warnings.

## Purpose

Scans C++ files through `clang-tidy` using the project's `compile_commands.json`. A non-zero exit (any warning from the selected check suite) fails the step. Requires `clang-tidy` to be installed (e.g. `clang-tidy-18` in the `ci-cpp20` container).

## Input parameters (`inputs`)

| Parameter | Description | Required | Default |
| :--- | :--- | :---: | :--- |
| `source_dir` | Source directory to scan (relative to workspace) | No | `.` |
| `build_dir` | CMake build directory containing `compile_commands.json` | No | `build` |
| `checks` | `clang-tidy` check patterns (comma-separated) | No | `*,bugprone-*,modernize-*` (full suite) |
| `header_filter` | Regex for headers to include in diagnostics | No | `.*` |
| `exclude` | Directory names to exclude (comma-separated, pruned by `find`) | No | `_deps,build,CMakeFiles,cmake` |
| `fail_on_error` | Whether non-zero exit code fails the step | No | `true` |

## Usage example

```yaml
- name: Run clang-tidy
  uses: ai-warevo/<repo>/.github/actions/clang-tidy@6cae36f7fe728c23b1a6170d09d6dace55edea77
  with:
    source_dir: .
    build_dir: build
    checks: 'bugprone-*,modernize-*'
    header_filter: .*/include/aw/tpl/.*
    exclude: _deps,build
```
