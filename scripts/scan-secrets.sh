#!/usr/bin/env bash
# Pre-push check: this repo must never hold secrets or identifying network details.
# Scans tracked and staged files (or the paths given) for API keys, tokens, private
# keys, tailnet names, Tailscale (100.64.0.0/10) addresses, Syncthing device IDs and
# email addresses. Exit 1 on any hit.
#
# Usage: scripts/scan-secrets.sh [path...]
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2

if [ "$#" -gt 0 ]; then
	files=("$@")
else
	mapfile -t files < <(git ls-files --cached --others --exclude-standard)
fi
# The scanner itself contains the patterns.
mapfile -t files < <(printf '%s\n' "${files[@]}" | grep -v '^scripts/scan-secrets.sh$')

patterns=(
	'sk-[A-Za-z0-9_-]{20,}'                 # OpenAI / Anthropic style keys
	'sk-ant-[A-Za-z0-9_-]{10,}'
	'gh[pousr]_[A-Za-z0-9]{30,}'            # GitHub tokens
	'github_pat_[A-Za-z0-9_]{20,}'
	'AKIA[0-9A-Z]{16}'                      # AWS access key id
	'xox[abpr]-[A-Za-z0-9-]{10,}'           # Slack
	'AIza[0-9A-Za-z_-]{35}'                 # Google API key
	'-----BEGIN [A-Z ]*PRIVATE KEY-----'
	'tskey-[A-Za-z0-9-]+'                   # Tailscale auth keys
	'[a-z0-9-]+\.ts\.net'                   # tailnet hostnames
	'\btail[0-9a-f]{5,}\b'                  # tailnet names
	'\b100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]{1,3}\.[0-9]{1,3}\b'   # CGNAT / Tailscale IPs
	'\b[A-Z0-9]{7}(-[A-Z0-9]{7}){7}\b'      # Syncthing device IDs
	'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'   # email addresses
	'"(access|refresh)_?[Tt]oken"[[:space:]]*:'
)
allow='noreply@anthropic\.com|git@github\.com'

hits=0
for p in "${patterns[@]}"; do
	out="$(grep -HnIE -- "$p" "${files[@]}" 2>/dev/null | grep -vE "$allow" || true)"
	if [ -n "$out" ]; then
		echo "== pattern: $p"
		echo "$out"
		hits=1
	fi
done

for f in "${files[@]}"; do
	case "$(basename "$f")" in
		auth.json|models-store.json|.credentials.json|*.pem|*.key|.env|.env.*)
			echo "== forbidden file: $f"; hits=1 ;;
	esac
done

if [ "$hits" = 0 ]; then echo "scan-secrets: clean (${#files[@]} files)"; fi
exit "$hits"
