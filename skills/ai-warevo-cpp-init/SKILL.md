---
name: ai-warevo-cpp-init
description: Create a new C++23 project from template_cpp generator
inputs:
  project_name:
    type: string
    required: true
    description: "Project name (lowercase, e.g. my-lib)"
    pattern: "^[a-z][a-z0-9_-]*$"
  project_type:
    type: string
    required: true
    description: "Template type"
    enum: [cli, static, dynamic]
  namespace:
    type: string
    required: false
    description: "C++ namespace (default: aw::unnamed)"
    default: "aw::unnamed"
  skip_tests:
    type: boolean
    required: false
    description: "Skip tests directory (default: false)"
    default: false
  skip_eject:
    type: boolean
    required: false
    description: "Keep templates/ directory (default: false)"
    default: false
outputs:
  working_dir:
    type: string
    description: "Path to the new project directory"
  status:
    type: string
    enum: [ready, failed]
---

# Skill: ai-warevo-cpp-init

## Purpose
Create a new C++23 project using the `template_cpp` generator (like `dotnet new`). Supports `cli`, `static`, and `dynamic` library templates.

## Input Validation
1. Check that `project_name` matches `^[a-z][a-z0-9_-]*$`
2. Verify `project_type` is one of: `cli`, `static`, `dynamic`
3. If `namespace` is provided, validate it contains only `::`-separated identifiers
4. If validation fails, report error and stop

## Inputs
- Project name (e.g., `my-lib`)
- Project type: `cli`, `static`, or `dynamic`
- Namespace (optional, default: `aw::unnamed`)
- Skip tests (optional, default: false)
- Skip eject (optional, default: false)

## Outputs
- New project directory with CMakeLists.txt, src/, include/, tests/
- Git repository ready for commits

## Workflow

### Step 1: Locate or clone template_cpp

```bash
TEMPLATE_DIR="${TEMPLATE_CPP_PATH:-$HOME/workspace/template_cpp}"

if [ ! -d "$TEMPLATE_DIR" ]; then
  echo "Cloning template_cpp..."
  git clone git@github.com:ai-warevo/template_cpp.git "$TEMPLATE_DIR"
fi

cd "$TEMPLATE_DIR"
```

### Step 2: Validate project name

```bash
PROJECT_NAME="<project_name>"

# Check against C++ keywords and forbidden patterns
if echo "$PROJECT_NAME" | grep -qE '(^|[[:space:]])(__|[a-zA-Z])'; then
  echo "Error: project name must start with lowercase letter, no __ prefix"
  exit 1
fi
```

### Step 3: Run make init

```bash
cd "$TEMPLATE_DIR"

NS="<namespace>"
TESTS_OPT=""
[ "<skip_tests>" = "true" ] && TESTS_OPT="TESTS=0"

make init TYPE=<project_type> NAME="<project_name>" NS="$NS" $TESTS_OPT
```

### Step 4: Move project to target directory

```bash
PROJECT_DIR="$HOME/workspace/<project_name>"

# The generator creates files in the current directory
# Move them to the target location
mkdir -p "$PROJECT_DIR"
mv "$TEMPLATE_DIR/CMakeLists.txt" "$TEMPLATE_DIR/src/" "$TEMPLATE_DIR/include/" "$TEMPLATE_DIR/tests/" "$TEMPLATE_DIR/examples/" "$PROJECT_DIR/" 2>/dev/null || true
```

### Step 5: Eject generator (optional)

```bash
cd "$PROJECT_DIR"

if [ "<skip_eject>" = "false" ]; then
  make eject
fi
```

### Step 6: Initialize git for the new project

```bash
cd "$PROJECT_DIR"
git init
git add .
git commit -m "chore: init project from template_cpp (<project_type>)"
```

### Step 7: Return result

Print the project path:

```
Project: $PROJECT_DIR
Type: <project_type>
Namespace: <namespace>
Tests: <skip_tests>
Generator ejected: <skip_eject>
```

## Rules
- Project name must be lowercase alphanumeric with underscores/hyphens
- Project name must not be a C++ keyword and must not start with `__`
- Namespace uses `::` separator (e.g., `aw::foo::bar`)
- If `make init` fails, do not proceed to git init
- Generator is pure Bash (3.2+), no Python required
- Templates are C++23 with `-Wall -Wextra -Wpedantic` (or `/W4` on MSVC)
- All templates include Catch2 v3 tests (unless skipped)

## Template Details

| TYPE | Aliases | Output |
|------|---------|--------|
| `cli` | `console`, `exe`, `app` | Executable with core library + `main.cpp` |
| `static` | `lib`, `library` | Static library with public header |
| `dynamic` | `dll`, `so`, `shared` | Shared library with `GenerateExportHeader` macros |

## Dependencies
- `template_cpp` repository (cloned to `$HOME/workspace/template_cpp` or `$TEMPLATE_CPP_PATH`)
- `cmake`, C++23 compiler, `make` (or `bash` on Windows)
