# know-your-code

Before you run `git push` or `gh pr create`, the user must explain what changed and why.

1. Check for `.kyc/passed-$(git rev-parse HEAD)` at the repo root. If it exists, push.
2. If `.kyc/skip-$(git rev-parse HEAD)` exists, delete it, append `<date> skip <sha>` to `.kyc/log`, and push.
3. Otherwise follow [`skills/know-your-code/SKILL.md`](skills/know-your-code/SKILL.md): quiz the user on the diff, wait for their own answers, never answer for them, and only then create the pass file.

Agents with hooks (Claude Code, Codex, Cursor) enforce this with `hooks/gate.sh`. Everywhere else this file is the only guard, so follow it.
