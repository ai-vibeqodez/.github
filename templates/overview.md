# <Project Name> — OVERVIEW

## Goal

Brief project description (2–3 sentences). What problem does this project solve? Who is it for? What makes it unique?

**Example**: _"This project provides a reusable CI/CD template for ai-warevo projects, enabling consistent build, test, and release workflows across C++, C#, Python, and other stacks."_

## Status

- [ ] Requirements gathering
- [ ] Planning
- [ ] Development
- [ ] Testing
- [ ] Release

## Task Plan

| # | Task | File | Status | Dependencies |
|---|------|------|--------|--------------|
| 1 | Set up repository structure | `task_01.md` | ⬜ | — |
| 2 | Implement core functionality | `task_02.md` | ⬜ | Task 1 |
| 3 | Add tests and documentation | `task_03.md` | ⬜ | Task 2 |
| 4 | Prepare release | `task_04.md` | ⬜ | Task 3 |

**Legend**: ⬜ pending | 🔄 in progress | ✅ completed

## Progress

| Metric | Value |
|--------|-------|
| Total tasks | 4 |
| Completed | 0 |
| In progress | 0 |
| Percentage | 0% |

## Dependencies

- **Task 2** depends on Task 1 — repository structure must be in place before implementation.
- **Task 3** depends on Task 2 — tests require implemented functionality.
- **Task 4** depends on Task 3 — release requires tested code.

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Scope creep | Delayed release | Define clear acceptance criteria per task |
| External dependency changes | Build failures | Pin versions, add fallback |
| Knowledge concentration | Bus factor | Document decisions, pair on complex tasks |

## Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| YYYY-MM-DD | Choose CMake over Make | Cross-platform support, better dependency tracking |
| YYYY-MM-DD | Use Ninja as generator | Faster builds, parallel execution |

## Notes

Additional context, references, or links that don't fit elsewhere.
