# pi-dotfiles

Config to recreate my [Pi](https://github.com/earendil-works/pi-mono) CLI
coding-agent setup on a new machine.

## What's here

- `pi/settings.json` — Pi settings: model defaults, theme, installed
  extensions. Drop into `~/.pi/agent/settings.json`.
- `pi/AGENTS.md.example` — my *current machine's* global context file (Void
  Linux / ThinkPad T480 / mango compositor specifics). This is **not
  portable as-is** — it's an example of the format and level of detail to
  aim for, not something to copy verbatim onto a different machine. Write a
  fresh one for the new box (see "Writing your own AGENTS.md" below).
- `shell/bashrc-pi-tmux-wrapper.sh` — a bash function that wraps `pi` so
  interactive invocations always run inside a per-project tmux session
  (needed for `pi-codrive`'s `/spawn` subagent feature), while passing
  through non-interactive/print-mode calls untouched. Append into `.bashrc`.
  Each interactive launch gets its own uniquely-named session (`-2`, `-3`, …
  on collision) so a second terminal starts a fresh, independent Pi instead
  of mirroring into the first, and it deliberately avoids `exec` so that
  exiting Pi with Ctrl+D drops back to a shell prompt rather than closing
  the terminal.
- `shell/bashrc-pi-agent-browser-env.sh` — caps inline screenshot attachments
  from the `agent_browser` tool
  (`PI_AGENT_BROWSER_INLINE_IMAGE_MAX_BYTES`). Screenshots are the largest
  avoidable context cost; above the bound the capture still saves to disk
  with full metadata and only the base64 attachment is skipped. Append into
  `.bashrc`.

## What's deliberately excluded

- `~/.pi/agent/auth.json` — live provider credentials. Never committed.
  Recreate via `pi` login flows (`/login` in-session, or provider env vars /
  API keys).
- `~/.pi/agent/models-store.json` — cached model catalog, regenerates
  automatically on first run / `pi update`.

## Install (any Linux, incl. Debian)

Requires Node.js (v20+) and npm.

```bash
npm install -g @earendil-works/pi-coding-agent
mkdir -p ~/.pi/agent
cp pi/settings.json ~/.pi/agent/settings.json
```

Write your own `~/.pi/agent/AGENTS.md` (see below), then log in to at least
one model provider:

```bash
pi            # first run offers /login, or:
pi auth       # check/print credential status
```

### Extensions referenced in settings.json

`settings.json`'s `packages` list mixes npm packages (portable, install
automatically) and local path references to my other repos (only relevant
if you also clone those):

| package | type | notes |
|---|---|---|
| `npm:@hk_net/pi-usage-bars` | npm | usage/quota footer bar |
| `npm:@gotgenes/pi-anthropic-auth` | npm | Anthropic auth helper |
| `npm:pi-image-paste` | npm | paste images into chat |
| `npm:pi-agent-browser-native` | npm | browser automation tool (needs a Chrome/Chromium binary on the target machine) |
| `npm:pi-lens` | npm | real-time LSP / linter / formatter / type-check feedback |
| `npm:pi-mcp-adapter` | npm | MCP client adapter — lets Pi talk to MCP servers |
| `../../projects/pi-session-control` | local repo | lets the agent switch its own model tier and compact its own context |
| `../../projects/pi-local-delegate` | local repo | offloads cheap subtasks to a local Ollama box over the network |
| `../../projects/pi-terminal-kit/packages/pi-codrive` | local repo | tmux subagent spawning (`/spawn`) — clone `pi-terminal-kit` as a sibling of this repo's parent, or drop from settings if unwanted |
| `../../projects/pi-terminal-kit/packages/pi-arcoiris-refined` | local repo | color theme — same repo as above |
| `../../projects/pi-vault` | local repo | Secret Service (`secret-tool`/gnome-keyring) backed vault tool — needs `libsecret`/`gnome-keyring` on target machine |
| `../../projects/ipod-vault/pi-extension` | local repo | vault tied to a physical iPod I own — almost certainly **drop this one** on a new machine unless you also have that hardware |

If you don't want to bring over the local-path extensions, just delete
those entries from `packages` in `settings.json` before copying it in — the
npm ones will keep working fine on their own.

### Shell wrapper

```bash
cat shell/bashrc-pi-tmux-wrapper.sh >> ~/.bashrc
cat shell/bashrc-pi-agent-browser-env.sh >> ~/.bashrc
```

Requires `tmux` installed if you want the per-project session behavior;
falls back to running `pi` directly if `tmux` isn't present.

The second file is independent of tmux — it only sets the `agent_browser`
inline-image bound, and is worth adding on any machine that uses the browser
tool.

## Does this work on Debian?

Yes, with the caveats above:

- **Pi itself**: yes, it's a plain npm-installed Node CLI — no Void/Arch
  specific packaging involved.
- **`pi-vault`**: yes, as long as `gnome-keyring` (or another Secret
  Service provider) and `libsecret-tools` (`secret-tool`) are installed —
  `apt install gnome-keyring libsecret-tools` on Debian.
- **`pi-agent-browser-native`**: yes, needs a real Chrome/Chromium binary
  reachable on the target machine; my "headless-but-headful via `cage`"
  background-mode trick is a Wayland/mango-specific detail documented in
  `AGENTS.md.example`, not required for the extension to work at all — a
  normal visible browser window is fine on Debian if you don't need that.
- **`AGENTS.md.example`**: no — it's this specific machine's memory (Void
  Linux, mango, acpid lid handling, greetd, etc.). Write a new one for the
  new machine describing *its* OS/DE/hardware quirks instead of copying
  this file.
- **`ipod-vault`**: no, it's tied to a specific physical iPod — skip it
  unless recreating that exact hardware setup.

## Writing your own AGENTS.md

Keep it terse and factual — it's injected into every single message of
every session forever (unlike conversation history, it's never
summarized/compacted), so verbosity there is a permanent token tax. Good
contents: OS/DE facts that would otherwise need rediscovering every
session, hard rules (e.g. browser-use guardrails), and a running "small
projects & tools registry" of scripts/configs on that machine. See
`pi/AGENTS.md.example` for the shape, not the specific facts.
