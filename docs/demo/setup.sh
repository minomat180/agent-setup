#!/usr/bin/env bash
# Builds the throwaway home directory the README demo runs in: a vault with two
# project notes, four folders in ~/Projects, and one file with a leaked tailnet
# address. Nothing here is real. Usage: docs/demo/setup.sh <demo-home> <repo>
set -euo pipefail
demo="$1" repo="$2"
if [ -e "$demo" ] && [ -n "$(ls -A "$demo")" ]; then
	echo "demo home must be missing or empty: $demo" >&2
	exit 1
fi
mkdir -p "$demo/vault/projects/shop" "$demo/Projects"
ln -s "$repo" "$demo/agent-setup"
cp "$repo/shared/AGENTS.md" "$demo/vault/AGENTS.md"
printf '# blog\n\nStatic site. State, decisions, history.\n' > "$demo/vault/projects/blog.md"
printf '# shop\n\nLarger project, so it has a folder.\n' > "$demo/vault/projects/shop/MEMORY.md"
for p in blog shop scratch; do
	git init -q "$demo/Projects/$p"
	git -C "$demo/Projects/$p" -c user.name=demo -c user.email=demo@localhost \
		commit -q --allow-empty -m init
done
mkdir -p "$demo/Projects/downloads"
# A note that should never be pushed. Built from pieces so this script itself
# does not trip the scanner.
net="ts" ip="100.$((100 + 4)).7.12"
printf 'server: box.tail%s.%s.net (%s)\n' "c0ffee" "$net" "$ip" > "$demo/Projects/blog/notes.md"
git -C "$demo/Projects/blog" add notes.md
