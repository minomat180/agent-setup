# Security policy

Please report vulnerabilities privately through [GitHub Security Advisories](https://github.com/mino-shared/agent-setup/security/advisories/new) rather than a public issue.

This repo is configuration only. It must never contain secrets, tokens, auth
files, hostnames or addresses of the machines, Syncthing device IDs, or email
addresses; those are replaced by placeholders such as `<mac-tailnet-ip>`.
`scripts/scan-secrets.sh` checks for them before every push. If you find one
anyway, that is a bug: report it privately and it will be rotated and removed
from history.
