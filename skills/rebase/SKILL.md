---
name: rebase
description: Squash consecutive CHECKPOINT commits into a single polished commit
user-invocable: true
---

Announce: `🔀 REBASE`

Squash all consecutive `CHECKPOINT:` commits from HEAD into a single commit with a consolidated message.

## Step 1 — Identify Range

Walk HEAD backwards. Collect every commit whose subject starts with `CHECKPOINT:`. Stop at the first non-checkpoint commit — that is the rebase base.

If zero checkpoint commits are found, report "nothing to rebase" and stop.

Display the range (count, base commit, and each checkpoint subject line) and **block for confirmation**.

## Step 2 — Draft Message

Read the full messages (subject + body) of every checkpoint in the range. Compose a single commit message:

1. **Subject line**: imperative summary of the combined work — no `CHECKPOINT:` prefix.
2. **Body**: bulleted list of salient changes, deduplicated and ordered by logical dependency. Drop "Claude context" lines. Drop bullets that are subsumed by later work (e.g. a fix followed by a rewrite — keep only the rewrite).

Omit the `Co-Authored-By` trailer.

Display the proposed commit message and **block for confirmation**. User will confirm, edit, or reject.

## Step 3 — Squash

Execute an interactive-free squash rebase:

```
git reset --soft <base-commit> && git commit
```

Use the confirmed message from Step 2. Verify with `git log --oneline -5` after the commit.

---

After the rebase completes, resume the prior task.
