#!/usr/bin/env bash
# UserPromptSubmit: add know-your-code context. stdout on exit 0 is added to the agent's context.
# Pair mode on/paused → checkpoint reminder. Hard level without a plan → plan reminder. Else silent.
cwd=$(jq -r '.cwd // empty' 2>/dev/null) || exit 0
root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
branch=$(git -C "$root" rev-parse --abbrev-ref HEAD 2>/dev/null | tr / -)
kyc="$root/.kyc"

case "$(cat "$kyc/pair" 2>/dev/null)" in
  on) echo "know-your-code (pair): pair mode is on. If this prompt starts a new task, append '## Task: <name>' to .kyc/journal-$branch.md. Open a checkpoint only if one clearly applies (debug > design > prediction), max 3 per task, one at a time. Follow pair.md in the know-your-code skill." ;;
  paused) echo "know-your-code (pair): paused for the current task. If this prompt starts a new task, set .kyc/pair to 'on' and append '## Task: <name>' to .kyc/journal-$branch.md." ;;
esac

[ "$(cat "$kyc/teach" 2>/dev/null)" = on ] && echo "know-your-code (teach): teach mode is on. For a non-trivial coding task, follow the Teach mode workflow in the know-your-code skill: understand, plan, learn while building, verify, transfer. Read .kyc/profile.md first. Skip for questions, typos, config tweaks."

if [ "$(cat "$kyc/level" 2>/dev/null)" = hard ] && [ ! -f "$kyc/plan-$branch.md" ]; then
  echo "know-your-code (hard): no plan for branch '$branch'. If this prompt asks for a real feature, run the hard-level PLAN step from the know-your-code skill BEFORE writing code. Skip for questions, typos, config tweaks."
fi
exit 0
