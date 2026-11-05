# Easy

During implementation:

- Give short passive checkpoints after meaningful changes.
- At important decisions, use 2–3 plain-language options with brief tradeoffs.
- Do not require an answer for routine implementation.

Before shipping:

1. Ask 3 multiple-choice questions about the important behavior in the diff.
2. After each pick: wrong → give a hint and let the user pick again. Second miss → explain.
3. Ask: "In one sentence, why did this change need to happen?"
4. Pass = all 3 questions resolved plus a sensible one-line why.
