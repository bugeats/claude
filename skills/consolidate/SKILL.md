---
name: consolidate
description: Crystallize checkpoints, rebase over the mainline, and squash to a single commit
user-invocable: true
argument-hint: [base]
---

Bring the branch level with its integration target and leave exactly one commit above it, whatever mix of checkpoints and crystallized commits it holds now. This is the routine `/arcs:shipit` runs before pushing, and the routine a branch needs after its stack PRs merge.

`<base>` is `$1` when provided, otherwise the mainline:

```
${CLAUDE_PLUGIN_ROOT}/tools/checkpoint-range.sh --mainline
```

## Pre-flight

Refuse to proceed if either fails. Report the specific failure and stop.

- Working tree clean — if not, direct the user to `/arcs:checkpoint` first.
- `git fetch origin` succeeds.

If the branch has an upstream, every rewrite below means its next push needs `--force-with-lease`. Note this for the report.

## The Loop

Repeat until HEAD sits on `<base>` with at most one commit above it:

1. **Crystallize.** If `${CLAUDE_PLUGIN_ROOT}/tools/checkpoint-range.sh --count` is non-zero, invoke `/arcs:negentropy` and restart the loop. Checkpoint messages carry scope hints, not a description of the deliverable; only the negentropy pass consumes them.

2. **Rebase.** `git rebase <base>`. Local commits patch-equivalent to commits already on `<base>` drop automatically — expected and desired.

   If conflicts arise, **resolve them**. You have full context of the change set and the upstream — use it. Bias toward intent preservation: the local commits represent crystallized intent, the upstream represents the integration target.

   If you cannot resolve with confidence — both sides made intentional, semantically incompatible changes, and there is no clear winner — `git rebase --abort`, surface the conflict to the user, and stop.

3. **Squash.** If `<base>..HEAD` holds two or more commits, collapse them into one. Compose the message from the full messages of every commit in the range: it describes what changed and why, not how you got there.

   Format:
   ```
   <imperative summary>

   - <descriptive bullet points (exempt from the evergreen rule)>
   ```

   Keep the summary under 72 characters so GitHub does not truncate it in lists.

   ```
   git reset --soft <base> && git commit
   ```

Verify with `git log --oneline <base>..HEAD`.

## Report

Zero commits above `<base>` means the branch is level with it — say so. Otherwise show the resulting commit message. If the branch has an upstream, say the next push needs `--force-with-lease`. Resume the prior task.
