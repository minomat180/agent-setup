# Vault

Shared memory between mino and his coding agents. Plain markdown; Obsidian is
only the viewer. Agents read and write these files directly.

## How it works

`AGENTS.md` in this folder is the one file every agent session loads on both
machines (`~/.pi/agent/AGENTS.md` and `~/.claude/CLAUDE.md` are symlinks to it).
It holds the rules and an index: one line per topic, pointing at a note here.
Agents read a note only when the task touches it, and update the note (not
AGENTS.md) when something changes.

The vault is organised by project: each repo in `~/Projects` has a local,
git-excluded `AGENTS.md` pointing at its note in `projects/`.

| Path | What | Written by |
|---|---|---|
| `AGENTS.md` | Rules + index. Keep it short; it is paid for in every session. | mino, agents (index lines only) |
| `machine/` | One note per machine: `minomatnix.md` (server, vault home), `macbook.md` (main machine). | agents |
| `tools/` | Tools and helpers (vault sync, pib, secrets, pi, T3 Code). | agents |
| `projects/` | One note per project; start at `projects/index.md`, the status board. | both |
| `reference/` | Longer reference material (repo setup checklist, ...). | both |
| `lessons.md` | Why the rules exist: the incidents and measurements behind them. | agents |
| `open-threads.md` | Unfinished work to pick up later. | agents |
| `todos.md` | mino's todo list. | mino |

Agent skills (procedures with their own trigger, loaded on demand) live in
`~/.pi/agent/skills/` and `~/.claude/skills/` per machine; what is installed
where is in the machine notes.

## Conventions

- A note says what is true **now** and how to check it. Dated history goes at the bottom.
- Absolute dates, never "last week".
- If a note names a file or flag, verify it still exists before trusting it.
- `[[wikilinks]]` are fine; they are Obsidian's own syntax.

## Map

- Rules and index: [[AGENTS]], [[lessons]], [[open-threads]], [[todos]]
- Machines: [[minomatnix]], [[macbook]]
- Projects: [[projects/index|Projects]]
