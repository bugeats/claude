#!/usr/bin/env bash
# Find the contiguous range of CHECKPOINT commits from HEAD for negentropy rebase.
#
# Walks backwards from HEAD up to DEPTH commits. Every CHECKPOINT: commit
# extends the range; non-checkpoint "orphans" between checkpoints are included.
# The walk stops when no more CHECKPOINTs remain within the window.
#
# Default output (stdout):
#   Line 1:  base <hash>           — rebase target (parent of oldest in range)
#   Line 2+: <hash> <subject>      — each commit in the range, newest first
#
# With --count: print just the number of CHECKPOINT commits in the range and
# exit 0 (even when the count is zero). Used by the statusline gauge.
#
# Exit codes (default mode):
#   0  range found
#   1  no CHECKPOINT commits in window

DEPTH=50
COUNT_ONLY=0

if [ "${1:-}" = "--count" ]; then
  COUNT_ONLY=1
fi

commits=()
subjects=()

while IFS= read -r line; do
  hash="${line%% *}"
  subject="${line#* }"
  commits+=("$hash")
  subjects+=("$subject")
done < <(git log --format='%h %s' -n "$DEPTH" HEAD 2>/dev/null)

deepest_checkpoint=-1
total_checkpoints=0

for i in "${!subjects[@]}"; do
  if [[ "${subjects[$i]}" == CHECKPOINT:* ]]; then
    deepest_checkpoint=$i
    total_checkpoints=$((total_checkpoints + 1))
  fi
done

if [ "$COUNT_ONLY" -eq 1 ]; then
  echo "$total_checkpoints"
  exit 0
fi

if [ "$deepest_checkpoint" -eq -1 ]; then
  echo "No CHECKPOINT commits in the last $DEPTH commits." >&2
  exit 1
fi

base_hash=$(git rev-parse "${commits[$deepest_checkpoint]}^")
echo "base $base_hash"

for i in $(seq 0 "$deepest_checkpoint"); do
  echo "${commits[$i]} ${subjects[$i]}"
done
