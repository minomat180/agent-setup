# The Mac

Apple Silicon, macOS 27, zsh, Homebrew in `/opt/homebrew`. mino's main machine:
he works here, Obsidian shows the vault here. No GitHub credentials by choice:
code reaches GitHub by pushing from the server.

## Bootstrap

What is known from the 2026-11-18 snapshot; a full `brew list` was not captured.

```bash
# Homebrew, then:
brew install syncthing
brew services start syncthing          # the vault copy, see "Vault" below
brew install colima                    # containers (service installed, not running)
npm install -g @earendil-works/pi-coding-agent   # pi; on the Mac /opt/homebrew/bin/pi -> ~/.pi/agent/bin/pi
# Claude Code: /opt/homebrew/bin/claude
# T3 Code: the desktop app, with pi added as a provider; its CLI is ~/.t3/bin/t3
```

Then, from a checkout of this repo:

```bash
mkdir -p ~/vault ~/.pi/agent ~/.claude
cp shared/AGENTS.md ~/vault/AGENTS.md   # skip if Syncthing already brought it
scripts/link-agents.sh
cp pi/settings.mac.json ~/.pi/agent/settings.json
cp pi/mcp-adapter.json ~/.pi/agent/mcp-adapter.json
cp claude/settings.mac.json ~/.claude/settings.json
cp -R skills/delegation ~/.pi/agent/skills/
cp -R skills/vault skills/frontend-taste ~/.claude/skills/
scripts/project-pointers.sh
```

Log in again: `pi` then `/login`; `claude` and its login flow.

## Vault

`~/vault` is a live two-way Syncthing copy of the server's vault repo, without
`.git`. Syncthing finds the server by its tailnet address only (no relays, no
discovery). Pair by adding the Mac's device ID to the server's
`nixos/agents.nix` (`macDeviceId`) and accepting the `vault-notes` folder on the
Mac with path `~/vault`. Obsidian opens `~/vault`. Agents on the Mac write only
there; commits happen on the server.

## Tools in `~/.local/bin`

| Tool | What | Source |
|---|---|---|
| `pib`, `pib-chrome` | Agent browser CLI and the agent Chrome it drives | symlinks into [mino-shared/pib](https://github.com/mino-shared/pib) `bin/` (Mac branch `feature/macos`) |
| `pi-vault` | Store and list secrets in the login keychain; every read asks for Touch ID | symlink into [mino-shared/pi-vault](https://github.com/mino-shared/pi-vault) `macos/pi-vault-keychain` (macOS branch not pushed yet) |
| `vault-run` | Run one command with one secret in `$PI_VAULT_SECRET`, output redacted | small standalone script on the Mac, not in any repo yet |
| `capri`, `capri-ctl`, `capri-login` | Capri desktop overlay for agent activity | symlinks into capri-desktop (separate private repo; `linux/bin/`, `macos/bin/`) |
| `t3` | T3 Code CLI | symlink to `~/.t3/bin/t3` |
| `tailscale` | wrapper for the Tailscale app's CLI | small local script |
| `fd` | file finder | prebuilt binary |

Project-specific helpers that also live there are not part of this setup.

## Reaching the Mac

From a T3 thread on the server the Mac is a linked environment
(`t3_environment_links`, then `delegate_task` with `target.environmentId`).
Plain ssh from the server to the Mac is refused.
