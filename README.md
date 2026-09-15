# Dom's skills

Personal [Claude Code](https://claude.com/claude-code) skills.

Each folder under `skills/` is a self-contained skill — a `SKILL.md` (frontmatter + instructions) plus any bundled references, templates, or scripts it needs. Claude Code auto-discovers skills and decides when to use one based on its `description`. This repo is the source of truth; skills are installed into `~/.claude/skills/` via symlink so edits here take effect immediately.

## Available skills

| Skill | Description |
|-------|-------------|
| [`cpp-pro`](skills/cpp-pro) | Writes, optimizes, and debugs C++ applications using modern C++20/23 features, template metaprogramming, and high-performance systems techniques |
| [`leetcode-teacher`](skills/leetcode-teacher) | Interactive LeetCode-style teacher for technical interview preparation across Python/TypeScript/Kotlin/Swift |
| [`leetcode-import`](skills/leetcode-import) | Scaffolds a new LeetCode problem or contest question from a pasted LeetCode page into the `personal/leetcode` repo's C++ harness (structure only, never the solve logic) |

> Company/work-specific skills (UBCab v4 backend tooling) live in the separate `mezorn-com/backend-skills` repo, not here.
>
> `leetcode-import` is project-scoped — it assumes the `personal/leetcode` repo's own scripts and conventions, so it's only symlinked into that repo's `.claude/skills/`, not into `~/.claude/skills/` globally.

## Install

```bash
git clone git@github.com-personal:odmandakh/skills.git
cd skills
```

Symlink the skills you want (edits in this repo flow straight through):

```bash
# one skill
ln -s "$(pwd)/skills/cpp-pro" ~/.claude/skills/cpp-pro

# all skills in this repo
for d in skills/*/; do
  ln -sfn "$(pwd)/$d" ~/.claude/skills/"$(basename "$d")"
done
```

Reload any open Claude Code window afterwards so it picks up new skills.

## Add a new skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter (`name` matching the folder, and a `description` specific enough for Claude to know when to trigger it — include the phrasings people will actually type).
2. Bundle supporting files (templates, references, scripts) in subfolders and link to them from `SKILL.md` with relative links.
3. Symlink it into `~/.claude/skills/` and test it in a real repo.
4. Add a row to the table above.

## Benchmarking

- [Cross-model skill benchmarking workflow](docs/skill-benchmarking.md)
- [Benchmark run history](docs/skill-benchmark-runs.md)
