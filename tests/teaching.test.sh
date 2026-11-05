#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

for file in \
  skills/know-your-code/workflows/understand-task.md \
  skills/know-your-code/workflows/explore-codebase.md \
  skills/know-your-code/workflows/implementation-planning.md \
  skills/know-your-code/workflows/learning-during-build.md \
  skills/know-your-code/workflows/verification.md \
  skills/know-your-code/workflows/knowledge-transfer.md \
  skills/know-your-code/workflows/context.md \
  skills/know-your-code/templates/implementation-blueprint.md \
  skills/know-your-code/templates/learning-report.md \
  skills/know-your-code/templates/decision-record.md
do
  test -s "$file"
done

grep -Eq 'passed-.*without.*user|Never create.*pass file' skills/know-your-code/SKILL.md
grep -Eq 'unfamiliar.*introduced.*practiced.*demonstrated' skills/know-your-code/SKILL.md skills/know-your-code/workflows/context.md
grep -Eq 'pair mode.*opt-in|Pair mode is opt-in' README.md AGENTS.md skills/know-your-code/pair.md
grep -Eq 'journal.*diff|journal is evidence' README.md skills/know-your-code/pair.md

grep -Eq 'Use for any non-trivial coding task' skills/know-your-code/SKILL.md
grep -Eq 'default mode is lightweight' skills/know-your-code/SKILL.md
grep -Eq 'fallback.*compact' AGENTS.md

if command -v jq >/dev/null 2>&1; then
  teaching_tmp=$(mktemp -d)
  trap 'rm -rf "$teaching_tmp"' EXIT
  git -C "$teaching_tmp" init -q
  git -C "$teaching_tmp" config user.email test@example.com
  git -C "$teaching_tmp" config user.name test
  printf 'initial\n' >"$teaching_tmp/app.txt"
  git -C "$teaching_tmp" add app.txt
  git -C "$teaching_tmp" commit -qm initial
  git -C "$teaching_tmp" branch -M main
  mkdir -p "$teaching_tmp/.kyc"
  printf 'on\n' >"$teaching_tmp/.kyc/pair"

  pair_output=$(printf '{"cwd":"%s"}' "$teaching_tmp" | bash "$ROOT/hooks/nudge.sh")
  grep -q 'pair mode is on' <<<"$pair_output"

  rm -f "$teaching_tmp/.kyc/pair"
  printf 'hard\n' >"$teaching_tmp/.kyc/level"
  hard_output=$(printf '{"cwd":"%s"}' "$teaching_tmp" | bash "$ROOT/hooks/nudge.sh")
  grep -q 'no plan for branch' <<<"$hard_output"

  printf 'plan\n' >"$teaching_tmp/.kyc/plan-main.md"
  quiet_output=$(printf '{"cwd":"%s"}' "$teaching_tmp" | bash "$ROOT/hooks/nudge.sh")
  test -z "$quiet_output"
else
  echo 'jq unavailable; skipping nudge behavior checks'
fi

echo 'teaching workflow tests: ok'
