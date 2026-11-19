# Terminal recording for the README. Render from the repo root:
#   DEMO_HOME=<empty dir> vhs docs/demo/demo.tape
# The demo runs in a throwaway home built by docs/demo/setup.sh.
Output docs/demo.gif

Set Shell bash
Set FontSize 18
Set Width 1200
Set Height 860
Set Padding 24
Set TypingSpeed 35ms
Set Theme "GitHub Dark"

Hide
Type `docs/demo/setup.sh "$DEMO_HOME" "$PWD" && export HOME="$DEMO_HOME" && cd ~ && export PS1='\[\e[2m\]\w\[\e[0m\] $ ' && clear` Enter
Sleep 1s
Show

Type "# one rules file for every session: link ~/.claude/CLAUDE.md to the vault" Enter
Type "agent-setup/scripts/link-agents.sh" Sleep 300ms Enter
Sleep 1.5s
Type "# point every repo with a vault note at that note" Enter
Type "agent-setup/scripts/project-pointers.sh" Sleep 300ms Enter
Sleep 2.5s
Type "cat Projects/blog/AGENTS.md" Sleep 300ms Enter
Sleep 3s
Type "# the pointers are git-excluded; only the real change shows up" Enter
Type "cd Projects/blog && git status --short" Sleep 300ms Enter
Sleep 2s
Type "# the pre-push scan flags a tailnet name and address" Enter
Type "~/agent-setup/scripts/scan-secrets.sh" Sleep 300ms Enter
Sleep 4s
