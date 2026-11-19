#!/usr/bin/env bash
# Point Claude Code's global instructions at the one shared file in the vault:
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

# Print paths under $HOME as ~/...
t() { printf '%s' "${1/#"$HOME"/\~}"; }
run() { if [ "$dry" = 1 ]; then echo "would: ${*//"$HOME"/\~}"; else "$@"; fi; }

if [ ! -e "$target" ]; then
	echo "missing $(t "$target")" >&2
	echo "copy shared/AGENTS.md there first (or set VAULT=...)" >&2
	exit 1
fi

stamp="$(date +%Y%m%d-%H%M%S)"
link="$HOME/.claude/CLAUDE.md"
run mkdir -p "$(dirname "$link")"
if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
	echo "ok      $(t "$link")"
	exit 0
fi
if [ -e "$link" ] || [ -L "$link" ]; then
	run mv "$link" "$link.bak-$stamp"
	[ "$dry" = 1 ] || echo "moved   $(t "$link") -> $(t "$link.bak-$stamp")"
fi
run ln -s "$target" "$link"
[ "$dry" = 1 ] || echo "linked  $(t "$link") -> $(t "$target")"
