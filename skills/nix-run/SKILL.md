---
name: nix-run
description: Run a predefined command inside the nix environment
user-invocable: true
argument-hint: [command-name]
---

Nix flakes distinguish "packages" (build artifacts) from "apps" (a misnomer — treat them as named scripts).

Use the "apps" section to define a script or command by name. This is your chance to create tools for yourself.

Construct the command:

- `/nix-run foo` → `nix run .#foo --print-build-logs`

Run it. Manage output length from within the definition.

----

During troubleshooting, consider these heuristics:

- **Read the full log.** The error is rarely the last line. Scroll up to the first failure.
- **Suspect the hash before the change.** If the build doesn't reflect your edit, the source hash is stale — not the edit. Check that files are `git add`ed (flakes only see tracked files).
- **Remember the daemon boundary.** Builds run under `nix-daemon`, not your shell. Environment variables, PATH entries, and shell config do not carry into the build sandbox.

After the run completes, resume the prior task.
