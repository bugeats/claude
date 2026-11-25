# Tasks

Open tasks, one heading per plan. `(next: N)` is the plan's next free ID; a closed task's entry is deleted.

## REGS — task registry (next: 4)

- **REGS-3** Tracker-backed registry unexercised: no session has run against a declared Linear or GitHub Issues registry. Observe which writes a session makes (status, comments, new tickets) before prescribing a policy, and whether the tracker links a PR from the crystallized commit's closing line.

## LOCL — personal focus in `CLAUDE.local.md` (next: 5)

- **LOCL-3** A sibling git worktree does not see the main checkout's `CLAUDE.local.md` (Claude Code walks upward only), so a worktree session starts without focus.
- **LOCL-4** `/checkpoint` Step 2 has only been followed by hand from the source tree. Run it as a skill under a rebuilt plugin, including the branch that adds the ignore rule.

## OPTN — opt-in via output styles (next: 6)

- **OPTN-5** Mid-session style switching: an `outputStyle` settings change does not rebuild the system prompt within a turn. Whether it applies on the next user turn or only after `/clear` is unknown; record the answer in [launcher.md](launcher.md) once observed.

## SHIP — ship flow verification (next: 3)

- **SHIP-1** Consolidate loop untested: `/consolidate` has not run against mixed checkpoints and crystallized commits, nor via `/shipit` Phase 4, where negentropy would rewrite code on the PR branch.
- **SHIP-2** Stack flow untested: `/shipit` stack detection, `gh stack link`, and the post-ship reset-sync have not run against a real stacked PR.

## PLUG — plugin loose ends (next: 7)

- **PLUG-1** Bare skill names: whether `/checkpoint` resolves to the plugin skill in the TUI, and what wins when a user-scope skill shares the name, is unverified.
- **PLUG-2** rust-analyzer is a removal candidate: registered unconditionally, referenced by no guidance, never observed in use. Drop the MCP config, its flake inputs, and the [dependencies.md](dependencies.md) entry together.
- **PLUG-3** Permission rule semantics: `Bash(nix:*)` matches `nix` subcommands but not hyphenated binaries like `nix-prefetch-github`.
- **PLUG-4** System flake integration: consuming `packages.default` from another flake is untested.
- **PLUG-5** Color tuning: brand purple `#B388FF` is approximate; verify against Claude Code TUI source if possible.
- **PLUG-6** Unverified on a fresh `nix run --refresh`: statusline rendering and skill resolution under `${CLAUDE_PLUGIN_ROOT}`.
