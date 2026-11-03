# Stage A — Understand before coding

Use this for a feature, bug fix, refactor or unfamiliar integration. Skip or compress it for a typo, formatting-only change or an explicitly scoped one-line edit.

1. Restate the requested outcome and the observable acceptance condition.
2. Inspect the repository shape, relevant instructions, current branch/status and existing tests before proposing files.
3. Trace the current behavior from entry point to side effect. Name the files and symbols that own each responsibility.
4. Identify dependencies, integration points, security/reliability concerns and at least one unfamiliar concept. Check the local context files before teaching something already practiced.
5. State assumptions and alternatives. If an assumption could change the design, ask the user; otherwise label it and proceed.
6. Give a short blueprint: files to change, data/control flow, smallest increments and how each increment will be checked.

Do not dump a directory listing or explain framework boilerplate. Show the user the few facts that determine the design.
