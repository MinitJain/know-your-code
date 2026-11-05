#!/usr/bin/env bash
# In-flow learning nudge. Runs after Bash tool calls and only speaks when the
# working diff has changed. The agent supplies the actual explanation.
# Exit 0 always: learning must never block implementation.

input=$(cat)
command -v jq >/dev/null || exit 0

cwd=$(jq -r '.cwd // empty' <<<"$input")
cd "${cwd:-.}" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
kyc="$root/.kyc"
mkdir -p "$kyc" 2>/dev/null || exit 0
[ -f "$kyc/.gitignore" ] || printf '*
' >"$kyc/.gitignore"

# Do not speak on clean or routine tool calls.
git diff --quiet --no-ext-diff && git diff --cached --quiet --no-ext-diff && exit 0

# Hash staged and unstaged diffs. Untracked files are intentionally excluded
# because they can be large; the ship gate still catches them.
hash=$( {
  git diff --no-ext-diff
  git diff --cached --no-ext-diff
} 2>/dev/null | shasum -a 256 | awk '{print $1}')
[ -n "$hash" ] || exit 0

last=$(cat "$kyc/.last-diff-hash" 2>/dev/null || true)
[ "$hash" = "$last" ] && exit 0
printf '%s' "$hash" >"$kyc/.last-diff-hash"

level=$(cat "$kyc/level" 2>/dev/null || echo medium)
cat <<EOF
know-your-code (in-flow checkpoint, level: $level):
A meaningful tracked diff just changed. Before continuing, give the user a brief
checkpoint in 2–4 sentences: what behavior changed, why this approach was used,
and one important edge case or risk. Do not quiz them for routine work. If this
change introduces a consequential decision, pause and run the decision checkpoint
from the know-your-code skill instead.
EOF
