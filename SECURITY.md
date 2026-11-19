# Security policy

Please report vulnerabilities privately through [GitHub Security Advisories](https://github.com/minomat180/agent-setup/security/advisories/new) rather than a public issue.

This repo is configuration and three shell scripts. It must never contain
secrets, tokens, auth files, tailnet names, machine addresses, Syncthing device
IDs or email addresses; those are replaced by placeholders such as
`<mac-tailnet-ip>`. The server's hostname and the Mac's login name appear on
purpose, because the rules refer to them. `scripts/scan-secrets.sh` checks for
the rest before every push. If you find one anyway, that is a bug: report it
privately and it will be rotated and removed from history.
