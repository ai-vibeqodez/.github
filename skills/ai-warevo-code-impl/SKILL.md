---
name: ai-warevo-code-impl
description: Classify the task, implement changes, and run all tests — full implementation cycle
inputs:
  working_dir:
    type: string
    required: true
    description: "Repository workspace path"
  issue:
    type: object
    required: true
    description: "Issue details (title, body, labels, classification)"
    properties:
      number: integer
      title: string
      body: string
      labels: string[]
      classification: bug|feature|task|docs|ci
  branch_name:
    type: string
    required: true
    description: "Current branch name"
    pattern: "^(feat|fix)/issue-\\d+$"
outputs:
  commit_hash:
    type: string
    description: "Git commit SHA"
  tests_passed:
    type: boolean
    description: "Whether all tests passed"
  changes_summary:
    type: string
    description: "Summary of implemented changes"
---

# Skill: ai-warevo-code-impl

## Input Validation
1. Verify `working_dir` is a valid git repository root
2. Check that `issue.classification` is one of: `bug`, `feature`, `task`, `docs`, `ci`
3. Verify `branch_name` matches `^(feat|fix)/issue-\\d+$`
4. If validation fails, report error and stop

## Purpose
Classify the task type, implement the required changes following repo conventions, and run all tests/linters/build checks.

## Inputs
- Working directory path (`~/workspace/<repo>/`)
- Issue details (title, body, labels, classification)
- Branch name (`feat/issue-NNN` or `fix/issue-NNN`)

## Outputs
- Implemented changes committed to the branch
- Commit hash
- Confirmation that all tests pass

## Workflow

### Step 1: Classify the task
Use the classification from issue-discoverer. Verify it by examining:
- Issue labels
- Issue title keywords
- Issue body content
- Repository type (C++, Python, JS, etc.)

Classification affects commit message format:
| Classification | Commit prefix |
|---|---|
| `bug` | `fix(#NNN): ` |
| `feature` | `feat(#NNN): ` |
| `task` | `feat(#NNN): ` |
| `docs` | `docs(#NNN): ` |
| `ci` | `ci(#NNN): ` |

### Step 2: Analyze the repository
Before making changes:
1. Read `AGENTS.md` and follow repository-specific instructions; they take precedence over this skill.
2. Read `README.md` — understand project structure
3. Read `CMakeLists.txt` or equivalent build file
4. Check for existing test files and test patterns
5. Look for linter configs (`.eslintrc`, `.prettierrc`, `pyproject.toml`, etc.)
6. Check for Makefile targets
7. Identify the tech stack

### Step 3: Implement changes
- Make changes following existing code patterns and conventions
- Do not change unrelated code
- Keep changes minimal and focused on the issue
- Follow the repo's style (indentation, naming, etc.)
- Respect repository ownership rules for generated files: when CI generates a changelog, version file, lockfile, or other artifact, change its generator/input rather than editing the generated artifact unless explicitly requested
- Add comments only where necessary (explain why, not what)

### Step 4: Commit changes
```bash
cd ~/workspace/<repo>/
git add -A
git commit -m "<prefix> <short description> (#NNN)

Closes #NNN"
```

Example:
```
feat(#42): add user authentication endpoint

Closes #42
```

### Step 5: Run build and tests
Use the repository's documented commands and existing presets/targets first. For this repository's C++23 reference profile, verify the configured C++ standard rather than forcing it, and prefer existing CMake presets and Makefile targets. Check formatting and static-analysis configuration when present, then run the project's unit tests. For CMake projects without documented commands, configure/build with the repository's declared generator and run CTest; do not assume Catch2 or a particular compiler. Run ASan/UBSan or other sanitizer configurations only when the project supports them and the environment can run them.

Check for available build/test commands in priority order:

1. **Makefile**:
   ```bash
   make lint    # if exists
   make build   # if exists
   make test    # if exists
   make check   # if exists
   ```

2. **npm/yarn/pnpm**:
   ```bash
   npm run lint
   npm run build
   npm test
   ```

3. **Python**:
   ```bash
   pytest
   flake8
   ```

4. **CMake**:
   ```bash
   cmake --build build --parallel
   ctest --test-dir build --output-on-failure
   ```

5. **Default** (if nothing found):
   ```bash
   git diff --stat   # verify changes look reasonable
   ```

### Step 6: Fix failures
- If any test/lint/build fails → fix the issue and re-run
- Do not push with failing tests
- Iterate until all checks pass

### Step 7: Return result
```
Working dir: ~/workspace/<repo>/
Branch: feat/issue-NNN
Commit: abc1234
Tests: PASSED
```

## Rules
- Always run all available tests before returning success
- Never commit with failing tests
- Use Conventional Commits format with issue reference
- Keep changes minimal and focused
- Follow existing code patterns — do not introduce new patterns without justification
- If the issue is unclear, ask for clarification before implementing
- If implementation requires external dependencies, note them in the commit message
