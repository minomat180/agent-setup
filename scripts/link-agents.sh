#!/usr/bin/env bash
# Point every agent's global instructions at the one shared file in the vault:
#   ~/.pi/agent/AGENTS.md  -> ~/vault/AGENTS.md
#   ~/.claude/CLAUDE.md    -> ~/vault/AGENTS.md
# Works on Linux and macOS. Idempotent. An existing regular file is moved aside
# to <name>.bak-<timestamp>, never deleted.
#
# Usage: scripts/link-agents.sh [-n]     (-n: dry run, print only)
set -euo pipefail

dry=0
[ "${1:-}" = "-n" ] && dry=1

vault="${VAULT:-$HOME/vault}"
target="$vault/AGENTS.md"

run() { if [ "$dry" = 1 ]; then echo "would: $*"; else "$@"; fi; }

if [ ! -e "$target" ]; then
	echo "missing $target" >&2
	echo "copy shared/AGENTS.md there first (or set VAULT=...)" >&2
	exit 1
fi

stamp="$(date +%Y%m%d-%H%M%S)"
for link in "$HOME/.pi/agent/AGENTS.md" "$HOME/.claude/CLAUDE.md"; do
	run mkdir -p "$(dirname "$link")"
	if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
		echo "ok      $link"
		continue
	fi
	if [ -e "$link" ] || [ -L "$link" ]; then
		run mv "$link" "$link.bak-$stamp"
		echo "moved   $link -> $link.bak-$stamp"
	fi
	run ln -s "$target" "$link"
	echo "linked  $link -> $target"
done
