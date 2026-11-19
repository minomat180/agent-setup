# Contributing

This repo describes one person's agent setup: a NixOS server and a Mac sharing
a markdown vault, with Claude Code and T3 Code. It is not maintained as a
general-purpose project, so issues and PRs may sit unanswered.

If you fork it: `shared/AGENTS.md`, `mac/README.md` and `nixos/agents.nix`
describe these two machines and these rules. Copy the structure (a short global
rules file, vault notes per project, git-excluded per-repo pointers, skills
loaded on demand), not the facts.

Before a PR: `shellcheck scripts/*.sh docs/demo/setup.sh` must pass and
`scripts/scan-secrets.sh` must print `clean`.
