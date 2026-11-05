#!/usr/bin/env bash
# Run: bash tests/gate.test.sh
gate="$(cd "$(dirname "$0")/.." && pwd)/hooks/gate.sh"
fail=0

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT
git -C "$repo" init -q
git -C "$repo" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -q --allow-empty -m init
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
expect 2 "$repo" "git -C '/tmp/a b' push"          "push with quoted global arg blocked"
expect 2 "$repo" "(git push)"                      "push in subshell blocked"
expect 2 "$repo" "/usr/bin/git push"                "absolute git push blocked"
expect 2 "$repo" "sudo git push"                    "sudo git push blocked"
expect 2 "$repo" "gh pr create --fill"            "gh pr create blocked"
expect 2 "$repo" "env -i git push"                 "env -i git push blocked"
expect 2 "$repo" "command git push"                "command git push blocked"
expect 2 "$repo" "GIT_TRACE=1 time git push"       "VAR=x time git push blocked"
expect 0 "$repo" "echo git push"                   "push text in echo allowed"
expect 0 "$repo" 'git commit -m "git push later"'  "git push inside commit msg allowed"
expect 0 "$(mktemp -d)" "git push"                "outside git repo allowed"

msg=$(jq -n --arg d "$repo" '{tool_input:{command:"git push"},cwd:$d}' | bash "$gate" 2>&1 >/dev/null)
grep -q 'mkdir -p ".*" && touch ".*passed-' <<<"$msg" && echo "ok   block guidance quotes state path" || { echo "FAIL block guidance quotes state path"; fail=1; }

mkdir -p "$repo/.kyc" && touch "$repo/.kyc/passed-$(head)"
expect 0 "$repo" "git push"                       "passed HEAD allowed"

git -C "$repo" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -q --allow-empty -m next
expect 2 "$repo" "git push"                       "new commit needs new pass"

touch "$repo/.kyc/skip-$(head)"
expect 0 "$repo" "git push"                       "skip allows once"
expect 2 "$repo" "git push"                       "skip consumed"
grep -q "skip $(head)" "$repo/.kyc/log" && echo "ok   skip logged" || { echo "FAIL skip logged"; fail=1; }

# Cursor beforeShellExecution: top-level command, JSON deny on stdout
git -C "$repo" -c user.name=t -c user.email=t@t -c commit.gpgsign=false commit -q --allow-empty -m cursor
out=$(jq -n --arg d "$repo" '{hook_event_name:"beforeShellExecution",command:"git push",cwd:$d}' | bash "$gate" 2>/dev/null); code=$?
[ "$code" = 2 ] && [ "$(jq -r .permission <<<"$out")" = deny ] && echo "ok   cursor push denied with JSON" || { echo "FAIL cursor push denied with JSON (code $code, out: $out)"; fail=1; }
out=$(jq -n --arg d "$repo" '{command:"git push",cwd:$d}' | bash "$gate" 2>/dev/null); code=$?
[ "$code" = 2 ] && [ "$(jq -r .permission <<<"$out")" = deny ] && echo "ok   cursor wire input denied with JSON" || { echo "FAIL cursor wire input denied with JSON (code $code, out: $out)"; fail=1; }
out=$(jq -n --arg d "$repo" '{hook_event_name:"beforeShellExecution",command:"ls",cwd:$d}' | bash "$gate" 2>/dev/null); code=$?
[ "$code" = 0 ] && [ -z "$out" ] && echo "ok   cursor non-push allowed" || { echo "FAIL cursor non-push allowed"; fail=1; }

# nudge.sh: hard-level plan reminder + pair-mode reminder
hp="$(dirname "$gate")/nudge.sh"
nudge() { jq -n --arg d "$repo" '{prompt:"add login",cwd:$d}' | bash "$hp"; }
nudge | grep -q "teach mode is on" && echo "ok   teach reminder by default" || { echo "FAIL teach reminder by default"; fail=1; }
echo off > "$repo/.kyc/teach"
[ -z "$(nudge)" ] && echo "ok   no nudge on medium" || { echo "FAIL no nudge on medium"; fail=1; }
echo hard > "$repo/.kyc/level"
nudge | grep -q "know-your-code (hard)" && echo "ok   nudge on hard without plan" || { echo "FAIL nudge on hard without plan"; fail=1; }
touch "$repo/.kyc/plan-$(git -C "$repo" rev-parse --abbrev-ref HEAD | tr / -).md"
[ -z "$(nudge)" ] && echo "ok   no nudge once plan exists" || { echo "FAIL no nudge once plan exists"; fail=1; }
echo on > "$repo/.kyc/pair"
nudge | grep -q "pair mode is on" && echo "ok   pair reminder when on" || { echo "FAIL pair reminder when on"; fail=1; }
echo paused > "$repo/.kyc/pair"
nudge | grep -q "paused for the current task" && echo "ok   pair reminder when paused" || { echo "FAIL pair reminder when paused"; fail=1; }
rm "$repo/.kyc/pair"
[ -z "$(nudge)" ] && echo "ok   no pair reminder when off" || { echo "FAIL no pair reminder when off"; fail=1; }

exit $fail
