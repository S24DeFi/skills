# Skills

Small shell helpers and shared config for local development workflows.

## Configuration (`.env.local`)

1. Copy `.env.example` to `.env.local` in this directory.
2. Set `ENV_SYNC_WORKSPACE`, `ENV_SYNC_PROJECT`, and/or `ENV_SYNC_PROJECT_ROOT` for your machine.
3. Add any future variables documented by other skills here the same way.

`.env.local` is gitignored. Only `.env.example` is committed.

## `hub.sh` (recommended)

One line loads everything in this folder:

```bash
source /path/to/skills/hub.sh
```

- Sets `SKILLS_ROOT` (unless you already exported it).
- Sources **`env-sync.sh`** first (loads `.env.local`, defines `syncenv`, `syncccip`, alias `syncday`).
- Then **`git-branch-workflow.sh`**: `cleanbranches`, `cleanorphans` (optional: `SKILLS_GIT_REMOTE`, `SKILLS_PROTECTED_BRANCHES`).
- Then **`networking-workflow.sh`**: `myip` (optional: `SKILLS_MYIP_URL`).
- Then any **other** `*.sh` files in this directory (except `hub.sh`), in sorted order, so new skills are included without editing the hub.

## `env-sync.sh` (minimal)

If you only want env sync helpers and not git/network commands:

```bash
source /path/to/skills/env-sync.sh
```

You can also `source` individual `*-workflow.sh` files alone if you set `SKILLS_ROOT` first.

Sourcing works from **Bash** or **Zsh**. Skills root is detected automatically; you can override with `SKILLS_ROOT` in `.env.local` or before sourcing.
