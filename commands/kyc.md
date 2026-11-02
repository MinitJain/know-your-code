---
description: Quiz, explain, set level, or skip the know-your-code gate
argument-hint: "[explain | easy | medium | hard | off]"
---

Use the know-your-code skill. Argument: `$ARGUMENTS`

- empty → run the quiz flow on the current diff now.
- `explain` → walk the user through the diff: what changed, why, data flow, risks. Plain words, grouped by file. No quiz, no pass file.
- `easy` | `medium` | `hard` → `mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore) && echo <level> > .kyc/level`. Confirm in one line what that level does.
- `off` → ask the user for a one-line reason, then:
  ```bash
  mkdir -p .kyc && ([ -f .kyc/.gitignore ] || echo '*' > .kyc/.gitignore)
  touch .kyc/skip-$(git rev-parse HEAD)
  echo "$(date -u +%FT%TZ) off $(git rev-parse HEAD) <reason>" >> .kyc/log
  ```
  Tell them the next push of this commit goes through once, and it's logged.
- anything else → show the usage line from argument-hint.
