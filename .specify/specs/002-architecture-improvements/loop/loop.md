# Loop Contract

## Purpose
1. Implement architecture improvements for the podcast-player Flutter app: unify state management under Riverpod, implement working navigation via go_router, and inject all dependencies through Riverpod providers.

## Done-criteria

| ID | Criterion (checkable) | How the checker verifies it | Status |
|----|-----------------------|-----------------------------|--------|
| D1 | Phase 2 (Foundational) tasks complete | `grep "^\- \[X\] T00[4-8]" .specify/specs/002-architecture-improvements/tasks.md` returns all 5 lines | pending |
| D2 | User Story 1 (State Management) tasks complete | `grep "^\- \[X\] T0(09|10|11|12|13|14|15)" .specify/specs/002-architecture-improvements/tasks.md` returns all 7 lines | pending |
| D3 | User Story 2 (Navigation) tasks complete | `grep "^\- \[X\] T0(16|17|18|19|20|21|22)" .specify/specs/002-architecture-improvements/tasks.md` returns all 7 lines | pending |
| D4 | User Story 3 (DI) tasks complete | `grep "^\- \[X\] T0(23|24|25|26|27)" .specify/specs/002-architecture-improvements/tasks.md` returns all 5 lines | pending |
| D5 | Phase 6 (Polish) tasks complete | `grep "^\- \[X\] T0(28|29|30|31|32|33)" .specify/specs/002-architecture-improvements/tasks.md` returns all 6 lines | pending |
| D6 | `flutter analyze` passes with zero errors | `flutter analyze` exits with code 0 | pending |
| D7 | All unit tests pass | `flutter test` exits with code 0 | pending |
| D8 | No `setState` calls remain | `grep -r "setState" lib/` returns zero matches | pending |
| D9 | No direct `AppDatabase.instance` references | `grep -r "AppDatabase.instance" lib/` returns zero matches | pending |

Statuses: pending → maker-ready → checker-pass | checker-fail → human-signed.

## Budget
- Max iterations: 12
- Iterations run: 3
- Isolation: worktree

## Roles
- Maker: produces work toward the criteria (/speckit.loop.run).
- Checker: independent, adversarial grader (/speckit.loop.check). MUST be a separate agent/session from the maker.

## Allowed tools / connectors
- Core Spec Kit workflow only
- `flutter` CLI (analyze, test, run)
- `grep`, `find` for verification
- `git` for worktree management

## Automation trigger
- Manual: `/speckit.loop.run` from Hermes Agent

## Guardrails
- Human sign-off required before done: true
- Comprehension debt tracked: true
- Open blocking debt blocks done: true

## State
- Phase: maker-ready
- Last updated: 2026-09-04
