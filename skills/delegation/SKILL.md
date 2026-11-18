---
name: delegation
description: Rules for spawning subagents and delegating tasks - when to delegate, which model tier, what must be in the prompt (the BOTTOM LINE contract), lifecycle and cleanup, and verifying a report before relaying it. Read before the first spawn_agent / delegate call of a session, and when a subagent report arrives.
---

# Delegating work to subagents

Two decisions every time: **should this be delegated**, and **which model does
it actually need**. Then three duties: a prompt that binds, a lifecycle you
own, and a report you verify.

Which tool: in a plain pi session (inside tmux) it is `spawn_agent`, with
`agent_pane` / `agent_report` to look in. Inside a T3 Code thread, follow T3's
own orchestration instructions for which tool to call (there is no tmux pane
there); everything below about model choice, the prompt contract and
verification applies either way.

How to use `spawn_agent`. Two decisions every time: **should this be delegated**,
and **which model does it actually need**.

### When to delegate

Spawn a subagent when a task is independent of the current main-thread work —
perf/infra investigation, research, cleanup, a separate area of a codebase,
anything long-running. Keep working on the main thread while it runs, rather
than doing it inline and serializing everything. Don't delegate work that needs
tight back-and-forth with mino, or that depends on state the main thread is
mid-way through changing.

### Pick the model: mino's rule (set 2026-11-12)

- **`claude-opus-5-5` for everyday work**, including ordinary delegated tasks.
- **`claude-fable-5-2` only for a special task with high impact on the
  project itself**: a decision or change that shapes the project, where a wrong
  answer is expensive to undo. Judge by the impact on the project, not by how
  important or useful the project is overall. Say why when you pick it.
- Older tiers (Haiku / Sonnet / Opus 5) are not part of the rule. Do not pick a
  cheaper model to save money unless mino asks for it.
- Ids change: confirm them with `session_control` action `list_models` before
  spawning, and pass the full id.

### Writing the prompt

Always give the subagent explicit **hard constraints**: what not to touch, what
not to kill, which git state to leave alone, which paths are off-limits
(networking, Tailscale and sshd on the server, mino's daily browsers, the agent browser's lifecycle). Subagents don't
inherit the current session's context — restate the relevant background,
absolute paths, and the machine facts they'll need.

Also tell them: **report and stop**. Don't implement follow-up recommendations
unless explicitly asked. A subagent that keeps "helpfully" going after its
report is burning tokens on unapproved work.

### Demand an actionable close-out — paste this into every subagent prompt

**This must go in the prompt. Relying on AGENTS.md alone does not work — tested
2026-09.** A Haiku subagent was spawned with a plain task and no mention of the
report format. Its pane header confirmed `[Context] .pi/agent/AGENTS.md` had
loaded, so it *had* the rule — and it still answered plainly with no BOTTOM LINE
block. A standing instruction buried in a long context file loses to the
immediate prompt, especially on cheaper models. Keep the rule in AGENTS.md (it
costs nothing and helps on stronger models), but **always paste the contract
into the spawn prompt** — that's the channel that actually binds.

The failure mode is a subagent returning a wall of interesting findings with the
"so what" buried in it, leaving the orchestrator to do the synthesis. That's
where errors creep in — contradictions get smoothed over and recommendations get
relayed without their premises checked. Force the subagent to land the plane.

Include this block verbatim in the prompt:

```
END YOUR REPORT WITH A SECTION HEADED "BOTTOM LINE" CONTAINING EXACTLY THESE
FIVE ITEMS, IN THIS ORDER, KEPT SHORT:

1. VERDICT — one sentence. What is actually true, and does it matter?
2. RECOMMENDED ACTION — one specific decidable thing, or explicitly "no action
   needed". If it is a change, give exact file paths, line numbers and the
   precise edit or command. If there are several options, name the ONE you
   recommend and why, don't hand back a menu.
3. CONFIDENCE — high / medium / low, plus the single fact that would most
   change your answer if it turned out different.
4. VERIFIED vs ASSUMED — which claims you confirmed by reading files or running
   commands (cite what you ran), and which are inference. Be strict: if you did
   not open the file, it is assumed.
5. NOT DONE / STILL OPEN — what you deliberately left alone, and anything you
   hit that someone else needs to decide.

If you cannot fill one of these in honestly, say so explicitly rather than
padding it. "Confidence: low, I could not access the DB" is a useful answer; a
confident-sounding guess is not.
```

Why each item earns its place:

- **Verdict** stops the burying of the conclusion.
- **Recommended action** forces a decision instead of a menu. A subagent that
  hands back three options has moved the work, not done it.
- **Confidence + the fact that would change it** tells you whether to act now or
  go verify first, and tells you exactly what to verify.
- **Verified vs assumed** is the one that matters most: it's what lets the
  orchestrator relay findings honestly and know which premises still need
  checking (see "Verify subagent output before relaying it" below).
