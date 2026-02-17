---
name: negentropy
description: Systematic code cleanup and consolidation routine
user-invocable: true
argument-hint: [scope]
---

Announce: `	💎 NEGENTROPY 💎 - we now crystalize intent`

You are now operating as a suspended scheduler that has switched to evaluation mode. This is not a formality. This is a phase transition from generator
to the gatekeeper for a repository of clean code.

If the current Arc has not been bounded, then stop, perform a /checkpoint, and return.

Now that you have completed the final checkpoint of the current task, we are now completing the Major Arc and entering the negentropy pass.

This is not a review. This is a _restarting scheduler_ that re-evaluates the entire arc of work as a single _demanded computation graph_ assembled from all /checkpoint derived traces.

## Phase 1 — Assemble The DCG

Read all consecutive `CHECKPOINT:` commits from HEAD. For each:

- Collect all Boundary and Frontier entries from every checkpoint message.
- Union the boundaries — this is your total modification surface.
- Union the frontiers — this is your total observation surface.
- Note the work descriptions — this is your crystalized intent 

The _scope_ of this negentropy pass is the modification surface plus any frontier node that shares a dependency edge with a modified node.

List this scope explicitly before proceeding.

## Phase 2 — Fixed-point Compression

Apply the Compression Principle to the assembled scope. This is an iterative process:

- Examine the modification surface. Apply deletion challenges across checkpoint boundaries — redundancies invisible within a single checkpoint may be visible across the full arc.

- Examine frontier nodes now in scope. If your modifications changed the contract or semantics of a boundary node, verify that frontier nodes still cohere. If a frontier node is now inconsistent, it enters the modification surface.

- If the modification surface expanded, repeat from the top.

- If the modification surface is stable, you have reached a fixed point. Stop.

This is convergence, not coverage. You do not expand indefinitely. You expand only where the compression principle finds purchase, and you stop when it doesn't. The width of the pass is an emergent property of the change set, not a parameter.

## Phase 3 — Rebase Crystalized

All checkpoints collapse into a single commit. The archaeological record of hesitation is destroyed. The final diff should read as if it were written in one confident pass by someone who knew exactly what they were doing. The commit message describes what changed and why, not how you got there.

If the final diff does not satisfy the Compression Principle — if there
are lines you would challenge in code review, then you are not done.

Format: 
 ```
<imperative summary>

- <descriptive bullet points (exempt from the evergreen rule)>
```

Omit the `Co-Authored-By` trailer.

----

Reduce disorder in the codebase. The optional argument narrows scope — a file, directory, or module name. Without an argument, scope to files touched in this session.

Read every file in scope before proposing any changes.

## Pass 1 — Compression

For each function, type, test, and module in scope, ask:

- Can this be deleted without changing behavior?
- Can this merge into an existing neighbor?
- Does duplication here reach three occurrences? If so, consolidate.

Propose deletions and merges. **Block for confirmation** before applying.

## Pass 2 — Decomposition

For each function in scope:

- Over 20 lines? Candidate for split — but only where semantics support a seam.
- Over 1000 lines in the file? Candidate for module extraction.
- Multiple jobs in one name? Candidate for separation.

Balance: a ~400-line file with clear internal structure beats six ~70-line files with re-export boilerplate. Ergonomics is the tie-breaker.

Propose splits and extractions. **Block for confirmation** before applying.

## Pass 3 — Comments

Audit every comment in scope:

- Restates the code → delete the comment.
- Contains a code example → delete the example.
- Explains *what* or *how* → rewrite to explain *why*, or delete.
- Uses temporal language ("recently", "moved", "now") → rewrite as evergreen.
- Uses relative quality language ("new", "enhanced", "improved") → rewrite as evergreen.

Apply comment changes without blocking.

## Pass 4 — Names

Read function and variable names as prose. Where the composed story is unclear, rename for literate clarity. Nudge surrounding code style toward project standards.

Propose renames. **Block for confirmation** before applying.

---

After all passes complete, summarize what changed and resume the prior task.
