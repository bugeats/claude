# Launcher

The default package (`claude-arcs`) is a `writeShellApplication` whose body is one line:

```
exec claude --plugin-dir <plugin> --settings <plugin>/settings.json "$@"
```

`<plugin>` is the built plugin derivation (`packages.plugin`), an immutable Nix store path. The launcher writes nothing to `~/.claude/` and tears nothing down on exit; concurrent sessions on one host share the store path safely. Its `runtimeInputs` pin the `claude` binary and supply the model's shell toolset (git, gh, jq, rg, coreutils, grep, the Rust toolchain).

## Plugin Loading

Claude Code discovers plugin components from `<plugin>`:

- `.claude-plugin/plugin.json` — manifest (name, version, author).
- `skills/<name>/SKILL.md` — auto-discovered slash commands. Skill bodies reference plugin files via `${CLAUDE_PLUGIN_ROOT}`, which Claude Code substitutes anywhere in skill content.
- `hooks/hooks.json` — `PreToolUse`/`PostToolUse` registrations referencing `${CLAUDE_PLUGIN_ROOT}/hooks/*.sh`.
- `.mcp.json` — `rust-analyzer` stdio server, generated at build from `flake.nix` with an absolute store path as `command`.
- `output-styles/{manual,auto}.md` — generated at build from `prompts/`; selectable in `/config` as `arcs:manual` and `arcs:auto`. Nothing is injected into the system prompt unless one is selected. Headless selection: `--settings '{"outputStyle":"arcs:auto"}'`.

`settings.json` sits at the plugin root but is outside plugin discovery, so it reaches Claude Code via the `--settings` flag. Its `statusLine.command` is an absolute store path substituted at build (`@out@` in source).

## Build-time Path Pinning

The plugin needs no environment from its launcher:

- `hooks/*.sh` and `tools/*.sh` are built with `writeShellApplication` (shellcheck at build, PATH pinned to declared inputs) and installed under their source names. `nix` is deliberately not pinned so the client matches the host daemon.
- `statusline.py` has its shebang patched to the store `python3`; it still expects `git` and `bash` on PATH.
- The MCP `command` is a wrapper that puts the pinned `rust-analyzer` on PATH before exec'ing `rust-analyzer-mcp`.

## Identity

The containment prose and `/shipit` derive the user's name from `git config user.name`.

## Leftovers From Earlier Bootstraps

Earlier versions staged files into `~/.claude/` and cleaned them up on each launch. That cleanup no longer runs. If a session shows doubled hooks, duplicate skills, or a broken `~/CLAUDE.md` symlink, remove the stale artifacts once:

```
rm -f ~/.claude/statusline.py ~/.claude/identity ~/.claude/hooks/*.sh ~/.claude/tools/*.sh ~/.claude/cargo-workspace-root
find ~/.claude/skills -maxdepth 1 -type l -lname '/nix/store/*' -delete
[ -L ~/CLAUDE.md ] && rm ~/CLAUDE.md
claude mcp remove rust-analyzer -s user
```

If `~/.claude/settings.json` is a symlink into `/nix/store/` or references `$HOME/.claude/statusline.py`, delete it (restoring `~/.claude/settings.backup-pre-claude-arcs.json` if present).

## Unmanaged State

Everything in `~/.claude/` (projects, history, sessions, cache, MCP auth, `statusline.log`) is mutable runtime state owned by Claude Code. `statusline.log` accumulates tracebacks when the status-line script catches an exception — checking it diagnoses a disappearing status bar.
