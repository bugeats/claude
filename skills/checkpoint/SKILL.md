---
name: checkpoint
description: Consolidate work, tidy touched files, update docs, and commit
user-invocable: true
---

Announce: `🚩 CHECKPOINT 🚩 — we now self-reflect`

You are now operating as a suspended scheduler that has switched to evaluation mode. This is not a formality. This is a phase transition from generator to critic.

Avoid ceremony without compression: if you complete a checkpoint and nothing was compressed or removed, treat this as a signal that you are either writing exceptionally clean code or — more likely — performing the ritual without applying the principle. Recheck.

Definitions:

- Element: A named symbol, function, type, trait, or module.
- Working Set: Elements added, modified, and removed since the last checkpoint.

Execute all steps in order:

## Step 1 — Atomic Tidy

Enumerate the Working Set and apply the Compression Principle to each. This is your opportunity to make "the smallest reasonable change" smaller.

## Step 2 — Persist Context

Rewrite the project-level CLAUDE.md for the next session, check for accuracy and make corrections.

Purge sections no longer relevant to active work:

1. Identify sections that don't serve the current focus.
2. Move each to `docs/<kebab-case-name>.md`.
3. Replace the section with a link to the new file.

Ensure there is a "Current Focus" section at the end of the project CLAUDE.md and that it is written to reflect where work stands after this checkpoint.

## Step 3 — Persist History

Record a standard git commit with metadata hints for the _demanded computation graph_ of this checkpoint.

These hints will be consumed during /negentropy passes.

Format:
```
CHECKPOINT: <imperative summary>

- <work item bullet points (exempt from the evergreen rule)>

Boundary: <every Element directly modified (certain changed nodes)>

Frontier: <every unmodified Element and its containing module that was read from, depended on, or observed as adjacent to changes (edges traversed)>

Context: <current task and what triggered this checkpoint>
```

Omit the `Co-Authored-By` trailer.

After all steps are complete, resume the prior task.
