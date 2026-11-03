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

rg -q 'passed-.*without.*user|Never create.*pass file' skills/know-your-code/SKILL.md
rg -q 'unfamiliar.*introduced.*practiced.*demonstrated' skills/know-your-code/SKILL.md skills/know-your-code/workflows/context.md
rg -q 'pair mode.*opt-in|Pair mode is opt-in' README.md AGENTS.md skills/know-your-code/pair.md
rg -q 'journal.*diff|journal is evidence' README.md skills/know-your-code/pair.md

echo 'teaching workflow tests: ok'
