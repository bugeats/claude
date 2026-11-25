---
name: checkpoint
description: Consolidate work, tidy touched files, update docs, and commit
user-invocable: true
---

Announce: `Arc Close: 🚩 Checkpoint — We Now Self-Reflect`

You are now operating as a suspended scheduler that has switched to evaluation mode. This is not a formality. This is a phase transition from generator to critic.

Avoid ceremony without compression: if you complete a checkpoint and nothing was compressed or removed, treat this as a signal that you are either writing exceptionally clean code or — more likely — performing the ritual without applying the principle. Recheck.

Definitions:

- Element: A named symbol, function, type, trait, or module.
- Working Set: Elements added, modified, and removed since the last checkpoint.

Execute all steps in order:

## Step 1 — Atomic Tidy

Enumerate the Working Set and apply the Compression Principle. All code must be reviewed in accordance with Universal Code Style. Make edits as needed.

List `${CLAUDE_PLUGIN_ROOT}/style/` and, for each language present in the Working Set that has a matching `<lang>.md`, read it now — even if read in a prior arc — and apply it as review criteria to the diff. These rules are deliberately withheld from generation time; this re-read is their only enforcement point.

## Step 2 — Persist Context

Two files bootstrap the next session, and they have different owners.

The project-level `CLAUDE.md` is shared: it describes the project to every teammate's session and never carries one person's work. Check it for accuracy and make corrections. Move each section that serves only finished work to `docs/<kebab-case-name>.md`, optionally leaving a link in its place.

`CLAUDE.local.md`, beside it, is personal and never committed: if `git check-ignore -q CLAUDE.local.md` fails, add it to `.gitignore`. Ensure it holds an "Active Focus" section that names the branch it was written on and reflects where work stands after this checkpoint. A focus section found in `CLAUDE.md` moves here.

When `CLAUDE.md` declares a task registry, the Active Focus names its tasks by registry ID and the registry holds their detail. Bring those entries up to date, so a fresh session can resume from them.

Items in the Active Focus that are resolved or completed should be purged. Focus is about reducing noise.

## Step 3 — Persist History

Record a standard git commit with metadata hints for the _demanded computation graph_ of this checkpoint.

These hints will be consumed during `/arcs:negentropy` passes.

Format:
```
CHECKPOINT: <imperative summary>

- <work item bullet points (exempt from the evergreen rule)>

Boundary: <every Element directly modified (certain changed nodes)>

Frontier: <every unmodified Element and its containing module that was read from, depended on, or observed as adjacent to changes (edges traversed)>

Context: <current task, by registry ID when a registry is declared, and what triggered this checkpoint>
```

Omit the `Co-Authored-By` trailer.

After all steps are complete, resume the prior task.
