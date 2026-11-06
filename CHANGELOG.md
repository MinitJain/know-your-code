# Changelog

## 0.4.1 — 2026-11-06

- Docs: the Claude Code command is `/know-your-code:kyc ...` (plugin commands are namespaced; plain `/kyc` never existed). Saying "kyc pair" also works.
- Skill pre-approves `Read` on its own plugin folder while the skill is active, and re-invokes itself in later turns, so loading `pair.md`, levels and workflows doesn't prompt in default permission mode.

## 0.4.0 — 2026-11-03

- Teach mode (on by default, `/kyc teach off` to turn off): understand the repository before coding, learn during meaningful increments, verify with evidence, finish with knowledge transfer.
- Workflows and templates for codebase exploration, plans, verification and transfer reports, loaded only when needed.
- `/kyc profile`: local learning profile in `.kyc/profile.md`, updated only from evidence.

## 0.3.0 — 2026-11-03

- Pair mode (`/kyc pair`): while building, the user reasons first at debug, design and prediction checkpoints. Max 3 per task, one at a time. Logged to `.kyc/journal-<branch>.md`.
- Push quiz asks about journal entries first (wrong predictions, overridden choices), checked against the diff.
- Hard level: user writes the function that carries the feature's central decision.
- `hooks/hard-plan.sh` → `hooks/nudge.sh`: also reminds the agent while pair mode is on or paused.

## 0.2.0 — 2026-11-02

- Codex plugin (`.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`). Same hooks as Claude Code.
- Cursor support: `hooks/cursor-hooks.json`; the gate reads Cursor's `beforeShellExecution` input and answers with a JSON deny.
- `AGENTS.md` fallback for agents without hooks.
- Gate block message carries the quiz rules, so agents without the skill still run a fair quiz.
- `/kyc` logic moved into `SKILL.md` so every agent gets the commands.
- README: demo GIF, fixed install line (`know-your-code@know-your-code`), agent support table.
- Icon, GitHub Actions test workflow.
- Gate catches more push forms: subshells, absolute paths, `sudo`, `env`, `command`, `time`, VAR=x prefixes, quoted `git -C` args; ignores `echo git push`. Portable regex (no `\x27`).
- Quiz diff base: upstream, then origin default branch; asks the user instead of quizzing from the first commit.

## 0.1.0 — 2026-11-02

- PreToolUse gate blocks `git push` / `gh pr create` until `.kyc/passed-<HEAD>` exists.
- Levels: easy (MCQ + hints), medium (what/why/what breaks, default), hard (plan before coding, plan vs build at push).
- `/kyc`, `/kyc explain`, `/kyc easy|medium|hard`, `/kyc off` (one-time skip, logged).
- `tests/gate.test.sh`.
