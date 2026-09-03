---
description: "Run maker iterations toward the loop's goal, externalizing every iteration to disk; the maker never grades itself and stops to hand off to the checker"
---

# Run the Loop (Maker)

Take the next step toward the loop's recursive goal. This is the **maker** half
of the maker/checker split: it produces work, writes down what it did, and stops.
It deliberately does **not** decide whether the work is correct — that is the
checker's job, run separately, because the model that wrote the code is too
generous grading its own homework.

Each iteration is externalized to `iterations.md` the moment it happens, so the
loop survives a restart, a compaction, or a handoff: a new session resumes from
files, never from a lost conversation.

## User Input

```text
$ARGUMENTS
```

Optional. May name specific done-criteria to target this iteration (e.g.
`D2 D3`) or `n=<k>` to run up to `k` maker iterations back-to-back (still
stopping for a checker handoff after the batch). With no argument, target the
highest-priority `pending`/`checker-fail` criteria.

## Prerequisites

Resolve `LOOP_DIR` as in `/speckit.loop.define`. Require a defined loop
(`loop.md` present) — otherwise instruct the user to run `/speckit.loop.define`
and stop. Load the contract, the iteration counter, and `max_iterations`.

**Budget gate.** If `Iterations run >= max_iterations`, do not produce more.
Stop and report that the iteration ceiling is reached — the loop now requires
`/speckit.loop.check` and `/speckit.loop.guard` (human review), not more making.
This ceiling is a feature: unbounded making is how loops drift.

## Steps

### 1. Orient from state, not from memory

Read `loop.md` (criteria + statuses), the last few `iterations.md` records, and
`memory.md` (durable decisions and dead ends). Do **not** rely on conversation
history — treat the files as the source of truth. Pick the target criteria for
this iteration: prefer `checker-fail` (a previous attempt the checker rejected),
then `pending`, in the contract's order.

### 2. Set up isolation (if configured)

If `loop.isolation: worktree`, make the change in a dedicated git worktree for
this iteration so parallel or repeated runs never collide
(e.g. `git worktree add ../loop-iter-<n> <branch>`). Record the worktree path in
the iteration record. If `none`, work in place.

### 3. Make one increment

Produce the smallest coherent change that moves a targeted criterion toward
`checker-pass`. Stay inside the **allowed tools / connectors** listed in the
contract — if the work needs a tool the contract does not list, stop and say so
rather than reaching for it. Keep the change reviewable: a human and the checker
both have to understand it later.

### 4. Externalize the iteration (mandatory bookkeeping)

Append a record to `iterations.md`:

```markdown
## Iteration <n> — <date>
- Targeted criteria: <D-ids>
- Worktree: <path or "in place">
- Change: <what was produced/modified, with file:line pointers>
- Maker self-assessment: <which criteria the maker believes are now ready — clearly labelled as the maker's own view, NOT a verdict>
- Open questions / risks: <anything the checker or a human should look at>
- Handoff: ready-for-check
```

Then update `loop.md`:

- Increment `Iterations run`.
- Move each targeted criterion the maker believes is complete to `maker-ready`
  (never to `checker-pass` — only the checker sets that).
- Set `Phase: maker-ready` and the `Last updated` date.

If this iteration produced a durable decision, convention, or dead end, add a
one-line `M-xxx` entry to `memory.md` so the next run does not re-derive it.

### 5. Stop and hand off

Do not grade your own work and do not declare the loop done. End the iteration
with an explicit handoff:

- Which criteria are now `maker-ready`.
- The command to grade them: `/speckit.loop.check` — run it as a **separate
  agent/session** so the checker is genuinely independent.
- Remaining iteration budget.

If running a batch (`n=<k>`), repeat steps 1–4 up to `k` times or until the
budget ceiling, then hand off once.

## Guardrails

- The maker never writes to `verdicts.md` and never sets a criterion to
  `checker-pass` or the loop to `done`. Those belong to the checker and the guard.
- One increment per iteration record — keep changes small and individually
  reviewable; a giant unreviewable diff is comprehension debt by construction.
- Respect `max_iterations` as a hard stop, not a suggestion.
- Self-assessment is a hint for the checker, always labelled as the maker's own
  view. If the maker is tempted to write "done," that is exactly the moment to
  hand off instead.
