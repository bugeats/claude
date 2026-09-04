---
name: unwip
description: Fold the WIP commits at HEAD into the staging area, ready for /arcs:checkpoint
user-invocable: true
---

The user has been checkpointing by hand: a run of commits whose subjects start with `WIP`. Fold that run back into the index so the changes can be committed as a single, properly recorded `/arcs:checkpoint`.

## Step 1 — Find The Run

```
${CLAUDE_PLUGIN_ROOT}/tools/checkpoint-range.sh --wip
```

The tool prints the rebase base and the contiguous WIP commits at HEAD, bounded by history shared with the mainline. If it exits non-zero, HEAD is not a WIP commit — report this and stop.

Refuse if `git log --merges <base>..HEAD` is non-empty: a soft reset would flatten the merge.

If the branch has an upstream and the oldest WIP commit is already an ancestor of it (`git merge-base --is-ancestor <oldest> @{u}`), the run has been pushed. Tell the user the next push will need `--force-with-lease` and ask before continuing.

## Step 2 — Fold

```
git reset --soft <base>
```

The index now holds the WIP tree along with anything already staged; unstaged edits stay unstaged and will ride into the checkpoint with the rest. Confirm with `git status --short`.

## Step 3 — Checkpoint

Carry the WIP subjects into the checkpoint's work-item bullets — the reset dropped them from history. Invoke `/arcs:checkpoint`.
