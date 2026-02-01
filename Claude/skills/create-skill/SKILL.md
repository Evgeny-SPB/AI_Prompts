---
name: create-skill
description: Create a new Claude Code skill (slash command). Use when user wants to add a new reusable skill.
---

Create a new Claude Code skill in the user's personal skills folder.

## Steps

1. **Ask the user** for:
   - Skill name (becomes the `/slash-command`, use kebab-case)
   - Brief description of what the skill does
   - Detailed instructions for the skill behavior

2. **Create the skill directory**:
   ```
   ~/.claude/skills/<skill-name>/
   ```

3. **Create `SKILL.md`** with YAML frontmatter and markdown instructions:
   ```markdown
   ---
   name: <skill-name>
   description: <one-line description>. Use when <trigger condition>.
   ---

   <detailed instructions for Claude to follow when skill is invoked>
   ```

## Rules

1. The skill directory goes in `~/.claude/skills/` (personal, available across all projects).
2. The `name` field in frontmatter becomes the `/slash-command`.
3. The `description` field should end with a "Use when..." clause so Claude knows when to auto-suggest it.
4. Skill names use kebab-case (e.g., `add-headers`, `run-tests`).
5. Instructions should be clear and self-contained so Claude can follow them without extra context.
6. After creating the skill, inform the user they can invoke it with `/<skill-name>`.
