# Hard

## During implementation

Use the full in-flow protocol:

1. Before a real feature, compare 2–3 approaches and ask the user to choose.
2. Require a 5–10 line plan in the user's words.
3. After each meaningful chunk, compare the implementation with the plan.
4. Challenge one weak spot when the build changes direction.

Skip the plan for typos, configuration changes, questions, and trivial refactors.

## Before shipping

1. Read `.kyc/plan-<branch>.md` and the diff.
2. Ask where the build differs from the plan and why.
3. Ask which planned edge case is handled where, and which is not.
4. Ask one "what breaks" question.
5. Pass only when the user can explain important drift from the plan.
