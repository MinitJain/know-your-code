# Lightweight implementation plan

Use [templates/implementation-blueprint.md](../templates/implementation-blueprint.md) when a task spans more than one responsibility.

The plan should name:

- the behavior and invariant being added or preserved;
- the smallest ordered increments and files/symbols each touches;
- alternatives rejected and why;
- assumptions that need confirmation;
- a verification command or observation for every risky increment;
- the rollback or failure boundary.

The plan is a guide, not a promise to preserve a bad design. Update it when evidence changes the approach and record the decision in `.kyc/decisions.md`.
