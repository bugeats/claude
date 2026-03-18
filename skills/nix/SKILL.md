---
name: nix
description: Nix build and run interface
user-invocable: true
argument-hint: [build|run|status] [target]
---

Parse the first argument to dispatch:

- No arguments → print this skill's usage summary and stop.
- `build` → go to **Build**.
- `run` → go to **Run**.
- `status` → run `~/.claude/tools/nix-status.sh` synchronously and report the output.
- Anything else → treat as a build output name (shorthand for `build <arg>`).

## Build

Spawn a background Agent with the following prompt, substituting `$COMMAND`:

- `/nix build` → `$COMMAND = nix build --print-build-logs`
- `/nix build foo` → `$COMMAND = nix build .#foo --print-build-logs`

```
Run this nix build command:

    $COMMAND

Read the ENTIRE output before any analysis.

If the build SUCCEEDS: report the output name and that it succeeded.

If the build FAILS, apply these heuristics in order:

1. Read the full log. The error is rarely the last line. Scroll up to the first failure.
2. Suspect the hash before the change. If the build doesn't reflect the edit, the source hash is stale. Check that files are git-added (flakes only see tracked files).
3. Remember the daemon boundary. Builds run under nix-daemon, not your shell. Environment variables, PATH, and shell config do not carry into the build sandbox.
4. Isolate the phase. Nix builds in phases (unpack, patch, configure, build, install, check). Identify which phase failed.

Report the diagnosis. Do not propose a fix — just report what failed and why.
```

Set `run_in_background: true`. After launching, inform the user and resume the prior task.

When the agent completes, relay its report.

## Run

Run a flake app from the project flake:

- `/nix run` → `nix run` (default app)
- `/nix run foo` → `nix run .#foo`

Run it synchronously. After the run completes, resume the prior task.
