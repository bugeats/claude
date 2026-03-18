# Claude Arcs

Nix flake that manages Claude Code user-level configuration. Invoked remotely via `nix run github:bugeats/claude --refresh` — no local clone required. The default package (`claude-bootstrap`) installs authored config into `~/.claude/`, launches `claude`, and cleans up on exit.

This is a shared distribution used by teammates and a growing circle of users, not a single-user dotfiles repo. Changes here affect everyone on next bootstrap.

**Two CLAUDE files, two audiences**: this repo contains both `CLAUDE.md` (what you're reading) and `CLAUDE.system.md`. They serve different roles:

- **`CLAUDE.md`** — project instructions for *this repo only*. Claude reads it when working on claude-arcs itself. It describes the distribution's architecture, build commands, and open items.
- **`CLAUDE.system.md`** — system-level instructions shipped to the client. Bootstrap symlinks it to `~/CLAUDE.md`, where Claude Code loads it for *every session, in every project*. It defines workflow, code style, and universal conventions.

Skills (`skills/*/SKILL.md`), hooks (`hooks/*.sh`), and tools (`tools/*.sh`) ship to the client. Changes take effect on next bootstrap.

## Architecture

```
flake.nix                    # default package = claude-bootstrap wrapper
bootstrap.sh                 # bootstrap lifecycle: config install, claude launch, teardown
CLAUDE.system.md             # → ~/CLAUDE.md (system instructions, every session)
CLAUDE.md                    # project instructions (this repo only)
settings.json                # user-global settings + hook config (writable copy)
diagram.txt                  # arc workflow diagram (displayed in greeting banner)
skills/checkpoint/SKILL.md   # → ~/.claude/skills/ (tidy, consolidate, doc, commit)
skills/negentropy/SKILL.md   # → ~/.claude/skills/ (DCG-driven fixed-point compression + rebase)
skills/nix/SKILL.md          # → ~/.claude/skills/ (nix build, run, status interface)
skills/school-me/SKILL.md    # → ~/.claude/skills/ (guided tour of this config's workflow)
tools/nix-status.sh          # → ~/.claude/tools/ (show active nix builds, sandbox dirs, daemon workers)
tools/checkpoint-range.sh    # → ~/.claude/tools/ (find CHECKPOINT commit range for negentropy rebase)
statusline.py                # → ~/.claude/ (status line: arc depth, git branch, model, context, cost, churn)
hooks/nix-format.sh          # → ~/.claude/hooks/ (PostToolUse: nixfmt via nix run)
hooks/nix-guardian.sh        # → ~/.claude/hooks/ (PreToolUse: prompt before non-nix build commands)
hooks/rust-format.sh         # → ~/.claude/hooks/ (PostToolUse: rustfmt via rust-toolchain PATH)
```

See [docs/bootstrap-lifecycle.md](docs/bootstrap-lifecycle.md) for artifact management, settings, identity, MCP servers, and unmanaged state. See [docs/dependencies.md](docs/dependencies.md) for runtime inputs, Rust toolchain, and tool dependencies.

## Usage

Bootstrap (from any shell — no local clone required):

```
nix run github:bugeats/claude --refresh
```

Skills (inside a Claude session, targeting the project flake):

```
/nix                           # show nix skill usage
/nix build                     # nix build --print-build-logs (background agent)
/nix build my-foo              # nix build .#my-foo --print-build-logs (background agent)
/nix run                       # nix run (default project app, synchronous)
/nix run my-app                # nix run .#my-app (project flake app, synchronous)
/nix status                    # show active nix builds and sandbox dirs
```

## Current Focus

Bootstrap lifecycle, default permissions, and Rust tooling integration are landed. `/nix` skill has `build` (background agent), `run` (project flake apps), and `status` (build monitoring) subcommands. Tools in `tools/` are defined in this repo and shipped to `~/.claude/tools/` via bootstrap. No flake apps — all tools are bootstrap-managed scripts.

**`writeShellApplication` discipline**: `bootstrap.sh` runs under `set -o errexit nounset pipefail`. Guard `&&` chains in functions with `if` statements — a short-circuiting `&&` chain as the last statement in a `for` loop inside a function propagates non-zero to the call site. Files from `/nix/store/` have `444` permissions — tools and hooks use `install -m 0755` to get executable copies; skills and statusline remain symlinks (read-only is fine).

Open items:

- **Color tuning**: Brand purple `#B388FF` is approximate — verify against actual Claude Code TUI source if possible.
- **Hook verification**: `$HOME` expansion in hook command path untested. Hook stdin JSON schema (`tool_input.command`, `tool_input.file_path`) confirmed via docs but not verified at runtime.
- **System flake integration**: Remote invocation via `nix run github:bugeats/claude --refresh` is the primary usage path. Inclusion in a system flake via `packages.default` is untested.
- **Permission rule semantics**: `Bash(nix:*)` colon syntax matches `nix` subcommands but not hyphenated binaries like `nix-prefetch-github`.
- **MCP lifecycle verification**: `claude mcp add-json`/`remove` subcommands used in bootstrap — untested at runtime. Fallback: direct `jq` manipulation of `~/.claude.json`.
