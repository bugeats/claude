# Dependencies

All runtime packages are declared in `flake.nix` `runtimeInputs` — no ambient PATH assumptions.

## Runtime Inputs

`claude`, `jq`, `grep`, `git`, `rg`, `coreutils`, `python3`, `figlet`, `tte`, `rust-toolchain`, `rust-analyzer-mcp`

## Tools

Scripts in `tools/` ship to `~/.claude/tools/` via `install -m 0755` (copied, not symlinked). They run in the user's session with bootstrap-provided PATH plus ambient system tools (`pgrep`, `ps`, `awk`, `find` assumed available).

## Rust Toolchain

Provided by `oxalica/rust-overlay` tracking latest stable: rustc, cargo, rust-analyzer, rust-src, rustfmt, clippy.

`rust-analyzer-mcp` is built from source via `rustPlatform.buildRustPackage` (pinned at v0.2.0, `zeenix/rust-analyzer-mcp`).

## Fonts

The miniwi figlet font is fetched via `pkgs.fetchurl` (hash-pinned, source: `xero/figlet-fonts`).

## Formatting

`nix-format.sh` runs `nixfmt-rfc-style` ephemerally via `nix run`. `rust-format.sh` uses `rustfmt` from the toolchain PATH.
