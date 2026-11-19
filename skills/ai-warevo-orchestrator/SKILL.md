---
name: ai-warevo-orchestrator
description: Orchestrator skill — coordinates the full pipeline by delegating to specialized sub-skills (ai-warevo-issue-discoverer, ai-warevo-workspace-prepper, ai-warevo-code-impl, ai-warevo-pr-manager)
---

# Skill: ai-warevo-orchestrator

## Purpose
Orchestrates the complete autonomous workflow for working on tasks in organization repositories. This skill **does not implement steps directly** — it delegates to specialized sub-skills and verifies each step's completion.

## Designation
This is the **orchestrator**. It manages the pipeline flow: calls sub-skills, passes context between them, handles errors, and ensures the full pipeline completes. When sub-skills are not yet available, execute the corresponding step inline as a fallback.

## Inputs
- Issue number (`#NNN`) or task description
- Target organization repository (e.g., `ai-warevo/<repo>`)

## Outputs
- Implemented changes pushed to the agent's fork (`ai-vibeqodez/<repo>`)
- Open Pull Request targeting `ai-warevo/<repo>:main`
- Summary of actions taken

## Pipeline Architecture

```
ai-warevo-orchestrator (orchestrator)
├── ai-warevo-issue-discoverer    → Step 1: Find & select issue
├── ai-warevo-workspace-prepper   → Step 2: Fork, clone, branch
├── ai-warevo-code-impl           → Steps 3-5: Classify, implement, test
└── ai-warevo-pr-manager          → Steps 6-7: Push, PR, review
```

## Workflow

### Step 1: Delegate to ai-warevo-issue-discoverer
1. Call `ai-warevo-issue-discoverer` skill with the target repository.
2. The sub-skill should:
   - List open issues via `gh issue list`
   - Filter: **only** `loktionov129` and `ai-vibeqodez`
   - Exclude closed, assigned, blocked, or duplicate issues
   - Sort by priority, select the highest-priority unassigned issue
   - Return the selected issue number and full details
3. **Fallback** (if issue-discoverer not available): execute discovery steps inline (see Inline Fallbacks).
4. Verify the sub-skill returned a valid issue. If not, report error and stop.

### Step 2: Delegate to ai-warevo-workspace-prepper
1. Call `ai-warevo-workspace-prepper` skill with:
   - Target repository name
   - Selected issue number
   - Issue classification (from Step 1)
2. The sub-skill should:
   - Check if repo exists in `~/workspace/`
   - Verify/create fork at `ai-vibeqodez/<repo>`
   - Clone fork if needed
   - Sync `main` via `git pull origin main`
   - Create branch: `feat/issue-NNN` or `fix/issue-NNN`
   - Return the working directory path
3. **Fallback**: execute workspace prep inline.
4. Verify the working directory is ready. If not, report error and stop.

### Step 3: Delegate to ai-warevo-code-impl
1. Call `ai-warevo-code-impl` skill with:
   - Working directory (from Step 2)
   - Issue details and classification
   - Implementation plan
2. The sub-skill should:
   - Classify the task (bug fix / feature / refactor / docs / CI)
   - Implement changes following repo conventions
   - Use Conventional Commits format
   - Run all tests, linters, and build checks
   - Fix any failures
   - Return the commit hash
3. **Fallback**: execute implementation inline.
4. Verify changes are committed. If not, report error and stop.

### Step 4: Delegate to ai-warevo-pr-manager
1. Call `ai-warevo-pr-manager` skill with:
   - Branch name
   - Issue number
   - Commit hash
   - Summary of changes
2. The sub-skill should:
   - Push branch to `ai-vibeqodez/<repo>`
   - Create PR targeting `ai-warevo/<repo>:main`
   - Perform self-review of the diff
   - Monitor CI checks and iterate on feedback
   - Return the PR URL
3. **Fallback**: execute push/PR inline.
4. Verify PR is created and CI passes. If not, iterate.

## Inline Fallbacks
When a sub-skill is not available, execute the step directly using these rules:

### Issue Discovery (fallback)
- `gh issue list --state open` → filter authors → sort → select
- Only `loktionov129` and `ai-vibeqodez`

### Workspace Prep (fallback)
- Check `~/workspace/<repo>/` exists → skip clone if yes
- `gh repo fork ai-warevo/<repo> --clone=false` if fork missing
- `git clone git@github.com:ai-vibeqodez/<repo>.git`
- `git fetch origin && git checkout main && git pull origin main`
- Branch: `feat/issue-NNN` or `fix/issue-NNN`

### Implementation (fallback)
- Analyze issue text + labels → classify
- Make changes following repo conventions
- Conventional Commits: `feat(#NNN): description`
- Run Makefile targets, linters, tests — fix all failures

### Push & PR (fallback)
- `git config user.name "Anatoly Ivanov"` / `user.email "ai_vibeqodez@vk.com"`
- `git push -u origin feat/issue-NNN`
- `gh pr create --base main --head feat/issue-NNN --title "..." --body "Closes #NNN\n\n## Changes\n- ..."`

## Conventions
- **Git user**: `Anatoly Ivanov` <ai_vibeqodez@vk.com>
- **Branch naming**: `feat/issue-NNN` / `fix/issue-NNN`
- **Commit format**: Conventional Commits with issue reference
- **Push target**: `ai-vibeqodez/<repo>` (agent's fork)
- **PR target**: `ai-warevo/<repo>:main` (organization repo)
- **Issue filtering**: Only `loktionov129` and `ai-vibeqodez`
- **SSH setup**: Use `/tmp/ssh` workaround if filesystem is read-only (see `git-github-push` skill)

## Rules
- Always delegate to sub-skills when available — do not duplicate their logic
- Verify each sub-skill completes successfully before proceeding
- Stop the pipeline if any step fails (do not continue with partial results)
- Never push directly to `ai-warevo` — always use fork
- Always sync `main` before branching
- Run all available tests and linters before pushing
- Self-review every PR before submitting
- Iterate on review feedback until approved
