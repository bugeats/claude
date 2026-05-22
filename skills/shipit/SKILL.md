---
name: shipit
description: Open a GitHub pull request from negentropy'd arcs
user-invocable: true
argument-hint: [feature-tag]
---

Announce: `Arc Close: 🏁 Shipit — We Now Cross The Threshold`

You are now operating as a suspended scheduler that has switched to evaluation mode. This is not a formality. This is a phase transition from internal work to a shareable, reviewable deliverable.

This is the Greater Arc: a _compression_ of one or more negentropy'd Major Arcs into a single commit on a pull request branch. By the time `/shipit` runs, each Major Arc upstream should already be a single clean commit. If checkpoints remain in the range, the input is not yet crystallized — stop and direct the user to `/negentropy` first.

All work happens on a fresh PR branch; the original branch stays untouched. The original belongs to the user's history, the PR branch to the reviewer's.

## Phase 1 — Pre-flight

Refuse to proceed if any of the following fail. Report the specific failure and stop.

- Working tree clean (no staged or unstaged changes, no work-in-progress untracked files).
- A GitHub remote is configured (`gh repo view`).
- `gh` is authenticated (`gh auth status`).
- HEAD is ahead of `origin/main` (after `git fetch origin main`).
- No CHECKPOINT commits exist in `origin/main..HEAD` — if any, direct the user to `/negentropy` first.

Improvise additional checks if context suggests them (e.g. branch protection rules, missing PR template, dirty submodules).

## Phase 2 — Rebase Over Main

Rebase the current commit range over `origin/main`:

```
git fetch origin main
git rebase origin/main
```

If conflicts arise, **resolve them**. You have full context of the change set and the upstream — use it. Bias toward intent preservation: the local commits represent crystallized intent, the upstream represents the integration target.

If you cannot resolve with confidence — both sides made intentional, semantically incompatible changes, and there is no clear winner — `git rebase --abort`, surface the conflict to the user, and stop.

## Phase 3 — Compose The Branch

Determine the PR branch name: `<kebab-identity>/pr/<feature-tag>`.

The identity comes from `~/.claude/identity`. Kebab-case it at runtime:

```
identity=$(tr '[:upper:]' '[:lower:]' < ~/.claude/identity | sed 's/[^a-z0-9]\+/-/g; s/^-\+\|-\+$//g')
```

Derive the feature-tag with nuance:

- If `$1` is provided, slugify it to kebab-case and use it.
- Otherwise, infer from the current branch name when it carries signal (strip common prefixes like `feature/`, `feat/`, `wip/`; slugify the remainder).
- If the current branch is `main`, `master`, or generic, synthesize a short slug from the commits being shipped — read their messages and choose 2-4 words that capture the deliverable.

If the current branch already matches `<kebab-identity>/pr/*`, work in place. Otherwise create a fresh branch from current HEAD, leaving the original branch untouched:

```
git checkout -b <kebab-identity>/pr/<feature-tag>
```

## Phase 4 — Squash Crystallized

All commits in `origin/main..HEAD` collapse into a single commit. Compose the commit message from the full messages of every commit in the range.

Format:
```
<imperative summary>

- <descriptive bullet points (exempt from the evergreen rule)>
```

The imperative summary becomes the PR title. Keep it under 72 characters so GitHub does not truncate it in lists. If you cannot fit the deliverable in 72 characters, the scope is wrong — escalate to the user.

Squash:
```
git reset --soft origin/main && git commit
```

Verify with `git log --oneline origin/main..HEAD` — there should be exactly one commit.

## Phase 5 — Push And Open

Push with `--force-with-lease` (safe against unseen remote updates, allows updates to existing PR branches):

```
git push --force-with-lease --set-upstream origin <branch>
```

Open the pull request as ready (not draft). Title is the imperative summary. Body is the bullet list from the squashed commit message, verbatim.

```
gh pr create --title "<summary>" --body "<bullets>"
```

Report the PR URL.

## After Shipping

The PR branch's invariant is one commit. Review feedback is `git commit --amend` then `git push --force-with-lease`.

Resume the prior task.
