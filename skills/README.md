# 📚 Skill Catalog

## ai-warevo-analyst/ — Analyst
**Purpose**: Requirements gathering via stakeholder interview.
**Input**: Project name, context, stakeholders
**Output**: Structured requirements document
**Complexity**: Medium
**Dependencies**: None

## ai-warevo-planner/ — Planner
**Purpose**: Create project plan, OVERVIEW.md and task files from requirements.
**Input**: Requirements document (from ai-warevo-analyst)
**Output**: OVERVIEW.md, task_XX.md in task directory
**Complexity**: Medium
**Dependencies**: ai-warevo-analyst/

## ai-warevo-executor/ — Executor
**Purpose**: Execute tasks from todo/<task_short_name>/task_XX.md.
**Input**: Path to task file, context from OVERVIEW.md
**Output**: Implemented files, filled result, updated OVERVIEW.md
**Complexity**: Medium
**Dependencies**: ai-warevo-planner/ (tasks must be created)

## ai-warevo-skill-creator/ — Skill Creator
**Purpose**: Create new skills and update the skill catalog.
**Input**: Description of new skill
**Output**: skills/<name>/SKILL.md, updated skills/README.md and README.md
**Complexity**: High
**Dependencies**: None

## ai-warevo-git-github-push/ — Git GitHub Push
**Purpose**: Push commits to GitHub via SSH with read-only filesystem workaround.
**Input**: Ready commits, remote repository
**Output**: Successful push to GitHub
**Complexity**: Low
**Dependencies**: None

## ai-warevo-ci-infrastructure-integrator/ — CI/CD Infrastructure Integrator
**Purpose**: Selective, conflict-aware merge of catalog CI/CD artifacts into an already configured or partially configured project while preserving project-specific logic.
**Input**: Target project path, catalog repo path, project type
**Output**: Merged workflow files, preserved/extended build config, documentation, validation result
**Complexity**: Medium
**Dependencies**: None; use after ai-warevo-ci-setup when baseline CI is bootstrapped first

## ai-warevo-ci-setup/ — CI Setup
**Purpose**: Bootstrap the complete standard Makefile CI contract and baseline reusable workflows in a project that lacks them or needs baseline conformance.
**Input**: Repository path, optional language/build/test stack
**Output**: `pr-fast`, `weekly-deep`, and `release` Makefile targets, baseline workflow files, coverage/release artifacts
**Complexity**: Medium
**Dependencies**: None; use ai-warevo-ci-infrastructure-integrator afterward for selective catalog merging

## ai-warevo-cpp-init/ — C++ Project Init
**Purpose**: Create a new C++23 project from the template_cpp generator.
**Input**: Project name, type (cli/static/dynamic), namespace
**Output**: New project directory with CMakeLists.txt, src/, include/, tests/
**Complexity**: Low
**Dependencies**: template_cpp repository

## ai-warevo-orchestrator/ — Org Repo Worker (Orchestrator)
**Purpose**: Orchestrates the full autonomous workflow by delegating to specialized sub-skills. Does not implement steps directly — delegates and verifies.
**Input**: Issue number or task description, target repository
**Output**: Implemented changes pushed to fork, open PR targeting org repo
**Complexity**: High
**Dependencies**: ai-warevo-git-github-push/, ai-warevo-issue-discoverer/, ai-warevo-workspace-prepper/, ai-warevo-code-impl/, ai-warevo-pr-manager/
**Language**: English

### Sub-skills

#### ai-warevo-issue-discoverer/ — Issue Discoverer
**Purpose**: Find, filter, and select the highest-priority open issue from an organization repository.
**Input**: Target repository name
**Output**: Selected issue number, full details, classification (bug/feature/task/docs/ci)
**Complexity**: Low
**Dependencies**: None

#### ai-warevo-workspace-prepper/ — Workspace Prepper
**Purpose**: Prepare the working environment — fork, clone, and create a branch for the selected issue.
**Input**: Repository name, issue number, classification
**Output**: Local working directory path, branch name
**Complexity**: Low
**Dependencies**: ai-warevo-issue-discoverer/

#### ai-warevo-code-impl/ — Code Implementer
**Purpose**: Classify the task, implement changes, and run all tests — full implementation cycle.
**Input**: Working directory, issue details, branch name
**Output**: Implemented changes committed, commit hash, test confirmation
**Complexity**: High
**Dependencies**: ai-warevo-workspace-prepper/

#### ai-warevo-pr-manager/ — PR Manager
**Purpose**: Push branch to fork, create PR targeting the organization repo, self-review, and monitor CI.
**Input**: Branch name, issue number, commit hash, working directory, change summary
**Output**: PR URL, CI status, self-review notes
**Complexity**: Medium
**Dependencies**: ai-warevo-code-impl/
