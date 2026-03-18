# Find the contiguous range of CHECKPOINT commits from HEAD for negentropy rebase.
#
# Walks backwards from HEAD up to DEPTH commits. Every CHECKPOINT: commit
# extends the range; non-checkpoint "orphans" between checkpoints are included.
# The walk stops when no more CHECKPOINTs remain within the window.
#
# Output (stdout):
#   Line 1:  base <hash>           — rebase target (parent of oldest in range)
#   Line 2+: <hash> <subject>      — each commit in the range, newest first
#
# Exit codes:
#   0  range found
#   1  no CHECKPOINT commits in window

DEPTH=50

commits=()
subjects=()

while IFS= read -r line; do
  hash="${line%% *}"
  subject="${line#* }"
  commits+=("$hash")
  subjects+=("$subject")
done < <(git log --format='%h %s' -n "$DEPTH" HEAD)

if [ "${#commits[@]}" -eq 0 ]; then
  echo "No commits found." >&2
  exit 1
fi

deepest_checkpoint=-1

for i in "${!subjects[@]}"; do
  if [[ "${subjects[$i]}" == CHECKPOINT:* ]]; then
    deepest_checkpoint=$i
  fi
done

if [ "$deepest_checkpoint" -eq -1 ]; then
  echo "No CHECKPOINT commits in the last $DEPTH commits." >&2
  exit 1
fi

base_hash=$(git rev-parse "${commits[$deepest_checkpoint]}^")
echo "base $base_hash"

for i in $(seq 0 "$deepest_checkpoint"); do
  echo "${commits[$i]} ${subjects[$i]}"
done
