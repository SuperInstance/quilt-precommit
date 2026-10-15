# quilt-precommit

> A git pre-commit hook that validates `record.json` files in the git.pp format. The hook calls into `git.pp-doctor` for the actual validation logic.

## Why

When you're working on a git.pp record set, you want to know that every `record.json` file is valid *before* you commit it. A typo in a field name, a missing `parents` array, a non-canonical encoding — these are silent failures that only surface when the fold is run.

This hook is the front door: it runs `git.pp-doctor check` on every modified `record.json` in the staged set. If any record fails, the commit is blocked.

## Install

```bash
# In your git.pp project's root:
git clone https://github.com/SuperInstance/quilt-precommit .git/hooks/quilt-precommit
ln -s ../quilt-precommit/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/quilt-precommit/pre-commit
```

## What it checks

For each staged `record.json`:

1. **Structural**: has `id`, `kind`, `parents`, `effects`; `id` is a non-empty string; `kind` is one of `task`, `override`, `witness`.
2. **Encoding**: no empty `effects`; effects are strings, numbers, or nulls (no nested objects beyond a single level for known compound fields like `feature.x`, `config.x`).
3. **Closure completeness**: every parent referenced in `parents` exists as a record's `id` in the staged set or in the pinned record set (loaded from `.gitpp/records.json` if present, else just the staged set).
4. **Cycle detection**: a `record.json` whose `parents` form a cycle (directly or transitively) is flagged.
5. **Encoding consistency**: if a sibling `*.expected.json` is present, the leaf hash is compared to the expected value.

The hook exits 0 on success, 1 on any failure (with a clear message), 2 if `git.pp-doctor` is not installed.

## Disabling per-commit

If you ever need to commit a record.json that fails the check (rare, but happens when migrating between formats):

```bash
git commit --no-verify
```

## Limitations

- The hook does not check the closure ROOT — only the closure COMPLETENESS. The root is a property of the record set, not of an individual record, and the hook only has access to the staged subset.
- The hook does not enforce the fold's class-precedence rules — those are checked at fold time, not commit time.
- The hook is intentionally permissive: it blocks the most common mistakes (typos, missing fields) but does not try to be the spec. The spec lives at SuperInstance/git.pp-spec.
