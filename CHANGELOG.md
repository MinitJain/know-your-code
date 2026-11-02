# Changelog

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
