# Bootstrap Lifecycle

The bootstrap script loops over `skills/*/` and `hooks/*.sh` — adding or removing a skill/hook directory is sufficient; no manifest update needed.

## Artifact Management

`remove_managed_artifacts` handles two categories of installed files:

- **Symlinks** (statusline, skills, `~/CLAUDE.md`): removed only if they point into `/nix/store/`.
- **Copied files** (settings, tools, hooks): removed unconditionally.

Runs on entry (stale cleanup) and on EXIT trap (via `on_exit`).

## Settings

`settings.json` is installed as a writable copy (not a symlink) so Claude Code can write back at runtime. The user's original is backed up to `settings.backup-pre-claude-arcs.json` and restored on exit. User-authored entries are preserved.

## Identity

`~/.claude/identity` is created on first run (via `ensure_identity`, defaults to `whoami`) and persists across ephemeral invocations.

## Nix-interpolated Values

`self`, `miniwi-font`, and `flakeUri` reach the script via `runtimeEnv` as `FLAKE_SELF`, `MINIWI_FONT`, `FLAKE_URI`.

## MCP Servers

Conditional — `find_cargo_root` walks from `$PWD` and registers rust-analyzer only when a `Cargo.toml` is found. The detected root persists to `~/.claude/cargo-workspace-root` (ephemeral) for `set_workspace`.

## Unmanaged State

Everything else in `~/.claude/` (projects, history, sessions, cache, store.db) is mutable runtime state left unmanaged.
