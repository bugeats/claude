---
name: fixme
description: Find FIXME comments and work them, freshest first
user-invocable: true
argument-hint: [path...]
---

The user marks code needing action with a `FIXME` comment whose text is the task. Find them and begin the work now.

## Step 1 — Collect

```
git grep -n --untracked -E '\bFIXME\b' -- $ARGUMENTS
```

Skip matches that are not instructions addressed to you (string literals, prose about the marker itself). If nothing remains, report that and stop.

Order the rest freshest first: markers in uncommitted changes lead (`git diff HEAD -U0 | grep FIXME`, plus any untracked file), then the others in file order. List them with their text before touching anything.

## Step 2 — Work

Take each marker in turn. Read enough surrounding code to understand the request, make the change, and delete the marker — a resolved FIXME leaves no trace.

If a marker's text is ambiguous or the fix would be large, ask about that one and continue with the others.

## Step 3 — Checkpoint

A resolved FIXME is a checkpoint boundary. Invoke `/arcs:checkpoint` after each one, or after a cluster of trivial ones in the same module, and before finishing.
