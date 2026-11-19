---
name: ai-warevo-code-impl
description: Classify the task, implement changes, and run all tests — full implementation cycle
---

# Skill: ai-warevo-code-impl

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
1. Read `README.md` — understand project structure
2. Read `CMakeLists.txt` or equivalent build file
3. Check for existing test files and test patterns
4. Look for linter configs (`.eslintrc`, `.prettierrc`, `pyproject.toml`, etc.)
5. Check for Makefile targets
6. Identify the tech stack

### Step 3: Implement changes
- Make changes following existing code patterns and conventions
- Do not change unrelated code
- Keep changes minimal and focused on the issue
- Follow the repo's style (indentation, naming, etc.)
- Add comments only where necessary (explain why, not what)

### Step 4: Commit changes
```bash
cd ~/workspace/<repo>/
git add -A
git commit -m "<prefix> <short description>
\n\nCloses #NNN"
```

Example:
```
feat(#42): add user authentication endpoint

Closes #42
```

### Step 5: Run build and tests
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
