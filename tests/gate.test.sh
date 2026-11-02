#!/usr/bin/env bash
# Run: bash tests/gate.test.sh
gate="$(cd "$(dirname "$0")/.." && pwd)/hooks/gate.sh"
fail=0

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT
git -C "$repo" init -q
git -C "$repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
head() { git -C "$repo" rev-parse HEAD; }

run() { # run <cwd> <command> -> exit code of gate
  jq -n --arg c "$2" --arg d "$1" '{tool_input:{command:$c},cwd:$d}' | bash "$gate" 2>/dev/null
  echo $?
}
expect() { # expect <code> <cwd> <command> <name>
  got=$(run "$2" "$3")
  if [ "$got" = "$1" ]; then echo "ok   $4"; else echo "FAIL $4 (want $1, got $got)"; fail=1; fi
}

expect 0 "$repo" "ls -la"                        "unrelated command allowed"
expect 0 "$repo" 'git commit -m "fix push bug"'   "push inside commit msg allowed"
expect 0 "$repo" "git log --grep push"            "push as log arg allowed"
expect 2 "$repo" "git push"                       "git push blocked"
expect 2 "$repo" "git push -u origin main"        "git push with args blocked"
expect 2 "$repo" "git add . && git push"          "chained push blocked"
expect 2 "$repo" "git -C . push"                  "push with global flag blocked"
expect 2 "$repo" "gh pr create --fill"            "gh pr create blocked"
expect 0 "$(mktemp -d)" "git push"                "outside git repo allowed"

mkdir -p "$repo/.kyc" && touch "$repo/.kyc/passed-$(head)"
expect 0 "$repo" "git push"                       "passed HEAD allowed"

git -C "$repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m next
expect 2 "$repo" "git push"                       "new commit needs new pass"

touch "$repo/.kyc/skip-$(head)"
expect 0 "$repo" "git push"                       "skip allows once"
expect 2 "$repo" "git push"                       "skip consumed"
grep -q "skip $(head)" "$repo/.kyc/log" && echo "ok   skip logged" || { echo "FAIL skip logged"; fail=1; }

exit $fail
