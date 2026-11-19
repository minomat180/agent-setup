---
type: hub
updated: YYYY-MM-DD
---
# Projects

One note per project. Each note has: summary, stack and layout, how to run it,
current state with the command that re-checks it, decisions and gotchas,
related notes, history. Every repo in `~/Projects` (both machines) has a
git-excluded `AGENTS.md` pointing at its note here (`scripts/project-pointers.sh`
in agent-setup creates them).

`~/Projects` exists on the server and on the Mac as separate copies: work moves
between them only through git. Each note's "Current state" says which machine
holds what.

Status values: `active`, `paused`, `archived`.

## Agent tooling

| Note | Status | What |
|---|---|---|
| [[agent-setup]] | active | This setup: shared AGENTS.md, vault skeleton, per-machine config. |
| [[agent-chrome]] | active | Agent browser CLI (CDP). |
| [[agent-vault]] | active | Secrets for agents, read with approval. |

## Utilities

| Note | Status | What |
|---|---|---|

## Removed

- `<name>`: where it went, or its origin URL.
