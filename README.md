# pi-dotfiles: mino's agent setup

Everything needed to rebuild mino's coding-agent setup across his two machines:
a headless NixOS home server and an Apple Silicon Mac, sharing one markdown
vault as the agents' memory, with [pi](https://github.com/earendil-works/pi-mono),
Claude Code and T3 Code on top. Last synced with the live setup on 2026-11-18.

This is a sanitized copy, not the live config: nothing loads from this repo.
Secrets, auth files, hostnames and addresses are left out or replaced by
placeholders like `<mac-tailnet-ip>`.

## Architecture

```
                      GitHub  (every push comes from the server)
                         ^
                         | git push
+------------------------+--------------+          +------------------------------+
| minomatNix: server                    |          | Mac: main machine            |
| NixOS, headless, user `<user>`          |          | macOS, zsh, Homebrew         |
|                                       |          |                              |
| ~/Projects/vault-notes (git repo)     |Syncthing | ~/vault (copy, no .git)      |
| ~/vault -> ~/Projects/vault-notes     |<-------->| opened in Obsidian           |
|                                       |Tailscale |                              |
| t3code (T3 Code server)               |          | T3 Code desktop app          |
| pib-chrome (agent Chrome)             |   T3     | pib-chrome (agent Chrome)    |
| gnome-keyring (pi-vault secrets)      |  linked  | keychain + Touch ID secrets  |
| syncthing, tailscaled                 |<-------->| Capri overlay                |
|                                       |  env.    |                              |
| pi, Claude Code                       |          | pi, Claude Code              |
+---------------------------------------+          +------------------------------+
```

How an agent gets its context, on either machine:

| Piece | Loaded | Holds |
|---|---|---|
| `~/vault/AGENTS.md`, linked as `~/.pi/agent/AGENTS.md` and `~/.claude/CLAUDE.md` | every session and subagent | the rules, the two machines, a one-line-per-topic index of notes |
| `<repo>/AGENTS.md` (+ `CLAUDE.md` = `@AGENTS.md`), git-excluded | sessions started in that repo | a pointer to the project's note in `~/vault/projects/` |
| `~/vault/` notes: `projects/`, `machine/`, `tools/`, `lessons.md`, `open-threads.md` | when a task touches the topic | the details: state per machine, how to re-check it, decisions, history |
| skills in `~/.pi/agent/skills/`, `~/.claude/skills/` | name and description at startup, body on demand | procedures with a clear trigger (browser, secrets, delegation, documents) |

The global file stays short because it is paid for on every request of every
session and subagent; everything else is progressive disclosure. `~/Projects`
exists on both machines as separate copies; work moves between them only
through git.

## What is here

| Path | What |
|---|---|
| `shared/AGENTS.md` | Sanitized copy of `~/vault/AGENTS.md`, the one global instruction file. |
| `vault/` | Vault skeleton: `Home.md`, `projects/index.md` (status board), note templates for projects and machines, `lessons.md`, `open-threads.md`. |
| `pi/settings.minomatnix.json`, `pi/settings.mac.json` | Pi settings per machine (model, theme, packages). |
| `pi/mcp-adapter.json` | MCP servers for `pi-mcp-adapter` (Context7 docs). |
| `claude/` | Claude Code settings per machine, and which skills sit where (`claude/README.md`). |
| `skills/` | Skills written for this setup (`delegation`, `vault`, `frontend-taste`); third-party skills listed with their source in `skills/README.md`. |
| `nixos/agents.nix` | The agent-relevant part of the server's NixOS config as an importable module. |
| `mac/README.md` | Mac bootstrap and the `~/.local/bin` tool list. |
| `shell/bashrc-pi-tmux-wrapper.sh` | `pi` wrapper: interactive runs start in their own tmux session (needed by pi-codrive subagent panes). |
| `scripts/link-agents.sh` | Links `~/.pi/agent/AGENTS.md` and `~/.claude/CLAUDE.md` to `~/vault/AGENTS.md`. |
| `scripts/project-pointers.sh` | Writes the git-excluded `AGENTS.md` + `CLAUDE.md` pointer into every repo in `~/Projects` that has a vault note. |
| `scripts/scan-secrets.sh` | Pre-push scan for keys, tokens, tailnet names, Tailscale IPs, device IDs, emails. |

Not here, on purpose: `~/.pi/agent/auth.json`, `models-store.json`,
`~/.claude/.credentials.json`, the vault notes themselves (they describe real
accounts and hold project findings), Syncthing device IDs and tailnet details.

## Install and restore

### Server (NixOS)

1. Base system with Tailscale and sshd working first; never lose those, the box
   is headless. Copy `nixos/agents.nix` to `/etc/nixos/`, add it to `imports`,
   fill the placeholders in its `let` block, commit `/etc/nixos`, then
   `sudo nixos-rebuild switch`. `sudo tailscale up --ssh` once.
