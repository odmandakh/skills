#!/bin/sh
# Symlinks every skills/<name>/ folder in this repo into ~/.claude/skills/<name>,
# and prunes any ~/.claude/skills symlink that points back into this repo but
# whose source folder no longer exists. Safe to re-run any time.

set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"
repo_dir="$(cd "$script_dir/.." && pwd)"
skills_dir="$repo_dir/skills"
target_dir="$HOME/.claude/skills"

# Skills that are intentionally project-scoped and must not be installed globally.
skip_list=""

is_skipped() {
	name="$1"
	for s in $skip_list; do
		[ "$s" = "$name" ] && return 0
	done
	return 1
}

mkdir -p "$target_dir"

linked=""
added=""
skipped=""

for dir in "$skills_dir"/*/; do
	[ -f "$dir/SKILL.md" ] || continue
	name="$(basename "$dir")"
	if is_skipped "$name"; then
		skipped="$skipped $name"
		continue
	fi
	[ -e "$target_dir/$name" ] || added="$added $name"
	ln -sfn "$skills_dir/$name" "$target_dir/$name"
	linked="$linked $name"
done

pruned=""

for entry in "$target_dir"/*; do
	[ -L "$entry" ] || continue
	name="$(basename "$entry")"
	resolved="$(cd "$(dirname "$entry")" && readlink "$name" 2>/dev/null || true)"
	case "$resolved" in
		"$skills_dir"/*)
			[ -d "$entry" ] || {
				rm -f "$entry"
				pruned="$pruned $name"
			}
			;;
	esac
done

echo "Linked:  ${linked:-(none)}"
echo "Skipped: ${skipped:-(none)} (project-scoped)"
echo "Pruned:  ${pruned:-(none)}"

if [ -n "$added$pruned" ]; then
	echo
	echo "New:    ${added:-(none)}"
	echo "Restart any open Claude Code session to pick up added/removed skills"
	echo "(skills are only scanned at session start)."
fi
