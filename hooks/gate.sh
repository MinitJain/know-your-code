#!/usr/bin/env bash
# know-your-code gate. Blocks `git push` / `gh pr create` until the user has explained the current HEAD.
# Claude Code + Codex: PreToolUse on Bash, command in .tool_input.command.
# Cursor: beforeShellExecution, command in top-level .command, wants JSON on stdout.
# Exit 0 = allow, exit 2 = block (reason on stderr).

input=$(cat)

# Fail open: a learning tool must never brick someone's shell.
command -v jq >/dev/null || { echo "know-your-code: jq missing, gate disabled" >&2; exit 0; }

cmd=$(jq -r '.tool_input.command // .command // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
event=$(jq -r '.hook_event_name // empty' <<<"$input")
cursor_input=$(jq -r '.command // empty' <<<"$input")

# Match push/PR at a shell-command boundary (`git add . && git push`), allowing
# wrappers (sudo, env, command, exec, nohup, time), VAR=x prefixes, a path to the
# binary and quoted global-option args, but not text like `echo git push`.
# shortcut: `sh -c 'git push'` and shell aliases are not caught; needs a real shell parser.
q="'" # literal quote: `\x27` in an ERE is not portable across grep implementations
pre='(^|[;&|(){}])[[:space:]]*((sudo|env|command|exec|nohup|time)([[:space:]]+-[^[:space:]]+)*[[:space:]]+|[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*(/?[[:alnum:]_.-]+/)*'
end='([[:space:]]|$|[;&|(){}])'
git_push="${pre}git([[:space:]]+-[^[:space:]]+([[:space:]]+(\"[^\"]*\"|${q}[^${q}]*${q}|[^[:space:]]+))?)*[[:space:]]+push${end}"
gh_pr="${pre}gh[[:space:]]+pr[[:space:]]+create${end}"
if ! grep -Eq "$git_push|$gh_pr" <<<"$cmd"; then
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
# Self-contained so agents without the skill loaded still run a fair quiz.
msg="⛔ know-your-code: explain before you ship (level: $level, HEAD ${head:0:7})
Do not retry the push. Use the know-your-code skill if you have it. Otherwise:
ask the user 3 questions about this diff (what changed, why this way, what breaks),
wait for their own answers, never answer for them, explain anything they get wrong.
Only after they pass: mkdir -p \"$kyc\" && touch \"$kyc/passed-$head\", then push again.
To skip once (logged), the user runs /kyc off (or says \"kyc off\" in other agents)"

if [ "$event" = beforeShellExecution ] || [ -n "$cursor_input" ]; then
  jq -n --arg m "$msg" '{permission:"deny",user_message:"know-your-code: explain before you ship",agent_message:$m}'
fi
echo "$msg" >&2
exit 2
