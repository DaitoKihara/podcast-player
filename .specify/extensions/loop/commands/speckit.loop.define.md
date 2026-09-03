---
description: "Define an autonomous loop as a recursive goal: purpose, done-criteria, iteration budget, maker/checker roles, allowed tools, and guardrails — externalized to per-feature loop state files"
---

# Define a Loop

Turn "I'll keep prompting until it's done" into a **loop you designed**. A loop,
in Loop Engineering terms (Addy Osmani,
[Loop Engineering](https://addyo.substack.com/p/loop-engineering)), is a
*recursive goal*: you define a purpose and the agent iterates until complete.
This command writes that purpose down as a contract and creates the externalized
state the loop runs on — because the model forgets everything between runs, so
the memory has to live on disk.

Defining the loop **before** running it is the whole point: an undefined loop has
no stop condition, no grader, and no record — exactly the shape that drifts into
unattended verification gaps and cognitive surrender. The contract fixes the
done-criteria, the budget, and the maker/checker split up front.

## User Input

```text
$ARGUMENTS
```

If provided, treat the free text as the loop's **purpose** (the recursive goal —
e.g. "make every task in tasks.md pass its acceptance check"). Inline
`key=value` tokens are budget/policy overrides (e.g. `max_iterations=12
isolation=none`). Both may appear together.

## Steps

### 1. Resolve the loop directory and config

1. Load configuration: read `.specify/extensions/loop/loop-config.yml` if it
   exists; otherwise use the extension defaults (`max_iterations` 8,
   `done_requires_checker_pass` true, checker `independent`+`adversarial`, human
   sign-off required). Apply `SPECKIT_LOOP_*` environment overrides, then any
   `key=value` tokens from `$ARGUMENTS` (highest precedence).
2. Determine `FEATURE_DIR`:
   - If the current git branch matches a feature directory under `specs/`
     (e.g. branch `003-user-auth` → `specs/003-user-auth/`), use it.
   - Otherwise use the most recently modified directory under `specs/`.
   - If none exists, fall back to `state.fallback_directory`
     (default `.specify/loops/global/`).
3. `LOOP_DIR = FEATURE_DIR/<state.directory>` (default `specs/<feature>/loop/`).

### 2. Idempotency check

If `LOOP_DIR/loop.md` already exists, **do not overwrite anything**. Report that
a loop is already defined, then behave like `/speckit.loop.status` and stop. If
the user supplied a new purpose in `$ARGUMENTS`, append it to the `## Purpose`
section of `loop.md` as an additional numbered goal rather than replacing it.

### 3. Elicit the contract

From `$ARGUMENTS`, the active `spec.md`/`tasks.md` if present, and at most a few
clarifying inferences, fill in the loop contract. The non-negotiable fields:

- **Purpose** — the recursive goal in one sentence. What does "the AI iterates
  until complete" mean here?
- **Done-criteria** — an explicit, checkable list. Each criterion must be
  something the *checker* can pass or fail against a primary source (a passing
  test, a file that exists and matches a shape, an endpoint that returns X). "It
  works" is not a criterion; "`npm test` exits 0 and `/health` returns 200" is.
  Without checkable done-criteria the loop has no stop condition — refuse to
  proceed and ask for them.
- **Budget** — `max_iterations` (hard ceiling) and any per-iteration scope note.
- **Roles** — the **maker** (produces work) and the **checker** (grades it).
  Record that they must be different agents/sessions: the model that wrote the
  code is too generous grading its own homework.
- **Allowed tools / connectors** — which MCP tools, commands, or external
  systems the loop may use (component: plugins & connectors). Default: only what
  the core Spec Kit workflow already uses.
- **Isolation** — `worktree` (each iteration in its own git worktree so parallel
  runs never collide) or `none`.
- **Automation trigger** — how this loop is meant to be driven: manually
  (`/speckit.loop.run`), or wired to a scheduler/CI (record the intended
  trigger; the extension does not schedule anything itself).
- **Guardrails** — sign-off required? debt tracking on? These default from config.

### 4. Create the state files

Create `LOOP_DIR` and write each file below exactly once. Replace every `<...>`
with the resolved value and today's date.

`loop.md` — the contract and live status:

```markdown
# Loop Contract

## Purpose
1. <purpose from $ARGUMENTS>

## Done-criteria
| ID | Criterion (checkable) | How the checker verifies it | Status |
|----|-----------------------|-----------------------------|--------|
| D1 | <criterion> | <primary-source check> | pending |

Statuses: pending → maker-ready → checker-pass | checker-fail → human-signed.

## Budget
- Max iterations: <loop.max_iterations>
- Iterations run: 0
- Isolation: <loop.isolation>

## Roles
- Maker: produces work toward the criteria (/speckit.loop.run).
- Checker: independent, adversarial grader (/speckit.loop.check). MUST be a
  separate agent/session from the maker.

## Allowed tools / connectors
- <list, or "core Spec Kit workflow only">

## Automation trigger
- <manual | scheduler/CI description>

## Guardrails
- Human sign-off required before done: <guard.require_human_signoff>
- Comprehension debt tracked: <guard.track_comprehension_debt>
- Open blocking debt blocks done: <guard.block_done_on_open_debt>

## State
- Phase: defined
- Last updated: <date>
```

`iterations.md` — the maker's persistent memory (one record per iteration):

```markdown
# Maker Iterations

Append-only. One record per /speckit.loop.run iteration. The maker never marks
the loop done — it records what it attempted and which criteria it believes are
now ready for the checker.

<!-- Record format:
## Iteration <n> — <date>
- Targeted criteria: <D-ids>
- Change: <what was produced/modified, with file pointers>
- Maker self-assessment: <which criteria the maker believes are now ready>
- Open questions / risks: <anything the checker or a human should look at>
- Handoff: ready-for-check
-->
```

`verdicts.md` — the checker's durable verdicts:

```markdown
# Checker Verdicts

A criterion is `pass` only after the checker confirmed it against the PRIMARY
source (a run, a file, an endpoint), not the maker's self-assessment.

| ID | Iteration | Criterion | Method (primary source) | Verdict | Confidence | Date |
|----|-----------|-----------|-------------------------|---------|------------|------|
```

`debt.md` — the comprehension-debt ledger and sign-off log:

```markdown
# Comprehension Debt & Sign-off

Every change the loop makes that a human has not yet understood is debt. Debt is
acknowledged, not deleted. The loop may not declare "done" while blocking debt is open.

## Open debt
| ID | Iteration | What changed | Why it needs human eyes | Severity | Status |
|----|-----------|--------------|-------------------------|----------|--------|

## Sign-off log
| Date | Criterion / scope | Signed off by | Note |
|------|-------------------|---------------|------|
```

`memory.md` — durable decisions carried across runs (the "skills" component):

```markdown
# Loop Memory

Conventions, decisions, and dead ends that should survive between runs so the
loop never re-derives or re-litigates them. Keep entries short and durable.

<!-- - [M-001] <decision/convention/dead-end> (iteration <n>, <date>) -->
```

### 5. Report

Output a short confirmation:

- The resolved `LOOP_DIR` and the five files created.
- The purpose and the done-criteria table (so the user can correct them now).
- The budget, isolation, and guardrail settings in force.
- Next step: `/speckit.loop.run` to take the first maker iteration, or
  `/speckit.loop.status` at any time (including from a fresh session) to resume.

## Guardrails

- Refuse to create a loop with no checkable done-criteria — that is an
  open-ended loop, the exact thing this extension exists to prevent.
- Never overwrite an existing loop; this command only creates or appends a goal.
- Do not start producing work here. `define` writes the contract; `run` does the
  making. Keep this command's own context usage minimal.
