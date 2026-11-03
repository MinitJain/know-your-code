# Stage C — Verify and debug

For each meaningful increment:

1. State the expected result before running the check when the result teaches something.
2. Run the narrowest relevant test, type check, linter or focused command first.
3. Compare actual and expected output. Distinguish a product failure, a test failure, an environment failure and an inconclusive check.
4. If it fails, show the symptom and ask for the user's first hypothesis in pair mode; otherwise briefly explain the likely cause and investigate before changing code.
5. Add or update a regression check when the behavior is durable. Finish with the full appropriate suite and inspect the diff.

Never call a green command proof of behavior it does not exercise. Record meaningful predictions and outcomes in the pair journal or `.kyc/decisions.md`.
