# Local AI Skills — Codex + Claude Code, one Git repo

A project-independent collection of **local skills** and **Git-managed upstream skill libraries**. Each skill is linked into each agent's *user-level* skills directory, so application repositories never need copies of `SKILL.md`.

## What's included

| Source | Official upstream | Skills directory |
|---|---|---|
| Pstack port | [michael-denyer/pstack-claude](https://github.com/michael-denyer/pstack-claude) | `plugins/pstack/skills/` |
| Ponytail | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | `skills/` |
| Thermos (thermo-nuclear reviews) | [cursor/plugins](https://github.com/cursor/plugins) | `thermos/skills/` |
| Superpowers | [obra/superpowers](https://github.com/obra/superpowers) | `skills/` |

The repo also includes its own `implementation-planning`, `integrate`, `full-implementation`, `code-review`, `qa-testing`, and **`cleanup`** skills. The external repositories are **not bundled in this ZIP**: the one-time setup clones them from their upstream sources so that you can update them using Git.

> **Important:** This is a **skills-only** installation. Upstream plugin-specific hooks, custom agents, CLI binaries and lifecycle integrations (e.g. Ponytail's always-on hooks or Pstack's SessionStart routing) are **not installed**. The Markdown skill files are available, but any upstream feature requiring a native plugin may not work through symlinks alone. To get those features, follow the upstream plugin installation separately; avoid duplicate skill names.

## First-time setup (macOS / Linux)

Requirements: `git`, Bash, network access to GitHub, and at least one of Claude Code or Codex installed and authenticated separately.

Unzip this folder into a stable location, for example `~/workspace/ai-skills/`, then run:

```bash
cd ~/workspace/ai-skills
./scripts/setup.sh
```

Setup will **clone** the four approved sources under `external/`, create individual symlinks for all discovered skill folders in both personal/global agent directories, and run the doctor. The installer **does not overwrite** existing files or unrelated symlinks. External Git repos are ignored from this manager's version control.

To preview the links after fetching sources:

```bash
./scripts/install.sh --dry-run
```

To install only to one agent:

```bash
./scripts/sync.sh
./scripts/install.sh --provider claude  # or codex
./scripts/doctor.sh --provider claude
```

## Run /full-implementation or /integrate in any project

Start your coding agent in the **application repository**, not in `ai-skills`. The global links make these workflows available everywhere.

**Claude Code:**

```text
/full-implementation --base develop Add a new wallet connection flow
/full-implementation Fix the incorrect account switching behavior
/integrate --plan ~/.local/state/ai-skills/runs/my-task/plan.md --max-rounds 5
```

**Codex:** use the same names with `$` instead of `/`:

```text
$full-implementation --base develop Add a new wallet connection flow
$integrate --plan ~/.local/state/ai-skills/runs/my-task/plan.md
```

The **first** skill uses `implementation-planning` to inspect the repository, write a bounded scope and testable `AC-*` acceptance criteria, ask for necessary clarifications, and request **approval of the concrete plan**. After approval it hands the **complete plan** to `integrate`. Running `/full-implementation` does **not** pre-approve an unseen scope.

The **second** skill takes an approved plan from the conversation or `--plan PATH`, implements the `STEP-*` tasks, then calls/applies the installed `code-review` and `qa-testing` instructions. It runs reviewers as independent read-only agents **if supported by the host**, otherwise it performs distinct passes and discloses that fallback. Review and QA evaluate the **same current change set**. If either fails, the implementation agent fixes the findings and **both** gates rerun. Success requires both to pass on the final changes.

**Stops and defaults:**

- Default review/QA cap: **5 rounds**; use `--max-rounds 1..10` to change it. An unresolved failure at the cap isn't reported as a pass.
- `--base REF` is optional and **never defaulted to `main`**; without it the reviewers examine only this implementation's changes and relevant surrounding code. An explicit base can add branch context.
- Required tests that cannot execute produce **BLOCKED**, not PASS. The agent asks for access/clarification or reports which checks remain unverified.
- Work is restricted to the approved scope and preserves existing user modifications. The agent won't automatically commit, push, reset, deploy, or move Jira tickets.
- Planning handoff follows [`skills/implementation-planning/references/handoff-template.md`](skills/implementation-planning/references/handoff-template.md). No skills need to be copied into application repos.
- These are **instructions**, not a deterministic CLI engine. The coding host must have access to code-editing and testing tools; independent subagents and nested skill invocation depend on host capabilities.

See [`skills/full-implementation/SKILL.md`](skills/full-implementation/SKILL.md), [`skills/integrate/SKILL.md`](skills/integrate/SKILL.md), and [`skills/integrate/references/agent-contracts.md`](skills/integrate/references/agent-contracts.md).

## Run /cleanup in any project

Start Claude Code or Codex **inside the project you want to review** (not inside `ai-skills`).

Claude Code interactive prompts:

```text
/cleanup
/cleanup --base develop
/cleanup --base release/next --apply
```

Codex CLI/IDE:

```text
$cleanup
$cleanup --base develop
$cleanup --base develop --apply
```

- `/cleanup` defaults to a **read-only** analysis of uncommitted working-tree changes, including staged and relevant untracked files. It does **not** assume `main` as a comparison branch.
- `--base <branch>` adds committed branch differences relative to the branch **you specify**.
- `--apply` expresses a desire to fix findings, but the agent first shows the plan and waits for **explicit approval** before making changes.
- Ponytail's `ponytail-review` handles source-code problems. Pstack's `unslop` handles **writing/technical prose** in documentation, comments and copy — `unslop` is **not** a source-code simplifier.
- Where the host supports parallel subagents, it delegates independent, read-only reviews to agents. After approval, only **one** implementation agent writes changes, and a separate reviewer verifies the result. Without native subagent capability, it runs separate passes but must report that the review was not independent.
- Optional Thermos checks provide stricter security and maintainability auditing. Superpowers' verification skill guides test evidence.
- The skill doesn't make commits, pushes, merges, or automatic branch resets.

See [`skills/cleanup/SKILL.md`](skills/cleanup/SKILL.md) and [`skills/cleanup/references/agent-contracts.md`](skills/cleanup/references/agent-contracts.md) for the full workflow and delegation contracts.

## Directory structure

```text
ai-skills/
├── skills/                      # Your own version-controlled skills
│   ├── cleanup/
│   │   ├── SKILL.md
│   │   └── references/agent-contracts.md
│   ├── code-review/
│   ├── full-implementation/
│   │   └── SKILL.md
│   ├── implementation-planning/
│   │   └── references/handoff-template.md
│   ├── integrate/
│   │   ├── SKILL.md
│   │   └── references/agent-contracts.md
│   └── qa-testing/
├── external/                    # Auto-cloned upstreams (gitignored)
│   ├── pstack/
│   ├── ponytail/
│   ├── thermos/
│   └── superpowers/
├── sources.tsv                  # Approved upstream URLs and skill locations
├── scripts/
│   ├── setup.sh                 # Clone + link + verify
│   ├── sync.sh                  # Clone or fast-forward upstream sources
│   ├── install.sh               # Link without overwriting
│   ├── update.sh                # Fast-forward + link newly added upstream skills
│   ├── doctor.sh                # Check links, conflicts and clones
│   ├── uninstall.sh             # Remove only links owned by this repository
│   └── test.sh                  # Offline smoke tests with temporary HOME
└── README.md
```

For each skill:

```text
~/workspace/ai-skills/external/ponytail/skills/ponytail-review/
  -> ~/.claude/skills/ponytail-review/     (Claude Code)
  -> ~/.agents/skills/ponytail-review/     (Codex)
```

Because these are symlinks, **edits in the central repository apply immediately** to the linked skill. Restart your agent session if its skill discovery list is stale. No local copies in individual projects.

## Updates and maintenance

```bash
./scripts/update.sh      # git pull --ff-only in all four upstream clones; link new skills
./scripts/doctor.sh      # show missing sources/links and conflicts
./scripts/uninstall.sh   # remove this repo's symlinks; leave clone and other skills intact
./scripts/test.sh        # self-test without touching your actual HOME
./scripts/validate-skills.sh # validate local skill contract and handoff
```

**Conflict behavior:** If a skill name already exists in an agent's global skills directory, this installer skips it and reports a conflict. For duplicates **within** these sources, priority is local skills, then Pstack, Ponytail, Thermos, Superpowers. Re-running `install.sh` won't overwrite another tool's installation. Upstream Git updates are **fast-forward only**; local upstream edits or non-fast-forward changes stop the update.

## Git and safety

This starter ZIP is a **local Git repo template**, not a remote Git repository yet:

```bash
cd ~/workspace/ai-skills
git init
git add .
git commit -m "Add central agent skills and cleanup workflow"
```

- Read upstream `SKILL.md` instructions before trusting an agent to execute any supplied commands. Linking skills makes their instructions available to agents with your local tool permissions.
- `sync.sh` clones the published upstream Git repos and checks that the expected skill tree exists; it does **not execute** upstream scripts or register hooks.
- `update.sh` tracks current upstream default branches (latest compatible versions are **not pinned**). Review diffs/commits in `external/<source>` before updating if reproducibility is important.
- If you need native hook/plugin behavior, prefer the upstream plugin's documented install method rather than assuming Markdown-only skill links enable those features.
- Source licensing and attribution remain with the external cloned repositories. The ZIP does not redistribute their content.
