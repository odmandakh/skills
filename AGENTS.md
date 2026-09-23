This file provides guidance to AI coding agents working in this repository.

## What this repository is

- A personal library of [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills) — not an application.
- Each `skills/<name>/` folder is a self-contained skill: `SKILL.md` (required) plus optional `references/`, `templates/`, `scripts/`.
- Skills here are installed via symlink into `~/.claude/skills/<name>/`; editing a file in this repo changes the live skill immediately (no build/copy step).

## Editing rules

1. `SKILL.md` frontmatter `name` must match the folder name (kebab-case).
2. `description` is the only thing Claude sees when deciding whether to trigger the skill unprompted — keep it specific and include concrete trigger phrases.
3. Keep `SKILL.md` itself lean; put long reference material in `references/*.md` or `templates/*` and link to it with relative paths so the skill works regardless of where it's symlinked from.
4. When adding, renaming, or removing a skill folder, update the table in `README.md` in the same change, and run `scripts/install.sh` to sync `~/.claude/skills/` (it symlinks new/renamed folders and prunes stale links for removed ones).
5. Do not add UBCab / Mezorn work-specific skills here — those belong in the separate `mezorn-com/backend-skills` repo.
6. `scripts/install.sh` skips any skill listed in its `skip_list` (currently empty — all skills here are installed globally, even project-scoped ones like `leetcode-import`). Only add a skill to that list if it must never be visible outside one specific project.
