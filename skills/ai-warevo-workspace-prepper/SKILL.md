---
name: ai-warevo-workspace-prepper
description: Prepare the working environment — fork, clone, and create a branch for the selected issue
inputs:
  repo:
    type: string
    required: true
    description: "Target repository in owner/name format"
    pattern: "^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$"
  issue_number:
    type: integer
    required: true
    description: "GitHub issue number"
    min: 1
  classification:
    type: string
    required: true
    description: "Issue classification"
    enum: [bug, feature, task, docs, ci]
outputs:
  working_dir:
    type: string
    description: "Local workspace path"
  branch_name:
    type: string
    description: "Branch name (fix/issue-NNN or feat/issue-NNN)"
  status:
    type: string
    enum: [ready, failed]
---

# Skill: ai-warevo-workspace-prepper

## Input Validation
1. Check that `repo` matches `owner/name` format
2. Verify `issue_number` is a positive integer
3. Verify `classification` is one of: `bug`, `feature`, `task`, `docs`, `ci`
4. If validation fails, report error and stop

## Purpose
Set up the local working environment: ensure the fork exists, clone it, sync `main`, and create a properly named branch.

## Inputs
- Target repository name (e.g., `ai-warevo/<repo-name>`)
- Issue number (`#NNN`)
- Issue classification (`bug` / `feature` / `task` / `docs` / `ci`)

## Outputs
- Local working directory path (`~/workspace/<repo>/`)
- Branch name (`feat/issue-NNN` or `fix/issue-NNN`)
- Confirmation that the environment is ready

## Workflow

### Step 1: Check if repo exists locally
```bash
ls ~/workspace/<repo>/
```
- If exists → go to Step 4
- If not → continue to Step 2

### Step 2: Verify fork exists
```bash
gh repo view ai-vibeqodez/<repo> --json fullName
```
- If fork exists → skip Step 3
- If fork missing → create fork:
  ```bash
  gh repo fork ai-warevo/<repo> --clone=false
  ```

### Step 3: Clone the fork
```bash
git clone git@github.com:ai-vibeqodez/<repo>.git ~/workspace/<repo>/
```

### Step 4: Configure git
```bash
git config user.name "Anatoly Ivanov"
git config user.email "ai_vibeqodez@vk.com"
```

### Step 5: Sync main branch
```bash
cd ~/workspace/<repo>/
git fetch origin
git checkout main
git pull origin main
```

### Step 6: Create branch based on classification
- If classification is `bug` → `fix/issue-NNN`
- Otherwise → `feat/issue-NNN`

```bash
git checkout -b feat/issue-NNN
```

### Step 7: Return result
Print the working directory path and branch name:
```
Working dir: ~/workspace/<repo>/
Branch: feat/issue-NNN
```

## Rules
- Always sync `main` before creating the branch
- Branch naming must follow the classification rule (`fix/` for bugs, `feat/` for everything else)
- If any step fails, report the error and stop (do not proceed to implementation)
- If the repo already has a branch `feat/issue-NNN` or `fix/issue-NNN`, delete it first: `git branch -D feat/issue-NNN`

## Git workflow rules
Shared rules (never commit to `main`, never push to `origin`, SSH only, fork as `dshagent`) are defined in [`git-github-push/SKILL.md`](../git-github-push/SKILL.md).
