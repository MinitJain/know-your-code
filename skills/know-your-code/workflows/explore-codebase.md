# 1b. Explore the codebase

Explore in this order, stopping when the question is answered:

1. Read the repository instructions and package/build manifests.
2. Check `git status`, branch context and recent history so edits do not confuse existing work.
3. Locate the user-facing entry point, the owner of the behavior, its data boundary and its tests. Prefer focused search over reading every file.
4. Read the smallest complete slice of the current execution path, including error paths and configuration.
5. Search for existing patterns before inventing a new abstraction.

Report the resulting map in plain language: entry point → transformation → side effect, plus the tests that protect it. If the repository is too unfamiliar to proceed safely, say what is missing and inspect one level deeper.
