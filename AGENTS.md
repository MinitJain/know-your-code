# know-your-code

The goal is to help the user build at AI speed while understanding important implementation decisions.

During implementation, keep the user in the loop:

1. Before a consequential decision, explain the decision, give 2–3 options with tradeoffs, and let the user choose or ask for more context.
2. After a meaningful code change, give a short checkpoint covering what changed, why this approach was used, and one risk. Do not interrupt routine edits.
3. If implementation diverges from the stated approach, call it out and ask whether the new direction is understood.
4. Before `git push` or `gh pr create`, follow [`skills/know-your-code/SKILL.md`](skills/know-your-code/SKILL.md) for the final ship checkpoint.

When hooks are available, `hooks/gate.sh` enforces the ship checkpoint and `hooks/learning-loop.sh` nudges the agent after meaningful diff changes.

The user must answer in their own words. Never create a pass file without their answer. If they need to ship immediately, ask them to use `kyc off`; the skip is logged and applies once.
