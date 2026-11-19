#!/usr/bin/env bash
# Give every git repo in ~/Projects a local, git-excluded pointer to its vault note:
#   <repo>/AGENTS.md  "Project memory and status: ~/vault/projects/<note>.md ..."
#   <repo>/CLAUDE.md  "@AGENTS.md"  (Claude Code reads CLAUDE.md, which imports AGENTS.md)
# and add both to <repo>/.git/info/exclude so they are never committed.
#
# The note is found as ~/vault/projects/<repo>.md, then the lower-case name, then
# ~/vault/projects/<repo>/MEMORY.md. Repos without a note are reported and skipped.
# Existing pointer files are left alone unless -f is given, and -f only rewrites
# files this script wrote (a hand-written AGENTS.md is kept). An
# AGENTS.md or CLAUDE.md that the repo itself tracks in git is never touched.
#
# Usage: scripts/project-pointers.sh [-n] [-f] [projects-dir]
#   -n  dry run    -f  rewrite pointer files this script wrote earlier
set -euo pipefail

dry=0 force=0
while getopts "nf" opt; do
	case "$opt" in
		n) dry=1 ;;
		f) force=1 ;;
		*) echo "usage: $0 [-n] [-f] [projects-dir]" >&2; exit 2 ;;
	esac
done
shift $((OPTIND - 1))

projects="${1:-$HOME/Projects}"
notes="${VAULT:-$HOME/vault}/projects"
[ -d "$projects" ] || { echo "no projects folder: $projects" >&2; exit 1; }

find_note() {
	local name="$1" lower
	lower="$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"
	for rel in "$name.md" "$lower.md" "$name/MEMORY.md" "$lower/MEMORY.md"; do
		[ -f "$notes/$rel" ] && { printf '%s' "$rel"; return 0; }
	done
	return 1
}

# Print paths under $HOME as ~/...
t() { printf '%s' "${1/#"$HOME"/\~}"; }

ours() { head -n 1 "$1" 2>/dev/null | grep -q ': agent pointer (local, not committed)$'; }

tracked() { git -C "$1" ls-files --error-unmatch "$2" >/dev/null 2>&1; }

write() {
	# write <file> <content>
	if [ "$dry" = 1 ]; then echo "  would write $(t "$1")"; else printf '%s\n' "$2" > "$1" && echo "  wrote   $(t "$1")"; fi
}

exclude() {
	local file pattern="$2"
	file="$(git -C "$1" rev-parse --path-format=absolute --git-path info/exclude)"
	grep -qxF "$pattern" "$file" 2>/dev/null && return 0
	if [ "$dry" = 1 ]; then echo "  would exclude $pattern"; return 0; fi
	mkdir -p "$(dirname "$file")"
	printf '%s\n' "$pattern" >> "$file"
}

for repo in "$projects"/*/; do
	repo="${repo%/}"
	name="$(basename "$repo")"
	if [ ! -e "$repo/.git" ]; then
		echo "skip    $name (not a git repo)"
		continue
	fi

	if ! rel="$(find_note "$name")"; then
		echo "skip    $name (no note in $(t "$notes"))"
		continue
	fi
	echo "repo    $name -> projects/$rel"

	if tracked "$repo" AGENTS.md; then
		echo "  AGENTS.md is tracked by the repo, left alone"
	elif [ -e "$repo/AGENTS.md" ] && { [ "$force" = 0 ] || ! ours "$repo/AGENTS.md"; }; then
		echo "  AGENTS.md exists, left alone (-f rewrites it if this script wrote it)"
	else
		write "$repo/AGENTS.md" "# $name: agent pointer (local, not committed)

Project memory and status: \`~/vault/projects/$rel\`. Read it before working
here; when something durable changes, update its current state and the status
line in \`~/vault/projects/index.md\`. Rules and everything else: \`~/vault/AGENTS.md\`."
	fi

	if tracked "$repo" CLAUDE.md; then
		echo "  CLAUDE.md is tracked by the repo, left alone"
	elif [ -e "$repo/CLAUDE.md" ] && [ "$force" = 0 ]; then
		:
	else
		write "$repo/CLAUDE.md" "@AGENTS.md"
	fi

	tracked "$repo" AGENTS.md || exclude "$repo" /AGENTS.md
	tracked "$repo" CLAUDE.md || exclude "$repo" /CLAUDE.md
done
