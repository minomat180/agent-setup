# <machine> (<role>)

Hardware, OS, user, shell. What it is for, and the one thing an agent must never
break on it (for a headless box: networking, Tailscale, sshd).

## Reaching it

- From the other machine: <how>. Hostnames and addresses stay in the private
  vault, never in a public repo.

## Setup

- System config: where it lives and how changes are applied.
- Services: name, what it does, how it is started.
- Agents: pi version, Claude Code version, default model, packages (see
  `~/.pi/agent/settings.json`), skills in `~/.pi/agent/skills` and `~/.claude/skills`.
- `~/vault`: the git repo here, or the Syncthing copy.

## Check

- `<one command per claim above>`

## History

- YYYY-MM-DD: <what changed>.