2. Agents (npm prefix `~/.local`, on `PATH`):
   ```bash
   npm config set prefix ~/.local
   npm install -g @earendil-works/pi-coding-agent
   # Claude Code: from nixpkgs (in agents.nix) or its native installer
   ```
   T3 Code: install its server and let it write `~/.config/systemd/user/t3code.service`;
   `agents.nix` adds `t3-project-sync`, which registers every `~/Projects` folder.
3. The vault: clone the private vault repo to `~/Projects/vault-notes`, then
   `ln -s ~/Projects/vault-notes ~/vault`. (New vault: copy `vault/` and
   `shared/AGENTS.md` from here into it.)
4. Config from this repo:
   ```bash
   scripts/link-agents.sh
   cp pi/settings.minomatnix.json ~/.pi/agent/settings.json
   cp pi/mcp-adapter.json ~/.pi/agent/mcp-adapter.json   # optional
   cp claude/settings.minomatnix.json ~/.claude/settings.json
   mkdir -p ~/.pi/agent/skills && cp -r skills/delegation ~/.pi/agent/skills/
   cat shell/bashrc-pi-tmux-wrapper.sh >> ~/.bashrc
   ```
5. Clone the local packages that `settings.json` points at into `~/Projects`
   (table below) and pib (its `bin/` linked into `~/.local/bin`), then
   `scripts/project-pointers.sh`.
6. Log in: `pi`, then `/login`; `claude`; `gh auth login`. pi-vault secrets:
   `secret-tool store --label='pi-vault: NAME' service pi-vault account NAME`.
7. Check: `systemctl --user is-active t3code pib-chrome; systemctl is-active syncthing tailscaled`.

### Mac

See `mac/README.md`: Homebrew, Syncthing pairing for `~/vault`, the
`~/.local/bin` tools, then the same `scripts/link-agents.sh` and settings copy
with the `*.mac.json` files.

### Re-syncing this repo

When the live setup changes, copy the changed file over, strip machine state
(`lastChangelogVersion`, `extensionChangelogVersions` in pi settings), and run
`scripts/scan-secrets.sh` before every push. `shared/AGENTS.md` is
`~/vault/AGENTS.md` with the substitutions listed in its header comment.

## Pi packages

Paths are relative to `~/.pi/agent`, so `../../Projects/x` is `~/Projects/x`.
Drop a local entry you do not clone; the npm ones work on their own.

| Package | Server | Mac | What |
|---|---|---|---|
| `npm:@hk_net/pi-usage-bars` | yes | yes | usage and quota footer |
| `npm:@gotgenes/pi-anthropic-auth` | yes | yes | Anthropic subscription auth |
| `npm:pi-mcp-adapter` | yes | yes | MCP client; replaces the built-in `mcp` extension (disabled with `-builtin:mcp`) |
| `npm:cc-safety-net` | yes | yes | blocks destructive shell commands |
| `npm:pi-lens` | yes | yes | LSP, linter and type-check feedback after edits |
| `npm:pi-image-paste` | no | yes | paste images into the chat |
| [pi-terminal-kit](https://github.com/mino-shared/pi-terminal-kit) `packages/pi-codrive` | yes | yes | subagents in tmux panes (`spawn_agent`) |
| [pi-terminal-kit](https://github.com/mino-shared/pi-terminal-kit) `packages/pi-arcoiris-refined` | yes | yes | colour theme |
| [pi-session-control](https://github.com/mino-shared/pi-session-control) | yes | yes | the agent switches its own model and compacts its own context |
| [pi-vault](https://github.com/mino-shared/pi-vault) | yes | yes | run a command with a secret the model never sees (Secret Service on Linux, keychain + Touch ID on macOS) |
| ipod-vault `pi-extension` | yes | no | the same for a password vault on a physical iPod |
| capri-desktop `linux/pi-extension` | no | yes | Capri overlay showing what the agent is doing |

## Related repos

Linked, not copied: [pib](https://github.com/mino-shared/pib) (agent browser
CLI and skill), [pi-vault](https://github.com/mino-shared/pi-vault),
[pi-session-control](https://github.com/mino-shared/pi-session-control),
[pi-terminal-kit](https://github.com/mino-shared/pi-terminal-kit), and
capri-desktop (separate private repo: Capri overlay, Claude Code hooks, the
pi extension).

## Models

`claude-opus-5-5` for all work, in sessions and subagents alike (pi
`defaultModel`, Claude Code `model`).

## History

Started in 2026-08 as the pi config of a Linux laptop that has since been
retired; rebuilt on 2026-11-18 around the server and the Mac.
