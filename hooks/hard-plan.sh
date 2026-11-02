#!/usr/bin/env bash
# Hard level only: remind Claude to run the plan step before writing feature code.
# stdout on exit 0 is added to Claude's context.
cwd=$(jq -r '.cwd // empty' 2>/dev/null) || exit 0
root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ "$(cat "$root/.kyc/level" 2>/dev/null)" = hard ] || exit 0
branch=$(git -C "$root" rev-parse --abbrev-ref HEAD | tr / -)
[ -f "$root/.kyc/plan-$branch.md" ] && exit 0
echo "know-your-code (hard): no plan for branch '$branch'. If this prompt asks for a real feature, run the hard-level PLAN step from the know-your-code skill BEFORE writing code. Skip for questions, typos, config tweaks."
