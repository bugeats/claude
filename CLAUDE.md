# Claude Arcs

Nix flake that ships Claude Code workflow as a **plugin**. Invoked remotely via `nix run github:bugeats/claude --refresh` — no local clone required. The default package (`claude-bootstrap`) prints a banner, performs a one-time v1 cleanup, and `exec claude --plugin-dir $FLAKE_SELF …`. Nothing is staged into `~/.claude/`; everything resolves directly from the immutable Nix store path. Multiple concurrent sessions on one host share the same store path safely.

This is a shared distribution used by teammates and a growing circle of users, not a single-user dotfiles repo. Changes here affect everyone on next bootstrap.

**Two CLAUDE files, two audiences**:

- **`CLAUDE.md`** — project instructions for *this repo only*. Claude reads it when working on claude-arcs itself.
- **`CLAUDE.system.md`** — system-level instructions shipped to the client. Bootstrap passes it via `--append-system-prompt-file`, so Claude Code merges it into the system prompt for every session, every project. It defines workflow, code style, and universal conventions.

## Architecture

```
flake.nix                    # default package = claude-bootstrap wrapper
bootstrap.sh                 # banner + v1 cleanup, then exec claude with plugin flags
.claude-plugin/plugin.json   # plugin manifest (name="arcs", semver, author, …)
hooks/hooks.json             # plugin-scope hook registrations (paths via ${CLAUDE_PLUGIN_ROOT})
.mcp.json                    # plugin-scope MCP server registrations (rust-analyzer)
settings.json                # passed via --settings; statusLine + permissions + remoteControl
CLAUDE.system.md             # passed via --append-system-prompt-file
diagram.txt                  # arc workflow diagram (banner)
skills/<name>/SKILL.md       # auto-discovered by the plugin loader
style/<lang>.md              # language review criteria, read during /checkpoint Step 1
hooks/{nix-format,nix-guardian,rust-format}.sh   # invoked from hooks/hooks.json
tools/{checkpoint-range,nix-status}.sh            # invoked from skills via $CLAUDE_ARCS_ROOT/tools/
statusline.py                # invoked from settings.json via $CLAUDE_ARCS_ROOT/statusline.py
```

The bootstrap exports `CLAUDE_ARCS_ROOT=$FLAKE_SELF` so skills and `settings.json` reference store paths without baking specific hashes into source. Inside `hooks/hooks.json` and `.mcp.json`, Claude Code's own `${CLAUDE_PLUGIN_ROOT}` substitution does the same job.

See [docs/bootstrap-lifecycle.md](docs/bootstrap-lifecycle.md) for v1→v2 migration, identity, and unmanaged state. See [docs/dependencies.md](docs/dependencies.md) for runtime inputs.

## Usage

Bootstrap (from any shell — no local clone required):

```
nix run github:bugeats/claude --refresh
```

Validate plugin changes locally:

```
claude plugin validate .
claude --plugin-dir . plugin details arcs
```

Skills (inside a Claude session, targeting the project flake):

```
/nix                           # show nix skill usage
/nix build [target]            # nix build [.#target] --print-build-logs (background agent)
/nix run [app]                 # nix run [.#app] (synchronous)
/nix status                    # show active nix builds and sandbox dirs
```

## Current Focus

Plugin v2 (`.claude-plugin/plugin.json` + `--plugin-dir`) just landed, replacing the stage-and-teardown bootstrap that broke under concurrent sessions. The next bootstrap is the first real smoke test; verify hook firing, statusline rendering, and skill resolution on a fresh `nix run --refresh`.

Three arcs ship: `/checkpoint` (Minor), `/negentropy` (Major), `/shipit` (Greater). `/negentropy` Phase 2 includes a runtime-entropy lens alongside the Compression Principle — owned in-tree rather than delegating to `/simplify`, since fanning out three review agents per minor arc would discourage frequent checkpoints.

`statusline.py` resolves `tools/checkpoint-range.sh` via `__file__`-relative lookup so the gauge and `/negentropy` rebase share one algorithm. The script wraps its body in a top-level guard, appends tracebacks to `~/.claude/statusline.log`, and always exits 0 — Claude Code suppresses the status line after repeated failures and only retries on restart.

Shipped defaults in `settings.json`: `permissions.defaultMode: "acceptEdits"`, `remoteControlAtStartup: true`, no `model` pin. `statusLine.command` references `$CLAUDE_ARCS_ROOT/statusline.py`; Claude Code shell-expands the variable at invocation time.

`CLAUDE.system.md` is a parallel work surface — the shipped guidance itself. Tightening shipped guidance is fair game at any checkpoint.

Language-specific style is tiered by cost-of-late-detection: mechanical rules → PostToolUse hooks (edit time); surface judgment → `style/<lang>.md` read during `/checkpoint` Step 1 (arc close, deliberately withheld from generation time — review compliance beats generation compliance); structural rules → Universal Code Style in `CLAUDE.system.md` (generation time, must stay tiny). `style/rust.md` seeds the middle tier; add languages by file drop, no prompt or skill edit needed. Crate-gated subsections (`## Tracing` — "for projects using the `tracing` crate") scope rules below the language level; reuse that pattern rather than splitting files per crate.

`/shipit` is the Greater Arc: a compression of negentropy'd Major Arcs into one commit on a PR branch named `<kebab-identity>/pr/<feature-tag>`. It refuses to run if CHECKPOINT commits remain in `origin/main..HEAD`. Identity is kebab-cased at runtime from `~/.claude/identity`.

See [docs/shell-style.md](docs/shell-style.md) for `writeShellApplication` discipline.

Open items:

- **v1→v2 cleanup window**: `migrate_from_v1` runs on every bootstrap. Once the install base has cycled through it, the function and its helper become dead code and should be deleted.
- **Plugin namespace collisions**: if a user already has a user-scope skill named `checkpoint`/`negentropy`/`shipit`/`nix`/`school-me`, the resolution order under `--plugin-dir` is undocumented. Verify, then document.
- **Color tuning**: brand purple `#B388FF` is approximate — verify against Claude Code TUI source if possible.
- **System flake integration**: remote invocation via `nix run github:bugeats/claude --refresh` is the primary path. Inclusion in a system flake via `packages.default` is untested.
- **Permission rule semantics**: `Bash(nix:*)` colon syntax matches `nix` subcommands but not hyphenated binaries like `nix-prefetch-github`.
- **rust-analyzer eagerness**: the plugin registers rust-analyzer unconditionally via `.mcp.json`. The MCP server starts lazily on first tool call — confirmed by component-inventory note but not stress-tested across non-Rust projects.
