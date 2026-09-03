---
description: "Independent checker pass (separate from the maker) that adversarially grades the latest iteration against the done-criteria and records a durable verdict"
---

# Check the Loop (Independent Checker)

Grade the maker's work — adversarially, against primary sources, as someone who
did **not** write it. This is the checker half of the maker/checker split, and
the reason it exists is blunt: the model that wrote the code is way too nice
grading its own homework. Splitting the maker from the checker is what keeps an
autonomous loop honest.

Every check leaves a durable verdict in `verdicts.md`, so the loop's claim that a
criterion is met is always backed by a recorded, re-checkable judgment — not by
the maker's optimism.

## User Input

```text
$ARGUMENTS
```

Optional. May name specific criteria to check (e.g. `D1 D3`) or an iteration
number. Default: every criterion currently `maker-ready` in `loop.md`, for the
latest iteration.

## Prerequisites

Resolve `LOOP_DIR` as in `/speckit.loop.define`. Require a defined loop with at
least one iteration (`loop.md` and `iterations.md` present) — otherwise point to
`/speckit.loop.run` and stop.

**Independence gate.** The checker must be independent of the maker. If
`checker.independent: true` (default) and you (this agent/session) are the same
one that just produced the iteration under review, say so and recommend the user
re-run `/speckit.loop.check` in a **fresh session or as a separate sub-agent**.
A checker that shares the maker's context inherits the maker's blind spots —
prefer to stop over to rubber-stamp.

## Steps

### 1. Read the contract and the claim — but verify the source

Load `loop.md` (the criteria and how each is to be verified) and the latest
`iterations.md` record (what the maker claims it did). Treat the maker's
self-assessment as a **claim to be tested, not evidence**. The iteration record
tells you where to look; it does not tell you what is true.

### 2. Grade each criterion adversarially

For each targeted criterion, in contract order:

1. **Try to make it fail.** Ask what would be observable if the criterion were
   *not* met, and check for that. Run the test, hit the endpoint, open the file,
   exercise the edge case — at the primary source, in a clean state (the
   isolation worktree if one was used).
2. Decide the verdict:
   - `pass` — the primary source satisfies the criterion now, and your attempt to
     break it failed.
   - `fail` — it does not hold (record exactly what was observed and why).
   - `uncertain` — cannot be settled with available access/tools (record what
     would settle it).
   Assign confidence `high | medium | low`. Default to `fail`/`uncertain` when
   genuinely unsure — an unattended loop should under-claim, not over-claim.
3. If `checker.votes > 1`, require that many independent passes to agree before
   recording `pass`; otherwise record the disagreement as `uncertain`.

### 3. Record verdicts and route the outcome

For each criterion, append a row to `verdicts.md` (ID, iteration, criterion,
method/primary source, verdict, confidence, date), then update `loop.md`:

- `pass` → set the criterion to `checker-pass`.
- `fail` → set it to `checker-fail` (it goes back to the maker next `/speckit.loop.run`).
- `uncertain` → leave it `maker-ready` **and** open a comprehension-debt item in
  `debt.md` (an agent could not verify it; a human must), severity per impact.

Set `loop.md` `Phase` to `checked` and update the date.

### 4. Report and recommend

Output, in order:

1. Verdict table: criterion → verdict → confidence → evidence/method.
2. **Failures**, each with what was observed and the smallest change that would
   fix it — input for the next maker iteration, not a fix you apply yourself.
3. **Uncertain** criteria and the debt items opened for them.
4. The gate: if *every* done-criterion is `checker-pass`, do **not** declare the
   loop done. Recommend `/speckit.loop.guard` — a passing checker is necessary
   but not sufficient; a human still has to stay the engineer and sign off.
   Otherwise recommend `/speckit.loop.run` to address failures, or `status`.

## Guardrails

- The checker never edits the implementation and never writes to
  `iterations.md`. It grades and records; making is the maker's job.
- No criterion reaches `checker-pass` from the maker's self-assessment alone —
  only from a primary-source check recorded in `verdicts.md`.
- A passing check is not "done." Only `/speckit.loop.guard` plus human sign-off
  can close the loop.
- Confirmation bias is the failure mode: a check that only re-reads what the
  maker pointed at is not a check. Attempt to break it.
