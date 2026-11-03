# Stage B — Understandable Execution

Build in coherent increments. Before each increment, tell the user what responsibility is changing, what data/control flow matters, and what will demonstrate it. Then implement the increment autonomously and show the relevant evidence.

Teach immediately before an unfamiliar concept is used, not in a long preliminary lecture. Explain only the concept's role here, its important constraint, and one nearby example. Mark it `introduced` or `practiced` in `.kyc/concepts.md` only when the evidence supports that status.

Use occasional hand-backs, not constant narration:

- ask for a prediction before a test, migration, command or observable side effect;
- ask for the invariant or failure mechanism when a bug or security boundary is central;
- ask the user to choose among materially different designs when the choice changes behavior, cost, or future maintenance.

Do not hand back naming, formatting, routine plumbing, or choices already established by the repository. If the user cannot answer, teach briefly, let them retry, and continue without treating uncertainty as failure. Pair mode adds explicit checkpoints and a journal; ordinary mode does not require a pause at every increment.
