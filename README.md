# Dom's skills

Personal [Claude Code](https://claude.com/claude-code) skills.

Each folder under `skills/` is a self-contained skill — a `SKILL.md` (frontmatter + instructions) plus any bundled references, templates, or scripts it needs. Claude Code auto-discovers skills and decides when to use one based on its `description`. This repo is the source of truth; skills are installed into `~/.claude/skills/` via symlink so edits here take effect immediately.

## Available skills

| Skill | Description |
|-------|-------------|
| [`cpp-pro`](skills/cpp-pro) | Writes, optimizes, and debugs C++ applications using modern C++20/23 features, template metaprogramming, and high-performance systems techniques |
| [`cpp-coding-standards`](skills/cpp-coding-standards) | C++ coding standards based on the C++ Core Guidelines — enforces modern, safe, idiomatic practices when writing, reviewing, or refactoring C++ |
| [`java-springboot`](skills/java-springboot) | Best practices for developing applications with Spring Boot |
| [`leetcode-teacher`](skills/leetcode-teacher) | Interactive LeetCode-style teacher for technical interview preparation across Python/TypeScript/Kotlin/Swift |
| [`leetcode-import`](skills/leetcode-import) | Scaffolds a new LeetCode problem or contest question from a pasted LeetCode page into the `personal/leetcode` repo's C++ harness (structure only, never the solve logic) |
| [`frontend-design`](skills/frontend-design) | Guidance for distinctive, intentional visual design when building or reshaping UI — aesthetic direction, typography, and non-templated choices |
| [`ui-ux-pro-max`](skills/ui-ux-pro-max) | UI/UX design intelligence for web, mobile, and desktop — searchable styles, palettes, font pairings, UX guidelines, icons, and stack-specific implementation |
| [`find-skills`](skills/find-skills) | Helps discover and install agent skills when asked "is there a skill for X" or similar |

> Company/work-specific skills (UBCab v4 backend tooling) live in the separate `mezorn-com/backend-skills` repo, not here.
>
> `leetcode-import` assumes the `personal/leetcode` repo's own scripts and conventions — it's installed globally like the rest, but only actually does anything useful inside that repo.

## Install

```bash
git clone git@github.com-personal:odmandakh/skills.git
cd skills
./scripts/install.sh
```

`scripts/install.sh` symlinks every `skills/<name>/` folder into `~/.claude/skills/<name>` (edits in this repo flow straight through), and prunes any stale symlink left behind by a skill folder you removed or renamed. Re-run it any time you add, rename, or remove a skill. (It has an internal `skip_list` for any future skill that shouldn't be installed globally — currently empty.)

Reload any open Claude Code window afterwards so it picks up new skills.

## Add a new skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter (`name` matching the folder, and a `description` specific enough for Claude to know when to trigger it — include the phrasings people will actually type).
2. Bundle supporting files (templates, references, scripts) in subfolders and link to them from `SKILL.md` with relative links.
3. Run `./scripts/install.sh` and test it in a real repo.
4. Add a row to the table above.

## Benchmarking

- [Cross-model skill benchmarking workflow](docs/skill-benchmarking.md)
- [Benchmark run history](docs/skill-benchmark-runs.md)
