---
name: negentropy
description: Systematic code cleanup and consolidation routine
user-invocable: true
argument-hint: [scope]
---

Announce: `🧹 NEGENTROPY`

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
