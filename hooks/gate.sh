#!/usr/bin/env bash
# know-your-code gate: PreToolUse hook on Bash.
# Blocks `git push` / `gh pr create` until the user has explained the current HEAD.
# Exit 0 = allow, exit 2 = block (stderr goes back to Claude).

input=$(cat)

# Fail open: a learning tool must never brick someone's shell.
command -v jq >/dev/null || { echo "know-your-code: jq missing, gate disabled" >&2; exit 0; }

cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

# Match push/PR anywhere in a chain (`git add . && git push`), allowing global
# flags like `git -C dir push`, but not `git commit -m "push"`.
if ! grep -Eq '(^|[;&|( ])git( +-[^ ]+( +[^- ][^ ]*)?)* +push( |$)|(^|[;&|( ])gh +pr +create( |$)' <<<"$cmd"; then
  exit 0
fi

cd "${cwd:-.}" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
head=$(git rev-parse HEAD 2>/dev/null) || exit 0
kyc="$root/.kyc"

[ -f "$kyc/passed-$head" ] && exit 0

# /kyc off: one skip for this exact commit, consumed on use, logged.
if [ -f "$kyc/skip-$head" ]; then
  rm -f "$kyc/skip-$head"
  echo "$(date -u +%FT%TZ) skip $head" >>"$kyc/log"
  exit 0
fi

level=$(cat "$kyc/level" 2>/dev/null || echo medium)
cat >&2 <<EOF
⛔ know-your-code: explain before you ship (level: $level, HEAD ${head:0:7})
Do not retry the push. Use the know-your-code skill to quiz the user on this diff.
Only after they pass, create $kyc/passed-$head and push again.
To skip once (logged), the user runs: /kyc off
EOF
exit 2
