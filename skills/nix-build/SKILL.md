---
name: nix-build
description: Run nix build with full diagnostic discipline
user-invocable: true
argument-hint: [output]
---

Run the nix build-diagnose cycle. The optional argument selects a flake output.

## Build

Construct the command:

- `/nix-build` → `nix build --print-build-logs`
- `/nix-build foo` → `nix build .#foo --print-build-logs`

Run it. Read the **entire** output before any diagnosis.

## On Failure

Apply these heuristics in order:

1. **Read the full log.** The error is rarely the last line. Scroll up to the first failure.
2. **Suspect the hash before the change.** If the build doesn't reflect your edit, the source hash is stale — not the edit. Check that files are `git add`ed (flakes only see tracked files).
3. **Remember the daemon boundary.** Builds run under `nix-daemon`, not your shell. Environment variables, PATH entries, and shell config do not carry into the build sandbox.
4. **Isolate the phase.** Nix builds in phases (unpack, patch, configure, build, install, check). Identify which phase failed before proposing a fix.

Report the diagnosis. Do not propose a fix until the failure is understood.

## On Success

Report success and resume the prior task.
