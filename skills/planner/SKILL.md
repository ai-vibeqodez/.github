---
name: planner
description: Create a project plan, OVERVIEW.md, and task files from requirements documents
---

# Skill: Planner

## Purpose
Based on a requirements document, create a project plan: OVERVIEW.md with checkboxes and task files.

## Input
- Requirements document (from Skill 01_analyst)
- Priorities and MVP definition
- Deadlines and constraints

## Workflow

1. **Analyze requirements → decompose into tasks**
   - Go through all functional requirements
   - Break each requirement into atomic tasks
   - Treat non-functional requirements as separate tasks
   - Identify infrastructure setup tasks

2. **Determine execution order (task dependencies)**
   - Identify dependencies between tasks
   - Determine the critical path
   - Group tasks by logical phases
   - Consider MVP — tasks for MVP must come first

3. **Create OVERVIEW.md**
   - Fill the template from templates/overview.md
   - List all tasks with numbers
   - Describe dependencies
   - Document risks

4. **Create task directories and files**
   - For each task, create a directory `todo/<task_short_name>/` (if it doesn't exist)
   - Create file `todo/<task_short_name>/OVERVIEW.md` — general task overview (goal, status, plan, progress, dependencies, risks)
   - Create file(s) `todo/<task_short_name>/task_XX.md` — detailed subtask descriptions
   - Fill OVERVIEW.md using the template
   - Fill task_XX.md using the template (description, context, acceptance criteria, checklist, dependencies, deliverable)
   - Specify dependencies on other tasks
   - Define acceptance criteria

5. **Validate coverage completeness**
   - Verify that every requirement is covered by at least one task
   - Ensure dependencies do not form cycles
   - Verify that MVP tasks are identified and listed first
   - Recalculate progress (completed/total)

## OVERVIEW.md Template

```markdown
# <Project Name> — OVERVIEW

## Goal
Brief project description (2-3 sentences)

## Status
- [ ] Requirements gathering
- [ ] Planning
- [ ] Development
- [ ] Testing
- [ ] Release

## Task Plan
- [ ] **Task 1**: <description> (`todo/<task_short_name>/task_01.md`)
- [ ] **Task 2**: <description> (`todo/<task_short_name>/task_02.md`)
- [ ] **Task 3**: <description> (`todo/<task_short_name>/task_03.md`)

## Progress
Total tasks: X
Completed: Y
Percentage: Z%

## Dependencies
- Task 2 depends on Task 1
- Task 3 depends on Task 1
- Task directory: `todo/<task_short_name>/` (inside OVERVIEW.md + task_XX.md)

## Risks
- Risk 1: description
- Risk 2: description
```

## task_XX.md Template

```markdown
# Task <NN>: <Task Name>

## Description
Brief description of what needs to be done

## Context
Why this is needed, which requirements it addresses

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Execution Checklist
- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Dependencies
- Depends on: <specify tasks, e.g.: task_01>
- All task files in one directory: `todo/<task_short_name>/`

## Deliverable
What was done (filled in after completion)
```

## Output Files
- `todo/<task_short_name>/OVERVIEW.md` — task overview (goal, status, plan, progress, dependencies, risks)
- `todo/<task_short_name>/task_XX.md` — detailed subtask file(s)
- (optional) `todo/<task_short_name>/deps.md` — dependency graph in text form

## Rules
- Each task must be atomic (cannot be split further without losing meaning)
- Each task must be verifiable (clear acceptance criteria)
- Each task must have acceptance criteria (at least 2-3 items)
- Dependencies must be acyclic
- MVP tasks must come first in the list
- Task numbering is sequential, without gaps (task_01, task_02, ...)
- One task = one directory `todo/<task_short_name>/`
- Inside the directory: `OVERVIEW.md` + one or more `task_XX.md`
- `<task_short_name>` is a short English name for the task, kebab-case (e.g., `llamacpp-docker-setup`)
