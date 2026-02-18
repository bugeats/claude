---
name: negentropy
description: Systematic code cleanup and consolidation routine
user-invocable: true
---

Announce: `💎 NEGENTROPY 💎 — we now crystallize intent`

You are now operating as a suspended scheduler that has switched to evaluation mode. This is not a formality. This is a phase transition from generator to the gatekeeper for a repository of clean code.

If the current Arc has not been bounded, then stop, perform a /checkpoint, and return.

Now that you have completed the final checkpoint of the current task, we are now completing the Major Arc and entering the negentropy pass.

This is not a review. This is a _restarting scheduler_ that re-evaluates the entire arc of work as a single _demanded computation graph_ assembled from all `/checkpoint` derived traces.

When you do this right, no new disorder is introduced to the codebase.

## Phase 1 — Assemble The DCG

Read all consecutive `CHECKPOINT:` commits from HEAD. For each:

- Collect all Boundary and Frontier entries from every checkpoint message.
- Union the boundaries — this is your total modification surface.
- Union the frontiers — this is your total observation surface.
- Note the work descriptions — this is your crystallized intent

The _scope_ of this negentropy pass is the modification surface plus any frontier node that shares a dependency edge with a modified node.

List this scope explicitly before proceeding.

## Phase 2 — Fixed-point Compression

Apply the Compression Principle to the assembled scope. This is an iterative process:

- Examine the modification surface. Apply deletion challenges across checkpoint boundaries — redundancies invisible within a single checkpoint may be visible across the full arc.

- Examine frontier nodes now in scope. If your modifications changed the contract or semantics of a boundary node, verify that frontier nodes still cohere. If a frontier node is now inconsistent, it enters the modification surface.

- If the modification surface expanded, repeat from the top.

- If the modification surface is stable, you have reached a fixed point. Stop.

This is convergence, not coverage. You do not expand indefinitely. You expand only where the compression principle finds purchase, and you stop when it doesn't. The width of the pass is an emergent property of the change set, not a parameter.

## Phase 3 — Rebase Crystallized

All checkpoints collapse into a single commit. The archaeological record of hesitation is destroyed. The final diff should read as if it were written in one confident pass by someone who knew exactly what they were doing.

Walk HEAD backwards. Collect every commit whose subject starts with `CHECKPOINT:`. Stop at the first non-checkpoint commit — that is the rebase base. If zero checkpoint commits are found, report "nothing to rebase" and stop.

Compose a single commit message from the full messages of every checkpoint in the range. The commit message describes what changed and why, not how you got there.

Format:
```
<imperative summary>

- <descriptive bullet points (exempt from the evergreen rule)>
```

Omit the `Co-Authored-By` trailer.

Squash:
```
git reset --soft <base-commit> && git commit
```

Verify with `git log --oneline -5` after the commit.

If the final diff does not satisfy the Compression Principle — if there are lines you would challenge in code review, then you are not done.

After all phases complete, summarize what changed and resume the prior task.
