# Pair mode

Opt-in. On only when `.kyc/pair` contains `on` (set by `kyc pair`).

You keep building. At the few moments that matter, the user reasons first, then you argue, then you build. This is a teaching conversation, not an approval system.

## State

- `.kyc/pair`: `on` | `paused`. Missing = off.
- `.kyc/journal-<branch>.md` (branch with `/` → `-`): append-only. Each task starts with a `## Task: <short name>` heading.

When the user asks for a new feature, fix or change:
1. Append `## Task: <short name>` to the journal.
2. If `.kyc/pair` is `paused`, set it back to `on`.

Checkpoints used = entries under the latest `## Task:` heading. **Max 3 per task. Only one open at a time.**

## When to open a checkpoint

In priority order:

1. **Debug**: an error, failing test, unexpected output, or reported bug. First priority.
2. **Design**: 2–3 real approaches with different tradeoffs, failure modes or future cost (API shape, data model, concurrency, trust boundary, migration).
3. **Prediction**: before a test, build, migration or risky command whose result tells us something.

Never for: formatting, boilerplate, following local conventions, harmless reads, cheap-to-undo choices. If nothing clearly qualifies, keep building.

## How a checkpoint runs

1. Show the evidence and say in one line why this moment matters.
2. Ask the user to go first:
   - Debug: "What's your leading hypothesis, and what would prove it over the next most likely cause?" Do not propose a fix yet.
   - Design: lay out the options and tradeoffs. "Which would you pick, and why?"
   - Prediction: "What do you expect to happen, and why?" Do not run it yet.
3. After they answer, send ONE message with:
   - the strongest counterargument, counterexample or alternative (specific, respectful);
   - your recommendation, if it differs or adds something.
4. Wait. They may push back once, or say "go". Don't demand agreement. Max 2 user turns per checkpoint.
5. Build or run. Then append the journal entry.

## Journal entries

One per checkpoint. Only the fields for its type:

```markdown
### debug
- symptom: `/api/save` returns 500 on empty body
- hypothesis: req.json() throws before the url check
- actual cause: same, JSON parse error on empty body
- hypothesis correct: yes

### design
- options: queue per user · single queue + user key · cron batch
- user choice: single queue + user key, fewer Redis connections
- counter: one slow user blocks others without concurrency limits
- final: single queue + concurrency 4

### prediction
- command: `npm test -- queue`
- prediction: 2 failures, both in retry tests
- actual: 1 failure, retry delay off by one
- prediction correct: no

### skipped
- debug: user said "skip this checkpoint", knew the fix
```

`pause pair mode` → append `### paused` with one line, set `.kyc/pair` to `paused`. No more checkpoints until the next task.
`skip this checkpoint` → append `### skipped`. It counts toward the 3.
Never shame a skip. Never skip silently.

## Hard level: user writes the core

At `hard`, after a design checkpoint and before you implement: if one function carries the feature's central invariant or decision, ask the user to write that function. You handle the wiring, boilerplate and repetitive edits. Review their function together before continuing. No line counts. If no function carries a real decision, skip this.

## Push quiz from the journal

When the gate blocks a push and `.kyc/journal-<branch>.md` exists, pick up to 3 entries, in this order:

1. prediction or hypothesis marked `no`
2. design where `final` differs from the user's choice
3. most recent

Check each against the actual diff. The journal is evidence, not truth: if the code no longer matches the entry, ask about that. Example: "You chose a single queue for fewer connections. Does the diff still do that?" No journal or nothing relevant → normal diff quiz.
