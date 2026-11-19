# Claude Code

Global instructions: `~/.claude/CLAUDE.md` is a symlink to `~/vault/AGENTS.md`
on both machines (`scripts/link-agents.sh`). Per-project instructions come from
each repo's git-excluded `CLAUDE.md`, which only contains `@AGENTS.md`
(`scripts/project-pointers.sh`).

## Settings

| File | Machine | Install to |
|---|---|---|
| `settings.minomatnix.json` | server | `~/.claude/settings.json` |
| `settings.mac.json` | Mac | `~/.claude/settings.json` |

The Mac file holds the real configuration:

- **Hooks**: every lifecycle event goes to Capri's hook
  (`node "$HOME/Projects/capri-desktop/hooks/capri-hook.js"`, async), so the
  Capri overlay shows what Claude Code is doing. `pi-lens-analyze` (from the
  third-party npm package `pi-lens`, installed globally and standalone) runs
  after edits (`--hook`) and at turn end (`--turn-end`); the same package is
  registered as an MCP server (`claude mcp add pi-lens -- pi-lens-mcp`).
- **Plugins**: `cc-safety-net` from the `kenryu42/cc-marketplace` marketplace
  (blocks destructive shell commands).

The hook paths were `/Users/<user>/Projects/...` in the live file; here they use
`$HOME`, which the hook shell expands. Hooks need `capri-desktop` cloned to
`~/Projects` and `npm install -g pi-lens`. Drop either hook block if you do
not use it.

The server runs Claude Code mostly through T3 Code and has no hooks or plugins;
its settings only pick the theme and the model alias. Not copied:
`settings.local.json` (per-machine permission grants), `.credentials.json`.

## Skills

Skills live in `~/.claude/skills/<name>/`. Skills shared by both machines live
in the vault at `~/vault/skills/<name>/` and are symlinked in, so Syncthing
keeps them current on the Mac.

| Skill | Mac | Server | Source |
|---|---|---|---|
| `frontend-taste` | yes | yes | `~/vault/skills/frontend-taste` (symlink); a copy is in this repo, `skills/frontend-taste/` |
| `agent-chrome` | yes | install with agent-chrome | [mino-shared/agent-chrome](https://github.com/mino-shared/agent-chrome), `skill/` (symlink) |
| `vault` | yes | with agent-vault | [mino-shared/agent-vault](https://github.com/mino-shared/agent-vault) `skill/`, installed by its `install.sh` |
| `web-search` | yes | no | see `skills/README.md` |
| `youtube-transcript` | yes | no | see `skills/README.md` |
