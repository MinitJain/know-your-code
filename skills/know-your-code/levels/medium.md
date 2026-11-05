# Medium (default)

During implementation:

- Give a 2–4 sentence passive checkpoint after a meaningful implementation chunk.
- Before a consequential choice, ask one open question about the tradeoff.
- Do not interrupt formatting, renames, lockfiles, or routine test fixes.

Before shipping, ask exactly 3 open questions tied to the important parts of the diff:

1. **What** — what does the code do now that it did not before?
2. **Why** — why this approach instead of another?
3. **What breaks** — what happens on failure, bad input, concurrency, or security-sensitive input?
