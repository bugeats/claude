# Claude Code Configuration Flake

Nix flake that manages Claude Code user-level configuration. The default package (`claude-bootstrap`) symlinks authored config into `~/.claude/` and execs `claude`.

## Current Focus

Skill extraction from system prompt complete. System prompt is 78 lines — standing constraints only. Procedural content lives in skills.

Open items:

- **settings.json write-back**: Claude writes `feedbackSurveyState` to settings.json. Symlink to read-only store path may fail — may require copy-with-merge strategy.
- **Hook verification**: `$HOME` expansion in hook command path untested. Hook stdin JSON schema (`tool_input.command`, `tool_input.file_path`) confirmed via docs but not verified at runtime.
- **System flake integration**: Flake designed for both `nix run github:bugeats/claude` and inclusion in a system flake via `packages.default`. Neither path tested end-to-end.

## Architecture

```
flake.nix                    # default package = claude-bootstrap wrapper
settings.json                # user-global settings + hook config (symlinked)
skills/checkpoint/SKILL.md   # user-scoped skill: tidy, consolidate, doc, commit
skills/nix-build/SKILL.md    # user-scoped skill: nix build + diagnostic discipline
skills/negentropy/SKILL.md   # user-scoped skill: compression, decomposition, comments, names
hooks/nix-format.sh          # PostToolUse hook: nixfmt via nix run (symlinked)
hooks/nix-guardian.sh        # PreToolUse hook: prompt before non-nix build commands (symlinked)
```

**Authored vs runtime**: only the files in this repo are symlinked. Everything else in `~/.claude/` (projects, history, sessions, cache, store.db) is mutable runtime state left unmanaged.

**Dependencies**: hook scripts assume `jq` and `nix` on PATH at runtime. Formatting runs `nixfmt-rfc-style` ephemerally via `nix run nixpkgs#nixfmt-rfc-style`.

## Commands

```
/nix-build                     # nix build --print-build-logs
/nix-build my-foo              # nix build .#my-foo --print-build-logs
nix run                        # bootstrap config + launch claude
```
