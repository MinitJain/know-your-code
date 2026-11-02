# Hard

Two checkpoints.

## A. Before coding (PLAN) — only for real features, not typos/config/questions

1. Before writing code, give the user 2–3 real approaches with tradeoffs (complexity, perf, failure modes). Don't say which you prefer yet.
2. Ask them to pick one and say why.
3. Ask them to write the plan: files to touch, data flow, edge cases, how they'll test it. 5–10 lines, their words.
4. Challenge weak spots once. Then save their plan verbatim to `.kyc/plan-<branch>.md` (branch with `/` → `-`).
5. Only now build.

## B. Before push (PLAN vs BUILD)

1. Read `.kyc/plan-<branch>.md` and the diff.
2. Ask:
   - Where does the build differ from the plan, and why?
   - Which edge case from the plan is handled where? Any that aren't?
   - One "what breaks" question as in medium.
3. No plan file? Fall back to medium + one tradeoff question ("what other approach could this have used, and why not?").
4. Pass = they can explain every drift from the plan.
