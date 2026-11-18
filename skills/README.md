# Skills

A skill is a folder with a `SKILL.md`; the agent sees its name and description
at startup and reads the body only when the task matches. Pi loads them from
`~/.pi/agent/skills/`, Claude Code from `~/.claude/skills/`. The same skill can
sit in both (copy or symlink).

## Written for this setup (vendored here)

| Skill | What | Install |
|---|---|---|
| `delegation/` | Rules for spawning subagents: model choice, the BOTTOM LINE report contract, lifecycle, verifying reports. | pi |
| `vault/` | Run one command with a keychain secret without seeing it (`pi-vault list`, `vault-run NAME "reason" -- cmd`). macOS only. | Claude Code on the Mac |
| `frontend-taste/` | Rules against generic, model-made UI and copy, with a screenshot-and-fix loop. Credits taste-skill (MIT). | Claude Code |

## From elsewhere (listed, not vendored)

| Skill | Where installed | Source |
|---|---|---|
| `pib` | pi and Claude Code on the Mac | [mino-shared/pib](https://github.com/mino-shared/pib) (`skill/SKILL.md`); copy it from the repo checkout |
| `pdf`, `xlsx` | pi on the Mac | Anthropic's document skills ([anthropics/skills](https://github.com/anthropics/skills)); proprietary licence, do not vendor |
| `web-search` | pi and Claude Code on the Mac | DuckDuckGo search via `ddgs` + `markitdown` (`pip install --user ddgs markitdown`). Origin not recorded; copy from an existing machine |
| `youtube-transcript` | pi and Claude Code on the Mac | `transcript.js` on `youtube-transcript-plus`; appears to be the one from [badlogic/pi-skills](https://github.com/badlogic/pi-skills) (unverified); run `npm install` in its folder |
| `hallmark` | not on either machine yet | [Nutlope/hallmark](https://github.com/Nutlope/hallmark), `npx skills add nutlope/hallmark -g --agent claude-code` |
| `pptx-maker`, `gmail` | not on either machine yet | mino's own, not ported from the retired laptop |

The server has no pi skills installed yet (`~/.pi/agent/skills` does not exist
there as of 2026-11-18). To give it the Mac's set: copy `delegation/` from here
and the others from their sources.

Skill bodies that call scripts use absolute paths (`/Users/<user>/.claude/skills/...`);
adjust them when installing on the other machine.
