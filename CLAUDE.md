# Claude Code Configuration Flake

Nix flake that manages Claude Code user-level configuration. The default package (`claude-bootstrap`) symlinks authored config into `~/.claude/` and execs `claude`.

**Self-referential repo**: `CLAUDE.system.md` is symlinked to `~/CLAUDE.md`, which Claude Code loads as system-level instructions for every session. When working in this project, you are editing the instructions that govern you. Changes to `CLAUDE.system.md` take effect on next session start.

## Architecture

```
flake.nix                    # default package = claude-bootstrap wrapper
CLAUDE.system.md             # system-level instructions (symlinked to ~/CLAUDE.md)
settings.json                # user-global settings + hook config (symlinked)
skills/checkpoint/SKILL.md   # user-scoped skill: tidy, consolidate, doc, commit
skills/nix-build/SKILL.md    # user-scoped skill: nix build + diagnostic discipline
skills/negentropy/SKILL.md   # user-scoped skill: DCG-driven fixed-point compression + rebase
skills/nix-run/SKILL.md      # user-scoped skill: run named nix flake app
skills/school-me/SKILL.md    # user-scoped skill: guided tour of this config's workflow
statusline.py                # status line: model, context, cost, duration, churn (symlinked)
hooks/nix-format.sh          # PostToolUse hook: nixfmt via nix run (symlinked)
hooks/nix-guardian.sh        # PreToolUse hook: prompt before non-nix build commands (symlinked)
```

**Authored vs runtime**: the bootstrap script loops over `skills/*/` and `hooks/*.sh` — adding or removing a skill/hook directory is sufficient; no manifest update needed. Stale symlinks pointing into the nix store are cleaned on each run; user-authored entries are preserved. `~/.claude/identity` is created on first run (user-prompted, defaults to `whoami`) and read by Claude at session start for personalized address. Everything else in `~/.claude/` (projects, history, sessions, cache, store.db) is mutable runtime state left unmanaged.

**Dependencies**: all runtime binaries (`claude`, `jq`, `grep`, `git`, `rg`, `coreutils`, `python3`, `figlet`, `tte`) are declared in `flake.nix` `runtimeInputs` — no ambient PATH assumptions. The miniwi figlet font is fetched via `pkgs.fetchurl` (hash-pinned, source: `xero/figlet-fonts`). Formatting runs `nixfmt-rfc-style` ephemerally via `nix run nixpkgs#nixfmt-rfc-style`.

## Commands

```
/nix-build                     # nix build --print-build-logs
/nix-build my-foo              # nix build .#my-foo --print-build-logs
nix run                        # bootstrap config + launch claude
```

## Current Focus

Bootstrap and onboarding are stable. No active feature work.

Open items:

- **Color tuning**: Brand purple `#B388FF` is approximate — verify against actual Claude Code TUI source if possible.
- **settings.json write-back**: Claude writes `feedbackSurveyState` to settings.json. Symlink to read-only store path may fail — may require copy-with-merge strategy.
- **Hook verification**: `$HOME` expansion in hook command path untested. Hook stdin JSON schema (`tool_input.command`, `tool_input.file_path`) confirmed via docs but not verified at runtime.
- **System flake integration**: Flake designed for both `nix run github:bugeats/claude` and inclusion in a system flake via `packages.default`. Neither path tested end-to-end.
