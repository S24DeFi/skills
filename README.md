# Skills

Small shell helpers and shared config for local development workflows.

## Configuration (`.env.local`)

1. Copy `.env.example` to `.env.local` in this directory.
2. Set `ENV_SYNC_WORKSPACE`, `ENV_SYNC_PROJECT`, and/or `ENV_SYNC_PROJECT_ROOT` for your machine.
3. Add any future variables documented by other skills here the same way.

`.env.local` is gitignored. Only `.env.example` is committed.

## `env-sync.sh`

Source from your shell rc (or run `source /path/to/skills/env-sync.sh`):

- Loads `.env.local` from this repo when present (exports all `KEY=value` entries).
- Defines `syncenv`, `syncccip`, and alias `syncday` (see comments in `env-sync.sh`).

Sourcing works from **Bash** or **Zsh**. Skills root is detected automatically; you can override with `SKILLS_ROOT` in `.env.local` or before sourcing.