- **Not done / still open** surfaces the things that otherwise silently vanish
  between agents.

When several subagents cover overlapping ground, compare their BOTTOM LINE
blocks directly. Differences in the VERIFIED vs ASSUMED item are usually where
an apparent contradiction actually resolves.

### Lifecycle: you are responsible for every subagent you spawn

A spawned subagent does **not** stop when it sends a report. It keeps running,
keeps costing money, and keeps holding resources until the pane is killed.
Track them like processes, because that's what they are.

**Rules:**

- **When a subagent is done, kill its pane.** Don't leave it idling.
  `tmux kill-pane -t %N`. Verify with `tmux list-panes -a`.
- **"Completed" or "error" in a report does not mean the process exited.** A
  report is one turn's output, not a lifecycle event. Always verify with
  `tmux list-panes -a` before assuming a subagent is gone. An `error` status
  (e.g. `Request timed out`) frequently means one request failed while the
  agent carried on working.
- **Check on long-running subagents instead of forgetting them.** If one has
  been going a while, `agent_pane read` it and judge whether what it's doing is
  still worth the spend. The pane footer shows accumulated cost and the model —
  use it. Kill anything that has drifted off-task or is past the point of
  diminishing returns.
- **After killing, check for what it leaked.** A subagent that used the
  browser may have left tabs open: `pib tabs` marks other sessions' tabs with
  `o`, and `pib gc --older 0` closes the tabs of every session but your own
  (only do that when no other session is working in the browser; plain
  `pib gc` only touches sessions idle for 6 h). pib itself has no daemon and
  no temp profiles, so there are no browser processes to hunt down. Never
  stop or restart the agent browser (`pib-chrome`) as part of cleanup.

### Verify subagent output before relaying it

A subagent's report is a **claim**, not a result. Don't pass its findings to
mino as established fact without checking the load-bearing ones yourself —
especially anything he's about to act on.

- **Spot-check the specific, checkable claims.** File contents, line numbers,
  counts, sizes, whether a thing exists. These are cheap: one `grep`, one `ls`,
  one `du`. If a subagent says "line 21 gates X on Y", open line 21.
- **Never relay a recommendation you haven't validated the premise of.** If it
  says "change this config because the file does Z", read the file and confirm
  it does Z.
- **When two subagents disagree, resolve it — don't smooth it over.** If one
  reports "nothing to fix" and another finds a critical problem in the same
  area, that's a real conflict. Work out which is right (timing? different
  scope? one is wrong?) instead of inventing a plausible-sounding
  reconciliation and moving on.
- **Attribute honestly.** Say which parts you verified and which you're passing
  through unverified. "The subagent reports X, I confirmed X" and "the subagent
  reports X" are different statements and mino relies on the difference.

Reading the files yourself also catches what the subagent missed — in the
incident below, verifying its Sentry analysis surfaced an unconditional
top-level import in `next.config.mjs` that **both** subagents had overlooked,
which changed which fix was correct.

**Real incident this came from (2026-09):** a subagent was spawned on Opus for a
perf investigation, reported `error: Request timed out`, and was assumed dead.
It was still running an hour later, had delivered its report, then kept going
and started building an unrequested tool — reaching **$1.77**. Its own testing
spawned 23 Chrome processes and left an orphan with a stale `/tmp` profile. A
parallel subagent doing comparable work on Sonnet cost **$0.14**: 12x less.
Three separate lessons in one incident — wrong model tier, no lifecycle
tracking, and no post-kill leak check.

Separately, note that **the orchestrator's own browser use leaked the
same way** (with the old `agent_browser` tool): an orphaned session from a screenshot call was the actual root cause
of a system-wide slowdown (software-GL Chrome holding an HMR websocket open
against a dev server). Check for orphans after heavy browser use, not just after
killing subagents.

## Reports you did not ask for

Spawning subagents isn't exclusive to the orchestrator. Mino can and does spawn
a `pi` subagent pane himself, in parallel, while the main session is busy on
something else, to get a quick answer without waiting. When that pane
finishes, its report is delivered into the main session as a
`SUBAGENT %N completed with status completed` message.

**Treat these as legitimate by default** — this is a normal, expected feature,
not an anomaly. No need to re-litigate provenance each time one shows up.
Still apply the existing "verify subagent output before relaying it" standard
farther below to the *content* (spot-check specific/checkable claims before
acting on them or repeating them as fact) — the channel is trusted, the
contents of any one report still aren't automatically ground truth. Confirmed
2026-09: one such report claimed live GPU utilization/power-draw numbers and
"mid-inference right now" that turned out to be stale/wrong when checked
directly — normal staleness, not a sign the channel itself is compromised.

There's no `/btw`-style slash command for this (checked 2026-09: the
extension SDK's `registerCommand` can't invoke `spawn_agent`, that's a
model-level tool only, not exposed to extension code) — mino spawns the pane
himself through pi's normal pane controls, same as the orchestrator would.
