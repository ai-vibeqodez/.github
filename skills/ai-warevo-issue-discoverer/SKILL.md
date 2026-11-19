---
name: ai-warevo-issue-discoverer
description: Find, filter, and select the highest-priority open issue from an organization repository
inputs:
  repo:
    type: string
    required: true
    description: "Target repository in owner/name format (e.g. ai-warevo/.github)"
    pattern: "^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$"
outputs:
  issue:
    type: object
    format: JSON
    properties:
      issue_number: integer
      title: string
      body: string
      author: string
      labels: string[]
      classification: bug|feature|task|docs|ci
      priority_score: integer
---

# Skill: ai-warevo-issue-discoverer

## Input Validation
1. Check that `repo` matches `owner/name` format
2. Verify `gh` CLI is available and authenticated (`gh auth status`)
3. If validation fails, report error and stop

## Purpose
Automatically discover and select the best issue to work on from an organization repository. Filters by author, status, and priority.

## Inputs
- Target repository (e.g., `ai-warevo/<repo-name>`)

## Outputs
- Selected issue number (`#NNN`)
- Full issue details (title, body, labels, author, state)
- Classification: `bug` / `feature` / `task` / `docs` / `ci`

## Workflow

### Step 1: List open issues
```bash
gh issue list --repo ai-warevo/<repo> --state open --limit 50 --json number,title,body,labels,author,state
```

### Step 2: Filter issues
Keep only issues that match ALL criteria:
- **Author**: `loktionov129` or `ai-vibeqodez` only
- **State**: `open`
- **Not assigned**: no assignee (or unassigned)
- **Not closed/duplicate**: exclude closed, blocked, or duplicate labels

### Step 3: Classify each issue
Use labels + title + body to classify:
| Classification | Indicators |
|---|---|
| `bug` | label `bug`, title contains "fix", "error", "crash", "broken" |
| `feature` | label `enhancement`/`feature`, title contains "add", "implement", "create" |
| `task` | label `task`, no specific type indicators |
| `docs` | label `documentation`, title contains "doc", "readme", "comment" |
| `ci` | label `ci`/`workflow`, title contains "ci", "github actions", "pipeline" |

### Step 4: Prioritize and select
Priority order:
1. No labels + `loktionov129` author (highest — direct request)
2. `bug` label + `loktionov129` author
3. `feature` label + `loktionov129` author
4. No labels + `ai-vibeqodez` author
5. `bug` label + `ai-vibeqodez` author
6. `feature` label + `ai-vibeqodez` author

Select the highest-priority issue. If tied, pick the oldest (first in list).

### Step 5: Return structured result
```json
{
  "issue_number": 42,
  "title": "...",
  "body": "...",
  "author": "...",
  "labels": ["..."],
  "classification": "bug|feature|task|docs|ci",
  "priority_score": 1
}
```

## Rules
- Never assume issue priority — use the rules above strictly
- If no matching issues found, report clearly and stop (do not proceed)
- If issue body is too short for classification, default to `task`
- Always include the full issue body in output for downstream skills
- Use `--json` flag for reliable parsing, not text output
