---
name: know-your-code
description: Quiz the user on their diff before git push or gh pr create, and in hard mode make them plan before coding. Use when the know-your-code gate blocks a push, when the user runs /kyc, or when hard-mode context asks for a plan.
---

# know-your-code

The user vibe codes freely. Before shipping, they must show they understand what changed and why. You are a patient tutor, not a gatekeeper who enjoys saying no.

## State (all in `<repo root>/.kyc/`)

- `level`: `easy` | `medium` | `hard`. Missing = `medium`.
- `passed-<HEAD sha>`: user passed for this commit. The gate allows push.
- `skip-<HEAD sha>`: one-time skip from `/kyc off`. The gate consumes and logs it.
- `plan-<branch>.md`: hard-mode plan, written before coding.
- `log`: one line per pass/skip.

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
2. Read the diff and the code around it. Ask about the parts that matter: logic, error handling, data flow, security. Never ask about formatting, renames, or lockfiles.
3. Read the level file (`levels/<level>.md` next to this file) and follow it.
4. Show the header: `⛔ know-your-code: explain before you ship` + `N files changed · +A −D`.
5. Wait for the user's answers. Do not answer for them. Do not hint unless the level allows it.
6. Grade honestly:
   - Right (core idea correct, wording can be rough): say what they got right in one line, add anything they missed.
   - Wrong or "I don't know": explain the real answer briefly, then ask ONE follow-up that checks they now get it. Correct follow-up = pass.
7. On pass:
   ```bash
   mkdir -p .kyc && [ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore
   touch .kyc/passed-$(git rev-parse HEAD)
   echo "$(date -u +%FT%TZ) pass $(git rev-parse HEAD) $(cat .kyc/level 2>/dev/null || echo medium)" >> .kyc/log
   ```
   Then retry the original push/PR command.

## Commands

In Claude Code these are `/kyc ...`. In other agents the user just says "kyc easy", "kyc off" and so on.

- `kyc` → run the quiz flow on the current diff now.
- `kyc explain` → walk the user through the diff: what changed, why, data flow, risks. Plain words, grouped by file. No quiz, no pass file.
- `kyc easy` | `medium` | `hard` → `mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore) && echo <level> > .kyc/level`. Confirm in one line what that level does.
- `kyc off` → ask for a one-line reason, then:
  ```bash
  mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore)
  touch .kyc/skip-$(git rev-parse HEAD)
  echo "$(date -u +%FT%TZ) off $(git rev-parse HEAD) <reason>" >> .kyc/log
  ```
  Tell them the next push of this commit goes through once, and it's logged.

## Rules

- Never create `passed-*` without the user answering. That defeats the whole tool. If the user says "just push", point them to `/kyc off`.
- Never edit the user's code during the quiz.
- New commit = new HEAD = new quiz. Keep it short if the new diff is tiny (one question).
- Keep it fast: whole quiz should take the user under 3 minutes.
