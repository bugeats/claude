---
name: nix-run
description: Run a predefined command inside the nix environment
user-invocable: true
argument-hint: [command-name]
---

Use the nix flake "app" section to define a command by name. Any command can be added, it doesn't need to be an "app". This is your chance to create tools for yourself.

Construct the command:

- `/nix-run foo` → `nix run .#foo --print-build-logs`

Run it. Manage output length from within the "app" definition.

----

During troubleshooting, consider these heuristics:

- **Read the full log.** The error is rarely the last line. Scroll up to the first failure.
- **Suspect the hash before the change.** If the build doesn't reflect your edit, the source hash is stale — not the edit. Check that files are `git add`ed (flakes only see tracked files).
- **Remember the daemon boundary.** Builds run under `nix-daemon`, not your shell. Your shell's environment variables, PATH entries, and shell config does not carry into the build sandbox. That's the point.
