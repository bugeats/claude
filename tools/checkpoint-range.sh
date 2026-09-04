# Find the contiguous range of CHECKPOINT commits from HEAD for negentropy rebase.
#
# Walks backwards from HEAD up to DEPTH commits, never crossing into history
# shared with the mainline: published commits must not enter a rebase range,
# even when a stale CHECKPOINT was merged without being crystallized. Every
# CHECKPOINT: commit extends the range; non-checkpoint "orphans" between
# checkpoints are included.
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
#   1  no CHECKPOINT commits in the unshared range

DEPTH=50
COUNT_ONLY=0

if [ "${1:-}" = "--count" ]; then
  COUNT_ONLY=1
fi

# The ref that defines published history: the remote's declared HEAD when set,
# otherwise the first conventional mainline that exists. The checked-out
# branch cannot define published history relative to itself — skip it, or a
# local-only repo working directly on main would never see its own range.
mainline() {
  local ref
  if ref=$(git symbolic-ref -q --short refs/remotes/origin/HEAD); then
    echo "$ref"
    return
  fi

  local current
  current=$(git branch --show-current)

  for ref in origin/main origin/master main master; do
    if [ "$ref" != "$current" ] && git rev-parse -q --verify "$ref^{commit}" >/dev/null; then
      echo "$ref"
      return
    fi
  done

  return 1
}

# Everything unshared: <merge-base>..HEAD. Without a mainline to measure
# against, sharedness is undecidable — fall back to the bare window.
walk_range() {
  local shared
  if shared=$(mainline) && shared=$(git merge-base HEAD "$shared" 2>/dev/null); then
    echo "$shared..HEAD"
  else
    echo "HEAD"
  fi
}

commits=()
subjects=()

while IFS= read -r line; do
  hash="${line%% *}"
  subject="${line#* }"
  commits+=("$hash")
  subjects+=("$subject")
done < <(git log --format='%h %s' -n "$DEPTH" "$(walk_range)" 2>/dev/null)

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
  echo "No CHECKPOINT commits in the unshared range." >&2
  exit 1
fi

base_hash=$(git rev-parse "${commits[$deepest_checkpoint]}^")
echo "base $base_hash"

for i in $(seq 0 "$deepest_checkpoint"); do
  echo "${commits[$i]} ${subjects[$i]}"
done
