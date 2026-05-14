---
name: commit
description: Safely commit and push repository changes using Evgeny's git workflow. Use when the user asks to commit, push, or commit-and-push changes.
---

# Git commit workflow

Use this workflow whenever the user asks to commit changes.

## Non-negotiable rules

- Always pull first before committing.
- Always push to remote after committing.
- Never add `Co-Authored-By` lines to commit messages.
- Never change git config.
- Never use destructive git commands such as hard reset or force push unless the
  user explicitly requests and confirms them.
- Never use `--no-verify` unless the user explicitly requests it.
- Never leave junk files uncommitted or unignored.
- Always use `git add .` to stage all changes; never add individual files.

## Repository root rule

Always run git commands from the repository root directory, not from a
subdirectory. This avoids missing submodule pointer updates or other tracked
files outside the current working directory.

Find the repository root with:

```bash
git rev-parse --show-toplevel
```

Do not assume the current working directory is the git root.

After finding the root, run git commands with `git -C <root>` instead of
`cd <root> && git ...`. This avoids quoting issues with auto-approve patterns.

Examples:

```bash
git -C "C:\Users\Evgeny\Desktop\Kuraga\MultiProg" status --short --branch
git -C "C:\Users\Evgeny\Desktop\Kuraga\MultiProg" pull --ff-only
git -C "C:\Users\Evgeny\Desktop\Kuraga\MultiProg" add .
```

## Before committing

1. Find the git root:

   ```bash
   git rev-parse --show-toplevel
   ```

2. Inspect status from the root:

   ```bash
   git -C <root> status --short --branch
   ```

3. Inspect changes from the root:

   ```bash
   git -C <root> diff
   git -C <root> diff --staged
   git -C <root> log --oneline -5
   ```

4. Pull before committing:

   ```bash
   git -C <root> pull --ff-only
   ```

   If fast-forward pull is not possible, stop and report the situation unless
   the user has explicitly allowed rebasing or conflict resolution.

5. Check for unstaged and untracked files with:

   ```bash
   git -C <root> status --short --branch
   ```

6. If there are junk files, either add them to `.gitignore` or remove them.
   Never leave junk files uncommitted or unignored.

## Submodule rule

If a submodule is modified, commit and push it first, following these same rules,
before committing the main project.

For each modified submodule:

1. Find the submodule's own root:

   ```bash
   git -C <submodule-path> rev-parse --show-toplevel
   ```

2. Run the full commit workflow inside that submodule root:
   - inspect status and diffs;
   - pull first;
   - handle junk files;
   - `git add .`;
   - commit;
   - push.

3. Return to the parent repository root.
4. Stage all parent changes with `git add .`.
5. Commit and push the parent repository pointer update.

Never commit the parent repository before the modified submodule commit has been
pushed successfully.

## Staging rule

Always stage with:

```bash
git -C <root> add .
```

Never stage individual files. Adding individual files can create inconsistencies
when files are edited manually or when generated side changes are present.

## Commit message style

Use:

1. Short summary line describing what was done.
2. Blank line.
3. Bullet-point details of specific changes.

Do not add `Co-Authored-By` lines.

Example:

```text
Add static assertions for protocol structure sizes (64-bit migration)

Ensures binary protocol compatibility across 32-bit and 64-bit builds:
- dev_data: 64 bytes
- BaudRate: 1 byte
- CommunicationMode: 1 byte
- MultiProgCommand: 1 byte
```

For submodule pointer bumps, use a clear summary such as:

```text
Bump kt_swd_prog: helper script naming

- Update kt_swd_prog after helper script naming cleanup.
- Pick up relocated target-specific documentation.
```

## Commit and push sequence

After all checks pass:

```bash
git -C <root> add .
git -C <root> commit -m "Short summary" -m "- Bullet detail one.\n- Bullet detail two."
git -C <root> push
git -C <root> status --short --branch
```

If push is rejected because the remote advanced, do not force push. Pull/rebase
only if appropriate for the situation and safe to do so, then push again:

```bash
git -C <root> pull --rebase
git -C <root> push
```

If conflicts occur, stop and ask the user how to proceed.

## Final report

After committing and pushing, report:

- repository or submodule committed;
- commit hash and commit subject;
- push result;
- final `git status --short --branch` state.
