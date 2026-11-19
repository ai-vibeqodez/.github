---
name: executor
description: Execute tasks — pass a path to todo/<name>/ or a specific task_XX.md
inputs:
  task_path:
    type: string
    required: true
    description: "Path to task directory (todo/<name>/) or task file (todo/<name>/task_XX.md)"
    pattern: "^todo/[^/]+/(task_\\d+\\.md)?$"
outputs:
  result:
    type: markdown
    description: "Task execution result with completed acceptance criteria"
  updated_files:
    type: string[]
    description: "List of modified files"
---

# Skill: Executor

## Purpose
Execute tasks from `todo/<task_short_name>/`. Accepts a path to the task directory or a specific task file.

## Input Validation
1. Verify `task_path` matches `todo/<name>/` or `todo/<name>/task_XX.md` format
2. Check that the referenced file or directory exists
3. If validation fails, report error and stop

## How to Run
Write:
- `todo/<task_short_name>/` — execute all unexecuted tasks in the directory
- `todo/<task_short_name>/task_XX.md` — execute a specific task
- Or simply: "execute task_01"

## Workflow

1. **Identify the task**
    - If a path to `todo/<name>/` is provided — read OVERVIEW.md, find the first unexecuted task
    - If a path to `task_XX.md` is provided — work with that file
    - If only a task number is given — find it in OVERVIEW.md

2. **Read context**
    - Open `todo/<task_short_name>/task_XX.md`
    - Open `todo/<task_short_name>/OVERVIEW.md` for overall context
    - Check dependencies — verify that all dependent tasks are completed

3. **Readiness check**
    - Ensure dependencies are satisfied
    - Verify all necessary resources are available
    - If something is missing — report it, do not start work

4. **Execute the task**
    - Go through the execution checklist
    - Create/modify files according to the task description
    - Follow the acceptance criteria
    - Record each completed step

5. **Fill in the result**
    - Fill the "Result" section in task_XX.md
    - Mark all acceptance criteria as completed
    - Update OVERVIEW.md (check off the task)

6. **Commit**
    - Commit changes to task_XX.md and OVERVIEW.md

## Start Checklist
- [ ] Task identified and read
- [ ] OVERVIEW.md read for context
- [ ] Dependencies checked and satisfied
- [ ] Acceptance criteria are clear

## Rules
- Do not start a task if dependencies are not met
- Always read OVERVIEW.md from the same directory as the task file
- Follow the execution checklist step by step
- Fill in the "Result" section after completion
- Update OVERVIEW.md (task checkboxes)
- If a task cannot be completed — explain why
- Commit all changes
