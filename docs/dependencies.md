# Dependencies

All runtime packages are declared in `flake.nix` — no ambient PATH assumptions beyond `nix`, `bash`, and `git` where noted.

## Launcher Inputs

`claude`, `coreutils`, `gh`, `git`, `grep`, `jq`, `rg`, `rust-toolchain`. These form the model's shell toolset.

The `gh-stack` extension is user-level state, not shipped by the flake; `/shipit` uses it for stack registration when present and degrades to plain `--base` targeting when absent.

## Hooks and Tools

Each script under `hooks/` and `tools/` is a `writeShellApplication` with its own `runtimeInputs`, declared in the `scripts` attrset in `flake.nix`. Skills invoke tools via `${CLAUDE_PLUGIN_ROOT}/tools/<name>.sh`; `statusline.py` locates them `__file__`-relative. `nix-status.sh` calls `nix` from the host PATH.

## Rust Toolchain

Provided by `oxalica/rust-overlay` tracking latest stable: rustc, cargo, rust-analyzer, rust-src, rustfmt, clippy.

`rust-analyzer-mcp` is built from source via `rustPlatform.buildRustPackage` (pinned at v0.2.0, `zeenix/rust-analyzer-mcp`) and wrapped so the toolchain's `rust-analyzer` is on its PATH.

## Formatting

`nix-format.sh` runs the pinned `nixfmt`. `rust-format.sh` runs the toolchain's `rustfmt`.
