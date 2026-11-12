# pi-dotfiles

Config to recreate my [Pi](https://github.com/earendil-works/pi-mono) coding-agent
setup on a new machine. Last synced with the live setup on 2026-11-12.

## How the setup is organised

The main lesson from three months of use: the global `AGENTS.md` must stay
short. It is sent with every request of every session and every subagent, so
everything in it is paid for constantly, and a long file gets followed worse,
not better. Mine had grown to 757 lines (20k prompt tokens per request); it is
now about 160 lines (under 10k tokens including Pi's own system prompt).

The layout that replaced it (progressive disclosure):

| Piece | Loaded | Holds |
|---|---|---|
| `~/.pi/agent/AGENTS.md` (symlink to `~/vault/AGENTS.md`) | every session | hard rules plus a one-line-per-topic index of notes |
| `~/vault/` notes (`machine/`, `tools/`, `projects/`, `lessons.md`, `open-threads.md`) | only when a task touches the topic | the details: how things are set up, why rules exist, unfinished work |
| `~/.pi/agent/skills/*/SKILL.md` | name and description at startup, body on demand | procedures with a clear trigger (browser, delegation, slides, mail) |
| `<project>/AGENTS.md` | sessions started in that project | project rules; can point at project memory kept in the repo (git-excluded) |

`~/vault` is plain markdown; Obsidian is only the viewer.

## What's here

- `pi/settings.json`: Pi settings (model defaults, theme, packages). Drop into
  `~/.pi/agent/settings.json`.
- `pi/AGENTS.md.example`: my current global context file. It is specific to
  this machine (Void Linux, ThinkPad T480, mango compositor); copy the shape,
  not the facts.
- `vault/Home.md.example`: the vault's front page, describing the note layout
  and conventions.
- `skills/delegation/SKILL.md`: rules for spawning subagents (model choice, the
  report contract every child must end with, lifecycle, verifying reports).
  Install to `~/.pi/agent/skills/delegation/`.
- `shell/bashrc-pi-tmux-wrapper.sh`: a bash function that wraps `pi` so
  interactive runs always start inside their own tmux session (needed for
  `pi-codrive`'s subagent panes); print-mode calls pass through untouched.
  Each launch gets a unique session name, and it avoids `exec` so leaving Pi
  drops back to a shell. Append to `.bashrc`.

## What's deliberately excluded

- `~/.pi/agent/auth.json` (live provider credentials). Log in again with `/login`.
- `~/.pi/agent/models-store.json` (model cache, regenerates).
- The vault notes themselves and project memory: they describe one machine and
  contain account details.

## Install

Requires Node.js 20+ and npm.

```bash
npm install -g @earendil-works/pi-coding-agent
mkdir -p ~/.pi/agent ~/vault
cp pi/settings.json ~/.pi/agent/settings.json
cp -r skills/* ~/.pi/agent/skills/
# write ~/vault/AGENTS.md for the new machine, then:
ln -s ~/vault/AGENTS.md ~/.pi/agent/AGENTS.md
cat shell/bashrc-pi-tmux-wrapper.sh >> ~/.bashrc
```

## Packages in settings.json

Paths are relative to `~/.pi/agent`, so `../../Projects/x` is `~/Projects/x`.
Drop any local entry you do not clone; the npm ones work on their own.

| package | type | what |
|---|---|---|
| `npm:@hk_net/pi-usage-bars` | npm | usage and quota footer |
| `npm:@gotgenes/pi-anthropic-auth` | npm | Anthropic subscription auth |
| `npm:pi-image-paste` | npm | paste images into the chat |
| `npm:pi-mcp-adapter` | npm | MCP client (servers installed on demand); the built-in `mcp` extension is disabled in favour of it |
| `../../Projects/pi-session-control` | local repo | lets the agent switch its model and compact its own context; auto-compacts at 180k tokens or 82% of the window |
| `../../Projects/pi-local-delegate` | local repo | hands cheap subtasks to a local Ollama box |
| `../../Projects/pi-terminal-kit/packages/pi-codrive` | local repo | subagents in tmux panes (`spawn_agent`) |
| `../../Projects/pi-terminal-kit/packages/pi-arcoiris-refined` | local repo | colour theme |
| `../../Projects/pi-vault` | local repo | secrets from the Secret Service keyring (`secret-tool`), injected into one command without the model seeing them |
| `../../Projects/ipod-vault/pi-extension` | local repo | the same for a password vault on a physical iPod; drop it without that hardware |
| `../../Projects/capri-desktop/linux/pi-extension` | local repo | desktop overlay showing what the agent is doing |

Removed since the last sync: `pi-agent-browser-native` (replaced by `pib`,
below) and `pi-lens`.

## Browser

The agent drives a real, logged-in Chrome through `pib`, a small CDP command-line
tool with a Pi skill (`~/Projects/pib`, not published yet). It replaced the
`agent_browser` tool, which launched a detectable headless Chrome and failed
9% of its calls. `pib-chrome start` (run from the compositor's autostart)
keeps one Chrome on `127.0.0.1:9222`; each Pi session works in its own tab.

## Models

`claude-opus-5-5` for everyday work, in sessions and subagents alike;
`claude-fable-5-2` only for special tasks with high impact on the project.
