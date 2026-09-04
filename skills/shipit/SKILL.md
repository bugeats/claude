---
name: shipit
description: Open a GitHub pull request from negentropy'd arcs
user-invocable: true
argument-hint: [feature-tag]
---

Announce: `Arc Close: 🏁 Shipit — We Now Cross The Threshold`

You are now operating as a suspended scheduler that has switched to evaluation mode. This is not a formality. This is a phase transition from internal work to a shareable, reviewable deliverable.

This is the Greater Arc: a _compression_ of one or more negentropy'd Major Arcs into a single commit on a pull request branch. By the time `/arcs:shipit` runs, each Major Arc upstream should already be a single clean commit. If checkpoints remain in the range, the input is not yet crystallized — stop and direct the user to `/arcs:negentropy` first.

All rewriting happens on a fresh PR branch. The original branch is read, never written, until the final sync phase deliberately hands it the crystallized history.

## Phase 1 — Pre-flight

Record the current branch name — Phase 7 returns to it.

Refuse to proceed if any of the following fail. Report the specific failure and stop.

- Working tree clean (no staged or unstaged changes, no work-in-progress untracked files).
- A GitHub remote is configured (`gh repo view`).
- `gh` is authenticated (`gh auth status`).
- HEAD is ahead of `origin/main` (after `git fetch origin main`).
- No CHECKPOINT commits exist in `origin/main..HEAD` — if any, direct the user to `/arcs:negentropy` first.

Improvise additional checks if context suggests them (e.g. branch protection rules, missing PR template, dirty submodules).

## Phase 2 — Stack Detection

The new PR may belong on top of pending PRs rather than on main. The evidence is in local history: work built on a pending PR carries that PR's commits — or patch-equivalents of them — beneath the new work.

```
gh pr list --author "@me" --state open --json number,headRefName,baseRefName,title
```

No open PRs → the base is `origin/main`; skip to Phase 3.

For each candidate, fetch its head and test containment:

```
git fetch origin <headRefName>
git cherry HEAD origin/<headRefName>
```

Every line `-` (or empty output) means all of that PR's commits have patch-equivalents in local history: the PR is **contained**.

- No contained PRs → base on `origin/main`.
- Contained PRs forming a chain (each PR's base is the previous PR's head) → the stack parent is the chain's tip. Base on `origin/<tip-head>` and record the tip's PR number.
- Ambiguous — a PR only partially contained (mixed `+`/`-`), contained PRs on divergent chains, or containment that contradicts commit-message evidence → present the candidates to the user and ask which (or none) to stack on. Do not guess.

From here, `<base>` names the chosen ref and `<base>..HEAD` is the shipped range.

## Phase 3 — Compose The Branch

Determine the PR branch name: `<kebab-identity>/pr/<feature-tag>`.

The identity comes from `git config user.name`. Kebab-case it at runtime; if it is empty, stop and ask the user to set it:

```
identity=$(git config user.name | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g; s/^-\+\|-\+$//g')
```

Derive the feature-tag with nuance:

- If `$1` is provided, slugify it to kebab-case and use it.
- Otherwise, infer from the current branch name when it carries signal (strip common prefixes like `feature/`, `feat/`, `wip/`; slugify the remainder).
- If the current branch is `main`, `master`, or generic, synthesize a short slug from the commits being shipped — read their messages and choose 2-4 words that capture the deliverable.

If the current branch already matches `<kebab-identity>/pr/*`, work in place. Otherwise create a fresh branch from current HEAD:

```
git checkout -b <kebab-identity>/pr/<feature-tag>
```

## Phase 4 — Rebase Over Base

Rebase the PR branch over `<base>`:

```
git rebase <base>
```

Local commits patch-equivalent to already-shipped stack commits drop automatically — expected and desired. Afterward, `<base>..HEAD` is exactly the new work.

If conflicts arise, **resolve them**. You have full context of the change set and the upstream — use it. Bias toward intent preservation: the local commits represent crystallized intent, the upstream represents the integration target.

If you cannot resolve with confidence — both sides made intentional, semantically incompatible changes, and there is no clear winner — `git rebase --abort`, return to the original branch, delete the PR branch, surface the conflict to the user, and stop.

## Phase 5 — Squash Crystallized

All commits in `<base>..HEAD` collapse into a single commit. Compose the commit message from the full messages of every commit in the range.

Format:
```
<imperative summary>

- <descriptive bullet points (exempt from the evergreen rule)>
```

The imperative summary becomes the PR title. Keep it under 72 characters so GitHub does not truncate it in lists. If you cannot fit the deliverable in 72 characters, the scope is wrong — escalate to the user.

Squash:
```
git reset --soft <base> && git commit
```

Verify with `git log --oneline <base>..HEAD` — there should be exactly one commit.

## Phase 6 — Push And Open

Push with `--force-with-lease` (safe against unseen remote updates, allows updates to existing PR branches):

```
git push --force-with-lease --set-upstream origin <branch>
```

Open the pull request as ready (not draft). Title is the imperative summary. Body is the bullet list from the squashed commit message, verbatim. When stacked, target the parent's head branch:

```
gh pr create --title "<summary>" --body "<bullets>" [--base <parent-head>]
```

When stacked, register the chain on GitHub (creates a stack, or extends the parent's existing one):

```
gh stack link <parent-pr-number> <new-pr-number>
```

If the `gh-stack` extension is not installed, the `--base` targeting alone still chains the PRs correctly — mention that `gh extension install github/gh-stack` adds the GitHub stack UI, and move on.

Report the PR URL.

## Phase 7 — Return And Sync

Everything above the stack on the original branch was compressed into the PR commit; hand the branch the crystallized history so it stays rebase-clean:

```
git checkout <original-branch>
git reset --hard <pr-branch>
```

The reflog preserves the old tip. Skip this phase when shipping happened in place on a PR branch.

The original branch now reads: main, then the pending stack, then one crystallized commit — patch-identical to the open PRs. As stack PRs squash-merge, a plain `git fetch origin main && git rebase origin/main` drops the merged commits by patch-id. Its next push needs `--force-with-lease`.

## After Shipping

The PR branch's invariant is one commit. Review feedback is `git commit --amend` then `git push --force-with-lease`, followed by re-syncing the original branch as in Phase 7.

Resume the prior task.
