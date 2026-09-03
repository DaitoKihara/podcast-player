---
description: "Render a compact, budget-aware slice of loop state (goal, per-criterion progress, verdicts, open debt) with one recommended next action; safe session resume"
---

# Loop Status — Budget-Aware Rendering

Render the externalized loop state as a compact working slice: where the loop is,
what is proven, what a human still owes attention to, and the single next action.
Because the loop's memory lives on disk, this command is the **session-resume
entry point** — open a fresh session, run it, and continue exactly where the loop
stopped, with nothing carried over from a lost conversation.

This command is **read-only**: it writes nothing and changes no state.

## User Input

```text
$ARGUMENTS
```

Optional. `full` renders larger slices (3× the configured sizes); a criterion ID
or topic filters the tables.

## Steps

### 1. Locate state

Resolve `LOOP_DIR` as in `/speckit.loop.define`. If no loop exists, say so and
point to `/speckit.loop.define` — do not create anything.

### 2. Load slices only

Read `rendering.*` sizes, then load:

- `loop.md` — purpose, the done-criteria table with statuses, iterations
  run / max, isolation, guardrail settings.
- `iterations.md` — the last `iterations_slice` iteration records (headers +
  handoff state); count the rest.
- `verdicts.md` — latest verdict per criterion, plus counts by verdict.
- `debt.md` — up to `debt_slice` open debt rows (highest severity first) and the
  most recent sign-off; count the rest.

Do not read `memory.md` bodies or spec/plan/code files. Keep output within the
`context_tokens` cap; truncate lowest-severity material first and say what was cut.

### 3. Render the snapshot

```markdown
# Loop Status — <feature> (<date>)

**Purpose**: <purpose line(s)>

**Phase**: <defined | maker-ready | checked | done>   ·   **Iterations**: <run>/<max>

**Done-criteria** (<pass>/<total> checker-pass):
| ID | Criterion | Status | Latest verdict (conf.) |
|----|-----------|--------|------------------------|

**Comprehension debt**: <open> open (<blocking> blocking) · last sign-off: <date or "none">
⚠ Blocking debt: <list or "none">
⚠ Unattended / uncertain verifications: <list or "none">

**Recent iterations**: <slice, one line each: n → targeted criteria → handoff>
```

### 4. Recommend exactly one next action

Close with a single recommendation derived from the snapshot:

- A criterion is `checker-fail` (or all `pending`) → `/speckit.loop.run`.
- Criteria are `maker-ready` and ungraded → `/speckit.loop.check`
  (run as a separate session).
- All criteria `checker-pass` but sign-off/blocking-debt outstanding →
  `/speckit.loop.guard`.
- Iteration ceiling reached with work outstanding → `/speckit.loop.guard`
  (human review), not more `run`.
- All conditions met → loop is `done`; proceed with the feature.

State the reason in one sentence (e.g. "all 4 criteria checker-pass but 1
blocking debt item open → guard before declaring done").

## Guardrails

- Read-only. No file writes, no status changes, not even timestamps.
- Slices, never full files; counts stand in for what is not shown.
- The recommendation must follow from the rendered state alone — if the state
  files are missing or malformed, report that instead of guessing.
