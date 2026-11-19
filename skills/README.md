# Skills

A skill is a folder with a `SKILL.md`; Claude Code sees its name and
description at startup and reads the body only when the task matches. It loads
them from `~/.claude/skills/`. Skills meant for both machines live in the vault
at `~/vault/skills/<name>/` and are symlinked into `~/.claude/skills/` on each
machine.

## Written for this setup (vendored here)

| Skill | What | Install |
|---|---|---|
| `frontend-taste/` | Rules against generic, model-made UI and copy, with a screenshot-and-fix loop. Credits taste-skill (MIT). | copy into `~/vault/skills/`, symlink into `~/.claude/skills/` on both machines |

## From elsewhere (listed, not vendored)

| Skill | Where installed | Source |
|---|---|---|
| `vault` | Claude Code (Mac; server once agent-vault is installed there) | [mino-shared/agent-vault](https://github.com/mino-shared/agent-vault) `skill/`; its `install.sh` links it to `~/.claude/skills/vault` |
| `agent-chrome` | Claude Code on the Mac | [mino-shared/agent-chrome](https://github.com/mino-shared/agent-chrome) (`skill/SKILL.md`); symlink `~/.claude/skills/agent-chrome` to the checkout's `skill/` |
| `web-search` | Claude Code on the Mac | DuckDuckGo search via `ddgs` + `markitdown` (`pip install --user ddgs markitdown`). Origin not recorded; copy from an existing machine |
| `youtube-transcript` | Claude Code on the Mac | `transcript.js` on `youtube-transcript-plus`; origin not recorded; copy from an existing machine and run `npm install` in its folder |
| `pdf`, `xlsx`, `docx`, `pptx` | built into Claude Code | Anthropic's document skills ([anthropics/skills](https://github.com/anthropics/skills)); proprietary licence, do not vendor |
| `hallmark` | not on either machine yet | [Nutlope/hallmark](https://github.com/Nutlope/hallmark), `npx skills add nutlope/hallmark -g --agent claude-code` |
| `pptx-maker`, `gmail` | not on either machine yet | mino's own, not ported from the retired laptop |

Skill bodies that call scripts use absolute paths (`/Users/<user>/.claude/skills/...`);
adjust them when installing on the other machine.
