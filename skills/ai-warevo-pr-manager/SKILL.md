---
name: ai-warevo-pr-manager
description: Push branch to fork, create PR targeting the organization repo, self-review, and monitor CI
inputs:
  branch_name:
    type: string
    required: true
    description: "Branch to push"
    pattern: "^(feat|fix)/issue-\\d+$"
  issue_number:
    type: integer
    required: true
    description: "GitHub issue number"
    min: 1
  commit_hash:
    type: string
    required: true
    description: "Git commit SHA"
    pattern: "^[a-f0-9]{40}$"
  working_dir:
    type: string
    required: true
    description: "Repository workspace path"
  changes_summary:
    type: string
    required: false
    description: "Summary of changes from code-impl"
outputs:
  pr_url:
    type: string
    description: "Pull request URL"
  ci_status:
    type: string
    enum: [passed, failed, pending]
  review_notes:
    type: string
    description: "Self-review notes"
---

# Skill: ai-warevo-pr-manager

## Input Validation
1. Verify `branch_name` matches `^(feat|fix)/issue-\\d+$`
2. Check that `commit_hash` is a 40-char hex string
3. Verify `working_dir` is a valid git repository root
4. If validation fails, report error and stop

## Purpose
Push the implementation branch to the agent's fork, create a Pull Request targeting the organization repo's `main` branch, self-review the diff, and monitor CI checks.

## Inputs
- Branch name (`feat/issue-NNN` or `fix/issue-NNN`)
- Issue number (`#NNN`)
- Commit hash
- Working directory path (`~/workspace/<repo>/`)
- Summary of changes (from code-impl)

## Outputs
- PR URL
- Confirmation that CI checks pass
- Self-review notes

## Workflow

### Step 1: Push branch to fork
Follow the canonical remote and SSH procedure in [`ai-warevo-git-github-push/SKILL.md`](../ai-warevo-git-github-push/SKILL.md), then push to the named fork remote:
```bash
cd ~/workspace/<repo>/
GIT_SSH_COMMAND="ssh -i /tmp/ssh/id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/ssh/known_hosts" \
  git push -u dshagent feat/issue-NNN
```

### Step 2: Create Pull Request
```bash
gh pr create \
  --repo ai-warevo/<repo> \
  --base main \
  --head ai-vibeqodez:feat/issue-NNN \
  --title "<prefix> <short description> (#NNN)" \
  --body "## Description
Closes #NNN

## Changes
- <summary of changes>

## Testing
- <what tests were run and their status>

## Checklist
- [ ] Changes follow repo conventions
- [ ] All tests pass
- [ ] No unrelated changes included
- [ ] Commit message follows Conventional Commits"
```

Example title: `feat(#42): add user authentication endpoint`

### Step 3: Self-review
1. Run `gh pr diff <PR_NUMBER>` to see the full diff
2. Review each changed file:
   - Does the change match the issue requirements?
   - Are there any unintended changes?
   - Is the code clean and follows conventions?
   - Are there any edge cases not handled?
3. If issues found → fix, commit, push, and repeat review

### Step 4: Monitor CI checks
```bash
gh pr checks <PR_NUMBER> --watch
```
- Wait for all CI checks to complete
- If any check fails → investigate, fix, commit, push
- Iterate until all CI checks pass

### Step 5: Return result
```
PR URL: https://github.com/ai-warevo/<repo>/pull/<PR_NUMBER>
CI Status: PASSED
Self-review: PASSED
```

## Rules
- Always push to the `dshagent` remote (`ai-vibeqodez/<repo>` fork) — never to `origin` or `ai-warevo/<repo>`
- PR must target `ai-warevo/<repo>:main`
- Always self-review the diff before considering the task complete
- Never submit a PR with failing CI checks
- If CI fails, fix the issue and push — do not ignore failures
- Include `Closes #NNN` in the PR body
- Use Conventional Commits in the PR title
- Document what was tested in the PR body
- **Never merge PRs** — merging is the user's (repo owner's) responsibility only. Agent's role: fix bugs, work on PRs, report status.

## Git workflow rules
Shared rules (never commit to `main`, never push to `origin`, SSH only, use the `dshagent` fork remote, PAT auth) are defined in [`ai-warevo-git-github-push/SKILL.md`](../ai-warevo-git-github-push/SKILL.md).
