# Research: Architecture Improvements

**Date**: 2026-09-04
**Feature**: State Management, Navigation & DI Refactoring

## Research Tasks & Decisions

### RT-001: Riverpod State Management Patterns

**Decision**: Use `StateNotifier` for complex state (player, downloads), `FutureProvider` for async data fetching, `StreamProvider` for reactive streams.

**Rationale**: 
- `StateNotifier` is the recommended Riverpod pattern for mutable state with business logic
- `FutureProvider` handles one-time async operations (e.g., loading subscriptions)
- `StreamProvider` handles continuous data (e.g., position updates, downloaded episodes)

**Alternatives Considered**:
- `ChangeNotifier` — older pattern, less testable, no immutable state
- `Bloc` — overkill for this project size, adds boilerplate
- `Riverpod + freezed` — already used in project, consistent

### RT-002: go_router Navigation Patterns

**Decision**: Use `context.push()` for forward navigation, `context.go()` for tab-level navigation.

**Rationale**:
- `push` maintains back stack (needed for detail → player flow)
- `go` replaces current route (needed for tab switching)
- Existing `app_router.dart` already defines routes correctly

**Alternatives Considered**:
- `Navigator.pushNamed` — older imperative API, less type-safe
- `context.go()` everywhere — would break back navigation

### RT-003: Dependency Injection via Riverpod

**Decision**: Create explicit provider declarations for all dependencies, use `ref.onDispose` for cleanup.

**Rationale**:
- Riverpod's `Provider` is the simplest form — perfect for DI
- `ref.onDispose` ensures resources are cleaned up
- `ProviderScope(overrides: [...])` enables test mocking

**Alternatives Considered**:
- `get_it` — service locator pattern, less testable, no auto-dispose
- `InheritedWidget` — lower-level, more boilerplate
- Constructor injection only — doesn't work with Flutter widget tree

### RT-004: Testing Strategy for Refactoring

**Decision**: Use existing test suite as regression gate. Add provider override tests for DI verification.

**Rationale**:
- Existing 14 unit tests cover repositories and use cases
- Provider overrides are the standard Riverpod testing pattern
- No need to rewrite tests — just verify they still pass

**Alternatives Considered**:
- Write all new tests first — unnecessary since behavior isn't changing
- Integration tests for navigation — valuable but out of scope for this refactor

## Open Questions

None — all technical decisions are standard Riverpod/go_router patterns.
