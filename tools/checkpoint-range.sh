# Find the range of commits from HEAD that collapses into one commit.
#
# Walks backwards from HEAD up to DEPTH commits, never crossing into history
# shared with the mainline: published commits must not enter a rebase range,
# even when a stale CHECKPOINT was merged without being crystallized.
#
# Default mode collects the negentropy range: every CHECKPOINT: commit extends
# it, and non-checkpoint "orphans" between checkpoints are included.
#
# With --wip: collect the unwip range instead — the contiguous run of WIP
# commits at HEAD. A deliberately named commit is a boundary, so the walk stops
# at the first non-WIP subject.
#
# Default output (stdout):
#   Line 1:  base <hash>           — rebase target (parent of oldest in range)
#   Line 2+: <hash> <subject>      — each commit in the range, newest first
#
# With --count: print just the number of matching commits in the range and
# exit 0 (even when the count is zero). Used by the statusline gauge.
#
# Exit codes (default mode):
#   0  range found
#   1  no matching commits in the unshared range

DEPTH=50
COUNT_ONLY=0
CONTIGUOUS=0
LABEL=CHECKPOINT
MATCH='^CHECKPOINT:'

for arg in "$@"; do
  case "$arg" in
    --count) COUNT_ONLY=1 ;;
    --wip)
      CONTIGUOUS=1
      LABEL=WIP
      MATCH='^WIP([ :(]|$)'
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

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

deepest_match=-1
total_matches=0

for i in "${!subjects[@]}"; do
  if [[ "${subjects[$i]}" =~ $MATCH ]]; then
    deepest_match=$i
    total_matches=$((total_matches + 1))
  elif [ "$CONTIGUOUS" -eq 1 ]; then
    break
  fi
done

if [ "$COUNT_ONLY" -eq 1 ]; then
  echo "$total_matches"
  exit 0
fi

if [ "$deepest_match" -eq -1 ]; then
  echo "No $LABEL commits in the unshared range." >&2
  exit 1
fi

base_hash=$(git rev-parse "${commits[$deepest_match]}^")
echo "base $base_hash"

for i in $(seq 0 "$deepest_match"); do
  echo "${commits[$i]} ${subjects[$i]}"
done
