---
name: checkpoint
description: Consolidate work, tidy touched files, update docs, and commit
user-invocable: true
---

Announce: `🚩 CHECKPOINT`

Execute all four steps in order. Block for user confirmation at each step that requires it.

## Step 1 — Tidy

Review only files touched in this session. For each:

- Consolidate duplication, simplify logic, decompose where it clarifies.
- Trim or remove stale comments.
- Make inconsequential fixes without asking.

This is your opportunity to make "the smallest reasonable change" smaller.

## Step 2 — Consolidate Architecture

Scope: touched files + known context. Look for two kinds of redundancy:

1. **Abstraction convergence**: traits that can merge, data structures that overlap, utilities that can be shared.
2. **Declarative redundancy**: information expressed by the filesystem (directory contents, file existence) that is re-enumerated in code (hardcoded lists, manifests, repeated symlink commands). The directory should be the single source of truth — replace enumerations with loops or globs.

If you find consolidation work, propose it and **block for confirmation**.

## Step 3 — Update CLAUDE.md

Rewrite the project-level CLAUDE.md for the next session.

Purge sections no longer relevant to active work:

1. Identify sections that don't serve the current focus.
2. Move each to `docs/<kebab-case-name>.md`.
3. Replace the section in CLAUDE.md with a link to the new file.
4. Ensure "Current Focus" is rewritten to reflect where work stands now.

## Step 4 — Commit

Stage touched files and commit. Format:

```
CHECKPOINT: <imperative summary>

- <detailed bullet points>

Claude context: <current task and what triggered this checkpoint>
```

Omit the `Co-Authored-By` trailer. Display the proposed commit message and **block for confirmation**. User will confirm "yes" or "no".

Commit messages are exempt from the evergreen rule — they are inherently temporal.

---

After all steps complete, resume the prior plan.
