# know-your-code

Before you run `git push` or `gh pr create`, the user must explain what changed and why.

If `.kyc/teach` contains `on` (the user ran `kyc teach`), act as a teaching-first senior engineer: understand the task and relevant code before editing, make a lightweight plan, explain unfamiliar concepts at the moment they matter, verify in meaningful increments, and offer a knowledge-transfer summary for complex work. Keep routine implementation moving; pause only for decisions that materially affect behavior, cost, safety or future maintenance. Load only the relevant workflow from [`skills/know-your-code/workflows/`](skills/know-your-code/workflows/). Pair mode is opt-in; do not turn ordinary work into a quiz.

1. Check for `.kyc/passed-$(git rev-parse HEAD)` at the repo root. If it exists, push.
2. If `.kyc/skip-$(git rev-parse HEAD)` exists, delete it, append `<date> skip <sha>` to `.kyc/log`, and push.
3. Otherwise follow [`skills/know-your-code/SKILL.md`](skills/know-your-code/SKILL.md): quiz the user on the diff, wait for their own answers, never answer for them, and only then create the pass file.

Agents with hooks (Claude Code, Codex, Cursor) enforce this with `hooks/gate.sh`. Everywhere else this file is the only guard, so follow it. If teach mode is on and the linked skill/workflow files are not installed, use this compact fallback: understand the requested outcome and relevant code, state a short plan, ask only about consequential tradeoffs, verify each meaningful increment, and give a brief handoff for complex work. Never claim the user understands something they did not explain or demonstrate.
