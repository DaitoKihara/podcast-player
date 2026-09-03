---
description: "Stay-the-engineer checkpoint: surface comprehension debt and unattended-verification risk, then require explicit human sign-off before the loop may declare done"
---

# Guard the Loop (Stay the Engineer)

The point of a loop is to do work without you holding the tool through every
turn — but the danger is the same automation: verification that no one watched,
comprehension debt that compounds, and the quiet temptation to accept whatever
the loop produced. This checkpoint exists for one reason: *build the loop, but
build it like someone who intends to stay the engineer.*

`guard` does not grade correctness (that is the checker). It defends the three
things autonomy erodes — **attention, understanding, and judgment** — and it is
the only command that can move the loop to `done`.

## User Input

```text
$ARGUMENTS
```

Optional. `signoff` records a human sign-off (see step 4); a criterion ID scopes
the sign-off to that criterion. With no argument, render the guard report only.

## Prerequisites

Resolve `LOOP_DIR` as in `/speckit.loop.define`. Require a defined loop
(`loop.md` present). Load `loop.md`, `verdicts.md`, `debt.md`, and the
`iterations.md` records since the last sign-off in `debt.md`.

## Steps

### 1. Comprehension-debt sweep

Walk every iteration since the last recorded sign-off. For each change that a
human has **not** demonstrably reviewed, ensure there is an open row in
`debt.md` (`What changed`, `Why it needs human eyes`, severity). Comprehension
debt is the gap between what the loop changed and what a human actually
understands; this sweep makes the gap explicit instead of letting it compound.
New, un-acknowledged changes → new debt rows.

### 2. Unattended-verification check

Cross-read `verdicts.md`:

- Criteria marked `checker-pass` only at `medium`/`low` confidence, or by a
  checker that may not have been independent, are **unattended verifications** —
  flag each for human confirmation.
- Criteria still `uncertain` are verification gaps by definition — list them.

The question this answers is the one the article insists on: your job is to ship
work you confirmed works — so what here has *not* actually been confirmed by a
human?

### 3. Anti-cognitive-surrender prompt

Do not summarize the work in a way that invites a rubber stamp. Instead, put the
human back in the loop with specific, answerable questions derived from the
actual changes, e.g.:

- "Iteration 4 changed `<file>` — in one sentence, why was that necessary?"
- "Criterion D3 passed on the checker's say-so — have you seen it work yourself?"
- "Which of these changes would you not be able to explain to a reviewer?"

Anything the human cannot answer stays as open debt. Surrender looks like
accepting the loop's output without being able to answer these — name that risk
explicitly when it is present.

### 4. The done-gate (and sign-off)

The loop may move to `done` only when **all** hold:

1. Every done-criterion is `checker-pass` in `loop.md`
   (when `loop.done_requires_checker_pass`).
2. No **blocking** (high-severity) debt is open in `debt.md`
   (when `guard.block_done_on_open_debt`).
3. A human sign-off is recorded (when `guard.require_human_signoff`).

When invoked with `signoff`, and only after presenting steps 1–3, append a row to
the `## Sign-off log` in `debt.md` (date, scope, signed off by, note) and mark
the relevant debt rows acknowledged. If all three conditions now hold, set
`loop.md` `Phase: done` and report it. If any condition fails, refuse to mark
done and state exactly which condition is unmet and what would satisfy it.

Never record a sign-off the human did not actually give — `signoff` is a human
action this command logs, not a box the agent may check on its own.

### 5. Report

Output: open comprehension-debt (by severity), unattended/uncertain
verifications, the anti-surrender questions, and the done-gate status —
condition by condition, with the single next action (resolve debt, confirm a
verification, run more iterations, or record sign-off).

## Guardrails

- `guard` does not write code, grade criteria, or fabricate sign-offs. It
  surfaces risk and gates closure.
- Debt is acknowledged, never silently deleted; the ledger is the audit trail of
  what a human chose to accept.
- "Checker-pass on everything" is necessary but not sufficient for done — human
  sign-off is the load-bearing step this command protects.
- If the human cannot answer the anti-surrender questions, the correct outcome is
  *not done yet*, not a sign-off.
