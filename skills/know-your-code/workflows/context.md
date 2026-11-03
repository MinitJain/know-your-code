# Persistent learning context

Create `.kyc/` and its `.gitignore` before writing context. The ignore file must contain `*`; these notes are local learning state, not project source.

Use these files:

- `profile.md`: goals, preferred explanation depth, and evidence-backed preferences. Do not infer expertise from a single correct answer.
- `concepts.md`: one row per concept with status, evidence and a next practice. Status can only move `unfamiliar → introduced → practiced → demonstrated`; it can move back when later evidence shows a gap.
- `decisions.md`: date/task, decision, alternatives considered, reason, counterargument, outcome and follow-up. Record outcomes, not just the agent's recommendation.
- `plans/<short-task>.md`: optional blueprint, assumptions, affected files and verification plan. Use a safe descriptive name, not user input pasted into a shell command.

When the user explicitly says they already know a concept, treat that as a preference to reduce explanation, not as `demonstrated` evidence. Ask for a smaller prediction or explanation instead of repeating a lesson. Never store secrets, tokens, personal data or full command output unnecessarily.
