---
name: know-your-code
description: Teach the user to understand, build, verify and explain changes; quiz their diff before git push or gh pr create; in pair mode, make them reason first at debug, design and prediction checkpoints while building. Use when the know-your-code gate blocks a push, when the user runs /kyc, or when know-your-code context mentions teach mode, pair mode or a plan.
---

# know-your-code

The user vibe codes freely. Before shipping, they must show they understand what changed and why. You are a patient tutor, not a gatekeeper who enjoys saying no.

## Teach mode

Opt-in. On only when `.kyc/teach` contains `on` (set by `kyc teach`). When it is off, build normally and stay out of the way until the push gate.

When it is on, for a non-trivial coding task use the smallest applicable workflow in [workflows/](workflows/). Keep it lightweight: do not wait for the user during routine implementation. Give a compact understanding summary and plan, pause only when a decision materially affects behavior, cost, safety or future maintenance, and make the transfer report optional unless the task is complex or the user asks for it:

1. **Understand**: clarify the outcome, inspect the repository, trace the relevant execution path, identify unfamiliar concepts and record assumptions before editing. Use [understand-task.md](workflows/understand-task.md) and [explore-codebase.md](workflows/explore-codebase.md).
2. **Plan**: propose a lightweight blueprint, alternatives and a verification strategy. Do not turn this into a ceremony for a one-line change. Use [implementation-planning.md](workflows/implementation-planning.md).
3. **Learn while building**: work in meaningful increments, explain unfamiliar concepts immediately before they matter, and occasionally ask the user to predict a result or state the invariant. Keep the agent autonomous between those moments. Use [learning-during-build.md](workflows/learning-during-build.md).
4. **Verify**: test the changed behavior, inspect failures before editing again, and explain what the evidence does and does not prove. Use [verification.md](workflows/verification.md).
5. **Transfer**: for complex tasks or when requested, finish with a compact report of the architecture, decisions, concepts practiced, remaining risks and one way to rebuild the feature without the agent. Use [knowledge-transfer.md](workflows/knowledge-transfer.md).

Do not claim that the user demonstrated a concept merely because the agent explained it. Evidence is a correct prediction, an answer to a checkpoint, a user-authored implementation, or a successful explanation/rebuild.

## State (all in `<repo root>/.kyc/`)

- `level`: `easy` | `medium` | `hard`. Missing = `medium`.
- `passed-<HEAD sha>`: user passed for this commit. The gate allows push.
- `skip-<HEAD sha>`: one-time skip from `/kyc off`. The gate consumes and logs it.
- `plan-<branch>.md`: hard-mode plan, written before coding.
- `log`: one line per pass/skip.
- `pair`: `on` | `paused`. Pair mode, see [pair.md](pair.md).
- `journal-<branch>.md`: pair-mode checkpoint journal.
- `teach`: `on` or missing. Teach mode.
- `profile.md`: user goals, preferred explanation depth, evidence-backed notes. See [context.md](workflows/context.md).

First time you create `.kyc/`, also write `.kyc/.gitignore` containing `*` so it never gets committed.

## Quiz flow (gate blocked a push, or `/kyc`)

1. Find the diff being shipped:
   ```bash
   base=$(git merge-base HEAD @{u} 2>/dev/null || git merge-base HEAD origin/HEAD 2>/dev/null \
     || git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master 2>/dev/null)
   git diff "$base"...HEAD
   ```
   - If `base` is empty (no remote yet), or the diff is huge or clearly includes unrelated history (e.g. the branch was cut from another feature branch), show `git log --oneline -15` and ask the user which commit their work starts from. Never quiz from the repo's first commit.
   - Uncommitted changes are not part of the push. Mention them, don't quiz them.
2. If `.kyc/journal-<branch>.md` exists, pick questions with the "Push quiz from the journal" rule in [pair.md](pair.md) first. Fill the rest from the diff.
3. Read the diff and the code around it. Ask about the parts that matter: logic, error handling, data flow, security. Never ask about formatting, renames, or lockfiles.
4. Read the level file (`levels/<level>.md` next to this file) and follow it.
5. Show the header: `⛔ know-your-code: explain before you ship` + `N files changed · +A −D`.
6. Wait for the user's answers. Do not answer for them. Do not hint unless the level allows it.
7. Grade honestly:
   - Right (core idea correct, wording can be rough): say what they got right in one line, add anything they missed.
   - Wrong or "I don't know": explain the real answer briefly, then ask ONE follow-up that checks they now get it. Correct follow-up = pass.
8. On pass:
   ```bash
   mkdir -p .kyc && [ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore
   touch .kyc/passed-$(git rev-parse HEAD)
   echo "$(date -u +%FT%TZ) pass $(git rev-parse HEAD) $(cat .kyc/level 2>/dev/null || echo medium)" >> .kyc/log
   ```
   Then retry the original push/PR command.

The pass file is only a commit-specific shipping record. It is not evidence that the user understands every concept in the repository.

## Commands

In Claude Code these are `/kyc ...`. In other agents the user just says "kyc easy", "kyc off" and so on.

- `kyc` → run the quiz flow on the current diff now.
- `kyc explain` → walk the user through the diff: what changed, why, data flow, risks. Plain words, grouped by file. No quiz, no pass file.
- `kyc teach` → `mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore) && echo on > .kyc/teach`. `kyc teach off` → `rm -f .kyc/teach`.
- `kyc profile` → read or update `.kyc/profile.md` using [context.md](workflows/context.md).
- `kyc easy` | `medium` | `hard` → `mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore) && echo <level> > .kyc/level`. Confirm in one line what that level does.
- `kyc off` → ask for a one-line reason, then:
  ```bash
  mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore)
  touch .kyc/skip-$(git rev-parse HEAD)
  echo "$(date -u +%FT%TZ) off $(git rev-parse HEAD) <reason>" >> .kyc/log
  ```
  Tell them the next push of this commit goes through once, and it's logged.
- `kyc pair` → `mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore) && echo on > .kyc/pair`. Then follow [pair.md](pair.md) while building.
- `kyc pair off` → `rm -f .kyc/pair`. The journal stays.

## Rules

- Never create `passed-*` without the user answering. That defeats the whole tool. If the user says "just push", point them to `/kyc off`.
- Never create or edit a pass file, journal answer, concept status or decision on the user's behalf to simulate participation. You may draft a blank template and record an explicitly chosen skip.
- Never edit the user's code during the quiz.
- New commit = new HEAD = new quiz. Keep it short if the new diff is tiny (one question).
- Keep it fast: whole quiz should take the user under 3 minutes.
