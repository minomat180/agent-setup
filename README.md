# agent-setup: mino's agent setup

Everything needed to rebuild mino's coding-agent setup across his two machines:
a headless NixOS home server and an Apple Silicon Mac, sharing one markdown
vault as the agents' memory, with Claude Code and T3 Code on top. Last synced
with the live setup on 2026-11-19.

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
| agent-chrome (agent Chrome, CDP)      |   T3     | agent-chrome (agent Chrome)  |
| gnome-keyring (agent-vault secrets)   |  linked  | keychain + Touch ID secrets  |
| syncthing, tailscaled                 |<-------->| Capri overlay                |
|                                       |  env.    |                              |
| Claude Code                           |          | Claude Code                  |
+---------------------------------------+          +------------------------------+
```

How an agent gets its context, on either machine:

| Piece | Loaded | Holds |
|---|---|---|
| `~/vault/AGENTS.md`, linked as `~/.claude/CLAUDE.md` | every session and subagent | the rules, the two machines, a one-line-per-topic index of notes |
| `<repo>/AGENTS.md` (+ `CLAUDE.md` = `@AGENTS.md`), git-excluded | sessions started in that repo | a pointer to the project's note in `~/vault/projects/` |
| `~/vault/` notes: `projects/`, `machine/`, `tools/`, `lessons.md`, `open-threads.md` | when a task touches the topic | the details: state per machine, how to re-check it, decisions, history |
| skills in `~/.claude/skills/` | name and description at startup, body on demand | procedures with a clear trigger (browser, secrets, UI work) |

The global file stays short because it is paid for on every request of every
session and subagent; everything else is progressive disclosure. `~/Projects`
exists on both machines as separate copies; work moves between them only
through git.

## What is here

| Path | What |
|---|---|
| `shared/AGENTS.md` | Sanitized copy of `~/vault/AGENTS.md`, the one global instruction file. |
| `vault/` | Vault skeleton: `Home.md`, `projects/index.md` (status board), note templates for projects and machines, `lessons.md`, `open-threads.md`, `ideas.md`. |
| `claude/` | Claude Code settings per machine, and which skills sit where (`claude/README.md`). |
| `skills/` | `frontend-taste`, written for this setup; every other skill listed with its source in `skills/README.md`. |
| `nixos/agents.nix` | The agent-relevant part of the server's NixOS config as an importable module (Tailscale, agent Chrome, headless keyring, T3 project sync, Syncthing). |
| `mac/README.md` | Mac bootstrap, Syncthing pairing and the `~/.local/bin` tool list. |
| `scripts/link-agents.sh` | Links `~/.claude/CLAUDE.md` to `~/vault/AGENTS.md`. |
| `scripts/project-pointers.sh` | Writes the git-excluded `AGENTS.md` + `CLAUDE.md` pointer into every repo in `~/Projects` that has a vault note. |
| `scripts/scan-secrets.sh` | Pre-push scan for keys, tokens, tailnet names, Tailscale IPs, device IDs, emails. |

Not here, on purpose: `~/.claude/.credentials.json`, `settings.local.json`,
the vault notes themselves (they describe real accounts and hold project
findings), Syncthing device IDs and tailnet details.

## Install and restore

### Server (NixOS)

1. Base system with Tailscale and sshd working first; never lose those, the box
   is headless. Copy `nixos/agents.nix` to `/etc/nixos/`, add it to `imports`,
   fill the placeholders in its `let` block, commit `/etc/nixos`, then
   `sudo nixos-rebuild switch`. `sudo tailscale up --ssh` once.
   This installs Claude Code (`claude-code` from nixpkgs), the agent Chrome
   service, the headless keyring and Syncthing.
2. T3 Code: install its server and let it write
   `~/.config/systemd/user/t3code.service`; `agents.nix` adds
   `t3-project-sync`, which registers every `~/Projects` folder.
3. The vault: clone the private vault repo to `~/Projects/vault-notes`, then
   `ln -s ~/Projects/vault-notes ~/vault`. (New vault: copy `vault/` and
   `shared/AGENTS.md` from here into it.) Syncthing then shares it with the Mac
   (see "Vault sync" below).
4. Config from this repo:
   ```bash
   scripts/link-agents.sh
   cp claude/settings.minomatnix.json ~/.claude/settings.json
   mkdir -p ~/.claude/skills
   ln -s ~/vault/skills/frontend-taste ~/.claude/skills/frontend-taste
   ```
5. Clone [agent-chrome](https://github.com/mino-shared/agent-chrome) and
   [agent-vault](https://github.com/mino-shared/agent-vault) into `~/Projects`.
   Link agent-chrome's `bin/` (`agent-chrome`, `agent-chrome-ctl`) into
   `~/.local/bin` and its skill into `~/.claude/skills/agent-chrome`; run
   agent-vault's `./install.sh` (links `agent-vault` and `vault-run` into
   `~/.local/bin`, its skill to `~/.claude/skills/vault`). Then run
   `scripts/project-pointers.sh`.
6. Log in: `claude`; `gh auth login`. Secrets for agents go into the headless
   keyring: `secret-tool store --label='agent-vault: NAME' service agent-vault account NAME`.
7. Check: `systemctl --user is-active t3code agent-chrome; systemctl is-active syncthing tailscaled`.

### Mac

See `mac/README.md`: Homebrew, Syncthing pairing for `~/vault`, the
`~/.local/bin` tools (agent-chrome, agent-vault, vault-run), then the same
`scripts/link-agents.sh` and settings copy with `claude/settings.mac.json`.

### Vault sync

`~/vault` lives as a git repo on the server and as a live two-way Syncthing
copy (no `.git`) on the Mac. Syncthing talks over the tailnet only: no relays,
no global or local discovery, GUI on localhost. The server side is declarative
in `nixos/agents.nix` (fill `macDeviceId` and `macAddress`); on the Mac, accept
the `vault-notes` folder with path `~/vault`. Commits happen on the server.

### Re-syncing this repo

When the live setup changes, copy the changed file over, replace user paths
with `$HOME` and machine names or addresses with placeholders, and run
`scripts/scan-secrets.sh` before every push. `shared/AGENTS.md` is
`~/vault/AGENTS.md` with the substitutions listed in its header comment.

## Related repos

Linked, not copied: [agent-chrome](https://github.com/mino-shared/agent-chrome)
(agent browser CLI, `agent-chrome-ctl` service script and skill),
[agent-vault](https://github.com/mino-shared/agent-vault) (`agent-vault`,
`vault-run` and the `vault` skill: secrets in the Secret Service or macOS
keychain, used without the model seeing them), and capri-desktop
(separate private repo: the Capri overlay and its Claude Code hook).

## Models

`claude-opus-5-5` for all work, in sessions and subagents alike (Claude Code
`model`, T3 Code thread defaults).

## History

- 2026-08: started as the pi config (repo `pi-dotfiles`) of a Linux laptop that has since been retired.
- 2026-11-18: rebuilt around the server and the Mac.
- 2026-11-19: renamed to agent-setup; Claude Code and T3 Code only.
