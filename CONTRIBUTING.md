# Contributing

This repo describes one person's agent setup (a NixOS server and a Mac sharing
a markdown vault, with Claude Code and T3 Code). It is not maintained as a
general-purpose project. Issues and PRs are welcome but may sit unaddressed.

If you fork it: `shared/AGENTS.md` and the machine notes describe mino's
machines and rules. Copy the structure (short global file, vault notes,
per-project pointers, skills on demand), not the facts.

Before a PR: run `scripts/scan-secrets.sh`; it must report clean. No emojis in
files or commit messages.
