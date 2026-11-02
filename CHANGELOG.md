# Changelog

## 0.1.0 — 2026-11-02

- PreToolUse gate blocks `git push` / `gh pr create` until `.kyc/passed-<HEAD>` exists.
- Levels: easy (MCQ + hints), medium (what/why/what breaks, default), hard (plan before coding, plan vs build at push).
- `/kyc`, `/kyc explain`, `/kyc easy|medium|hard`, `/kyc off` (one-time skip, logged).
- `tests/gate.test.sh`.
