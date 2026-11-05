#!/usr/bin/env bash
# Every relative .md link inside the skill and AGENTS.md must point at a file that exists.
cd "$(dirname "$0")/.." || exit 1
fail=0
for f in AGENTS.md skills/know-your-code/*.md skills/know-your-code/*/*.md; do
  dir=$(dirname "$f")
  while read -r link; do
    [ -e "$dir/$link" ] || { echo "FAIL $f -> $link"; fail=1; }
  done < <(grep -oE '\]\([^)#:]+\)' "$f" | sed -E 's/^\]\(//; s/\)$//')
done
[ $fail = 0 ] && echo "ok   all skill links resolve"
exit $fail
