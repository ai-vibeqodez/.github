---
name: ai-warevo-skill-creator
description: Creating new skills and updating the skills repository
inputs:
  name:
    type: string
    required: true
    description: "Name of the new skill"
    pattern: "^[a-z][a-z0-9_-]*$"
  purpose:
    type: string
    required: true
    description: "Brief description of the skill purpose"
    min_length: 10
  inputs:
    type: string
    required: false
    description: "Input data specification"
  outputs:
    type: string
    required: false
    description: "Output data specification"
outputs:
  skill_file:
    type: file
    path: "skills/<name>/SKILL.md"
    format: markdown
  updated_catalog:
    type: file
    path: "skills/README.md"
  updated_readme:
    type: file
    path: "README.md"
---

# Skill: Skill Creator

## Input Validation
1. Check that `name` matches `^[a-z][a-z0-9_-]*$` (lowercase, kebab-case)
2. Verify `purpose` has at least 10 characters
3. If validation fails, report error and stop

## Purpose
Creating new skills and updating the skills repository.

## Input
- Name of the new skill
- Purpose (brief description)
- Input data (what needs to be provided)
- Output data (what is generated)
- Additional preferences for the structure

## Workflow

1. **Analyze the request for a new skill**
   - Determine the role of the new skill in the overall process
   - Identify input and output data
   - Determine at which stage of the workflow it is applied

2. **Check that no such skill already exists**
   - Scan the `skills/` directory for duplicates
   - Check the names and purposes of existing skills
   - If an equivalent skill is found — suggest merging or clarifying the difference

3. **Create the `skills/<name>/SKILL.md` file**
   - Create the directory if it does not exist
   - Create the file using the repository metadata and content conventions
   - Fill in all mandatory sections, including YAML frontmatter and `## Input Validation`

4. **Update `skills/README.md`**
   - Add an entry for the new skill to the catalog
   - Specify the name, purpose, input/output, complexity, and dependencies
   - Preserve the existing catalog order and formatting

5. **Update `README.md`**
   - Add a link to the new skill in the "Skills" section when a per-skill listing exists
   - Preserve formatting and order

6. **Validate consistency**
   - Check that all links are valid (files exist)
   - Check that the catalog in `skills/README.md` is synchronized with the directories in `skills/`
   - Check that every skill file contains valid metadata and an `## Input Validation` section

## New Skill Template

```markdown
# Skill: <Name>

## Purpose
Brief description of the purpose (1-2 sentences)

## Input
- <data 1>
- <data 2>

## Workflow
1. <step 1>
2. <step 2>
...

## <Template Name> Template (if applicable)
<template>

## Output Files
- <file 1> — description
- <file 2> — description

## Rules
- <rule 1>
- <rule 2>
```

## Output Files
- `skills/<name>/SKILL.md` — new skill file
- `skills/README.md` — updated catalog
- `README.md` — updated documentation when the root catalog links to individual skills

## Validation Rules
- Skill directory name matches the repository naming convention
- The catalog in `skills/README.md` matches the directories and `SKILL.md` files in `skills/`
- All skill metadata contains required `name` and `description` fields
- Every skill file contains an `## Input Validation` section
- All documentation links point to existing files
- New skills do not duplicate existing ones
- Dependencies between skills are explicitly stated in `skills/README.md`
