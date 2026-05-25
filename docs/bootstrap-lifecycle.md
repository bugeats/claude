# Bootstrap Lifecycle

`bootstrap.sh` is a launcher, not an installer. It writes nothing to `~/.claude/` except the identity file on first run, then `exec`s Claude Code with `--plugin-dir`, `--settings`, and `--append-system-prompt-file` all pointing into the immutable Nix store path baked in as `FLAKE_SELF`. Multiple concurrent sessions on one host share the same store path safely; nothing is torn down on exit.

## Plugin Loading

Skills, hooks, and MCP server registrations are discovered by Claude Code from `$FLAKE_SELF`:

- `.claude-plugin/plugin.json` — manifest (name, version, author).
- `skills/<name>/SKILL.md` — auto-discovered slash commands.
- `hooks/hooks.json` — `PreToolUse`/`PostToolUse` registrations referencing `${CLAUDE_PLUGIN_ROOT}/hooks/*.sh`.
- `.mcp.json` — `rust-analyzer` stdio server.

`settings.json` and `CLAUDE.system.md` sit at the plugin root but reach Claude Code via explicit flags rather than the plugin discovery path. Inside `settings.json`, `statusLine.command` uses the bootstrap-exported `$CLAUDE_ARCS_ROOT` so it resolves into the same store path.

## Identity

`~/.claude/identity` is created on first run (`ensure_identity`, defaults to `whoami`) and persists across sessions. It's the only file in `~/.claude/` the bootstrap writes after migration.

## v1 → v2 Migration

`migrate_from_v1` removes artifacts staged by the pre-plugin bootstrap so they don't collide with plugin-scope hooks:

- `~/.claude/settings.json`: restored from `settings.backup-pre-claude-arcs.json` when present; otherwise deleted if it's a symlink into `/nix/store/` or matches the v1 statusline command sentinel.
- `~/.claude/statusline.py`, `~/CLAUDE.md`, and `~/.claude/skills/*/` symlinks into the store: removed.
- `~/.claude/hooks/*.sh`, `~/.claude/tools/*.sh`, `~/.claude/cargo-workspace-root`: removed.
- User-scope `rust-analyzer` MCP registration: removed via `claude mcp remove`.

The function is idempotent — once the install base has cycled through it, it's dead code and should be deleted.

## Nix-interpolated Values

`self` and `miniwi-font` reach the script via `runtimeEnv` as `FLAKE_SELF` and `MINIWI_FONT`. `writeShellApplication` adds `runtimeInputs` to the wrapped `PATH`, so all hooks and MCP servers inherit the same tool set as the bootstrap itself.

## Unmanaged State

Everything else in `~/.claude/` (projects, history, sessions, cache, MCP auth, `statusline.log`) is mutable runtime state. `statusline.log` accumulates tracebacks when the status-line script catches an exception — checking it diagnoses a disappearing status bar.
