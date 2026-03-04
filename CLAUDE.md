# Claude Code Configuration Flake

Nix flake that manages Claude Code user-level configuration. The default package (`claude-bootstrap`) installs authored config into `~/.claude/`, launches `claude`, and cleans up on exit.

**Self-referential repo**: `CLAUDE.system.md` is symlinked to `~/CLAUDE.md`, which Claude Code loads as system-level instructions for every session. When working in this project, you are editing the instructions that govern you. Changes to `CLAUDE.system.md` take effect on next session start.

## Architecture

```
flake.nix                    # default package = claude-bootstrap wrapper
bootstrap.sh                 # bootstrap lifecycle: config install, claude launch, teardown
CLAUDE.system.md             # system-level instructions (symlinked to ~/CLAUDE.md)
settings.json                # user-global settings + hook config (writable copy)
diagram.txt                  # arc workflow diagram (displayed in greeting banner)
skills/checkpoint/SKILL.md   # user-scoped skill: tidy, consolidate, doc, commit
skills/nix-build/SKILL.md    # user-scoped skill: nix build + diagnostic discipline
skills/negentropy/SKILL.md   # user-scoped skill: DCG-driven fixed-point compression + rebase
skills/nix-run/SKILL.md      # user-scoped skill: run named nix flake app
skills/school-me/SKILL.md    # user-scoped skill: guided tour of this config's workflow
statusline.py                # status line: arc depth from git log, model, context, cost, churn (symlinked)
hooks/nix-format.sh          # PostToolUse hook: nixfmt via nix run (symlinked)
hooks/nix-guardian.sh        # PreToolUse hook: prompt before non-nix build commands (symlinked)
hooks/rust-format.sh         # PostToolUse hook: rustfmt via rust-toolchain PATH (symlinked)
```

**Authored vs runtime**: the bootstrap script loops over `skills/*/` and `hooks/*.sh` — adding or removing a skill/hook directory is sufficient; no manifest update needed. `remove_managed_symlinks` removes all nix-store-targeted symlinks; it runs on entry (stale cleanup) and on EXIT trap (via `on_exit`). `settings.json` is installed as a writable copy (not a symlink) so Claude Code can write back at runtime; user's original is backed up to `settings.backup-pre-claude-arcs.json` and restored on exit. User-authored entries are preserved. `~/.claude/identity` is created on first run (via `ensure_identity`, defaults to `whoami`) and persists across ephemeral invocations. Nix-interpolated values (`self`, `miniwi-font`, `flakeUri`) reach the script via `runtimeEnv` as `FLAKE_SELF`, `MINIWI_FONT`, `FLAKE_URI`. MCP servers are conditional — `find_cargo_root` walks from `$PWD` and registers rust-analyzer only when a `Cargo.toml` is found. The detected root persists to `~/.claude/cargo-workspace-root` (ephemeral) for `set_workspace`. Everything else in `~/.claude/` (projects, history, sessions, cache, store.db) is mutable runtime state left unmanaged.

**Dependencies**: all runtime packages (`claude`, `jq`, `grep`, `git`, `rg`, `coreutils`, `python3`, `figlet`, `tte`, `rust-toolchain`, `rust-analyzer-mcp`) are declared in `flake.nix` `runtimeInputs` — no ambient PATH assumptions. The Rust toolchain (rustc, cargo, rust-analyzer, rust-src, rustfmt, clippy) is provided by `oxalica/rust-overlay` tracking latest stable. `rust-analyzer-mcp` is built from source via `rustPlatform.buildRustPackage` (pinned at v0.2.0, `zeenix/rust-analyzer-mcp`). The miniwi figlet font is fetched via `pkgs.fetchurl` (hash-pinned, source: `xero/figlet-fonts`). `nix-format.sh` runs `nixfmt-rfc-style` ephemerally via `nix run`; `rust-format.sh` uses `rustfmt` from the toolchain PATH.

## Commands

```
/nix-build                     # nix build --print-build-logs
/nix-build my-foo              # nix build .#my-foo --print-build-logs
nix run                        # bootstrap config + launch claude
```

## Current Focus

Bootstrap lifecycle, default permissions, and Rust tooling integration are landed.

**`writeShellApplication` discipline**: `bootstrap.sh` runs under `set -o errexit nounset pipefail`. Guard `&&` chains in functions with `if` statements — a short-circuiting `&&` chain as the last statement in a `for` loop inside a function propagates non-zero to the call site. Files copied from `/nix/store/` inherit `444` permissions — always set explicit modes.

Open items:

- **Color tuning**: Brand purple `#B388FF` is approximate — verify against actual Claude Code TUI source if possible.
- **Hook verification**: `$HOME` expansion in hook command path untested. Hook stdin JSON schema (`tool_input.command`, `tool_input.file_path`) confirmed via docs but not verified at runtime.
- **System flake integration**: Flake designed for both `nix run github:bugeats/claude` and inclusion in a system flake via `packages.default`. Neither path tested end-to-end.
- **Permission rule semantics**: `Bash(nix:*)` colon syntax matches `nix` subcommands but not hyphenated binaries like `nix-prefetch-github`.
- **MCP lifecycle verification**: `claude mcp add-json`/`remove` subcommands used in bootstrap — untested at runtime. Fallback: direct `jq` manipulation of `~/.claude.json`.
