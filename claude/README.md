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
  Capri overlay shows what Claude Code is doing. `pi-lens-analyze` runs after
  edits (`--hook`) and at turn end (`--turn-end`).
- **Plugins**: `cc-safety-net` from the `kenryu42/cc-marketplace` marketplace
  (blocks destructive shell commands; pi loads the same tool as `npm:cc-safety-net`).

The hook paths were `/Users/<user>/Projects/...` in the live file; here they use
`$HOME`, which the hook shell expands. Hooks need `capri-desktop` cloned to
`~/Projects` and `pi-lens-analyze` on `PATH` (it ships with `npm:pi-lens`).

The server runs Claude Code mostly through T3 Code and has no hooks or plugins;
its settings only pick the theme and the model alias. Not copied:
`settings.local.json` (per-machine permission grants), `.credentials.json`.

## Skills

| Skill | Mac | Server | Source |
|---|---|---|---|
| `pib` | yes | no | [mino-shared/pib](https://github.com/mino-shared/pib), `skill/SKILL.md` |
| `vault` | yes | no | this repo, `skills/vault/` (Mac only: macOS keychain via `vault-run`) |
| `frontend-taste` | yes | no | this repo, `skills/frontend-taste/` |
| `web-search` | yes | no | see `skills/README.md` |
| `youtube-transcript` | yes | no | see `skills/README.md` |

On the server, Claude Code has only the skills that come with it; agent work
there that needs skills goes through pi.
