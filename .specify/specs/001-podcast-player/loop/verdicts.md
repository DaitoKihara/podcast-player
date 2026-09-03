# Checker Verdicts

Adversarial verification of D1-D7 against primary sources.
Checker: independent session (adversarial grader) — THIRD PASS
Date: 2026-09-03

---

## D1 — iTunes Search API client

**Criterion (loop.md):** `flutter test` でAPIクライアントのユニットテストが通る
**Task instruction:** Check that itunes_api_client.dart exists and has correct structure (search method, error handling)

### Primary source verified
- File: `lib/data/datasources/remote/itunes_api_client.dart` — EXISTS
- Class `ITunesApiClient` — PRESENT
- Method `searchPodcasts({required String term, int limit, int offset})` — PRESENT
- Error handling: `DioException` catch + generic catch — PRESENT
- Uses `createITunesDio()` from `core/network/dio_client.dart` — PRESENT
- `PodcastSearchResult.fromJson` factory — PRESENT
- Test file: `test/unit/itunes_api_client_test.dart` — EXISTS

### Adversarial findings
1. **Test compilation: FIXED.** The test now uses `collectionName` and `artistName` correctly. No more `undefined_getter` errors.
2. **Test runtime failure.** Both tests fail at runtime with: `type 'String' is not a subtype of type 'Map<String, dynamic>' in type cast` at `itunes_api_client.dart:43` (catch block). The actual error occurs at line 29: `final data = response.data as Map<String, dynamic>`. Dio returns `response.data` as a `String` (JSON string that needs parsing), not a parsed `Map`. This is a **source code bug** — the cast fails because Dio's default behavior with certain response types returns a String.
3. **Tests require network access.** The tests call the live iTunes API, making them integration tests. They will fail in CI/offline environments regardless of the cast bug.
4. **`flutter test` result: FAILED.** Exit code 1. Both D1 tests fail.

### Verdict: **FAIL**
**Confidence:** Certain
**Reason:** Tests compile now but fail at runtime. The root cause is a bug in `itunes_api_client.dart:29` — `response.data` is cast to `Map<String, dynamic>` but Dio returns a `String`. The test correctly exposes this bug. Additionally, these are integration tests requiring live network access.

---

## D2 — RSS feed parser

**Criterion (loop.md):** `flutter test` でパーサーのユニットテストが通る
**Task instruction:** Check that rss_feed_parser.dart exists and parses RSS correctly

### Primary source verified
- File: `lib/data/datasources/remote/rss_feed_parser.dart` — EXISTS
- Class `RssFeedParser` — PRESENT
- Method `parseFeed(String rssUrl)` — PRESENT
- Uses `rss_dart` (`RssFeed.parse`) — PRESENT
- Returns `RssFeedResult` with `PodcastInfo` and `List<EpisodeInfo>` — PRESENT
- RFC 822 date parsing fix: Uses `DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US')` — PRESENT
- Test file: `test/unit/rss_feed_parser_test.dart` — EXISTS

### Adversarial findings
1. **Exception type test: FIXED.** The test now uses `throwsA(isA<AppException>())` and imports `app_exception.dart`. The "handles invalid URL gracefully" test PASSES.
2. **First test requires network access.** The test calls a live RSS feed URL (`https://feeds.simplecast.com/54nAGcIl`), making it an integration test. It fails at runtime because the network call returns unexpected data or fails.
3. **`flutter test` result: FAILED.** The first test fails (network/integration issue). The second test passes.

### Verdict: **FAIL**
**Confidence:** High
**Reason:** The exception type test now passes (fix confirmed). However, the first test still fails because it calls a live RSS feed — an integration test that requires network access. The criterion requires `flutter test` to pass, which it doesn't.

---

## D3 — PodcastRepository subscribe/unsubscribe

**Criterion (loop.md):** `flutter test` でリポジトリのユニットテストが通る
**Task instruction:** Check that podcast_repository.dart exists with subscribe/unsubscribe methods

### Primary source verified
- File: `lib/data/repositories/podcast_repository.dart` — EXISTS
- Class `PodcastRepository` — PRESENT
- Method `subscribe(Podcast podcast)` — PRESENT (inserts into `podcasts` and `subscriptions`)
- Method `unsubscribe(int podcastId)` — PRESENT (deletes from `subscriptions` and `podcasts`)
- Getter `subscribedPodcasts` — PRESENT
- Test file: `test/unit/podcast_repository_test.dart` — EXISTS

### Adversarial findings
1. **Test compilation: FIXED.** The test now imports `app_database.dart` which provides access to the `Podcast` class. No more `undefined_function: 'Podcast'` errors.
2. **Runtime failure: `Binding has not yet been initialized`.** All three tests fail because `PodcastRepository()` defaults to `AppDatabase.instance`, which calls `driftDatabase()` from `drift_flutter`. This requires platform channels (`path_provider`) that need `WidgetsFlutterBinding.ensureInitialized()`. The test doesn't initialize the binding, so every database operation fails.
3. **Tests are integration tests.** Even with binding initialization, these tests would require a real Drift database, making them integration tests rather than unit tests.
4. **`flutter test` result: FAILED.** Exit code 1. All three D3 tests fail.

### Verdict: **FAIL**
**Confidence:** Certain
**Reason:** Tests compile now but fail at runtime with `Binding has not yet been initialized`. The `AppDatabase.instance` singleton requires platform channels that aren't available in unit tests. The tests need either `TestWidgetsFlutterBinding.ensureInitialized()` or mocked dependencies.

---

## D4 — SearchScreen search UI

**Criterion (loop.md):** 検索画面をビルドして結果が表示される
**Task instruction:** Check that search_screen.dart exists with search UI

### Primary source verified
- File: `lib/presentation/screens/search/search_screen.dart` — EXISTS
- Class `SearchScreen` (StatefulWidget) — PRESENT
- TextField with search controller — PRESENT
- Search button — PRESENT
- ListView.builder for results — PRESENT
- Loading indicator — PRESENT
- Error handling (SnackBar) — PRESENT

### Adversarial findings
1. `onTap` in the result list is empty (no navigation to detail). This is a missing feature but not part of D4's criterion.
2. Minor lints: `avoid_redundant_argument_values`, `unnecessary_underscores`.

### Verdict: **PASS**
**Confidence:** High
**Reason:** Search UI is fully implemented with all required elements. Unchanged from previous passes.

---

## D5 — PodcastDetailScreen subscribe toggle

**Criterion (loop.md):** 詳細画面をビルドしてボタンが動作
**Task instruction:** Check that podcast_detail_screen.dart exists with subscribe toggle

### Primary source verified
- File: `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart` — EXISTS
- Class `PodcastDetailScreen` (StatefulWidget) — PRESENT
- Subscribe/Unsubscribe button — PRESENT (text toggles based on `_isSubscribed`)
- `_repository` field — PRESENT (now used)
- `_checkSubscription()` — CALLS `_repository.getSubscription()` (works)
- `_toggleSubscription()` unsubscribe path — CALLS `_repository.unsubscribe()` (works)

### Adversarial findings
1. **Subscribe path is still a stub.** Line 51: `throw UnimplementedError('Podcast subscription requires fetching podcast data first');`. The subscribe action throws an exception instead of performing the subscription. Only unsubscribe works.
2. **Partial fix acknowledged.** The maker did improve the code — `_checkSubscription()` and unsubscribe now work. But the subscribe path is still broken, so the toggle is not fully functional.
3. The screen still shows only "Podcast ID: X" with no podcast metadata.

### Verdict: **FAIL**
**Confidence:** High
**Reason:** The subscribe action throws `UnimplementedError`. The toggle button does not fully work — only unsubscribe is functional. The criterion requires the button to work for both subscribe and unsubscribe.

---

## D6 — HomeScreen subscription list

**Criterion (loop.md):** ホーム画面をビルドしてリストが表示
**Task instruction:** Check that home_screen.dart exists with subscription list

### Primary source verified
- File: `lib/presentation/screens/home/home_screen.dart` — EXISTS
- Class `HomeScreen` (StatefulWidget) — PRESENT
- Loads subscriptions via `_repository.subscribedPodcasts.first` — PRESENT
- ListView.builder for subscribed podcasts — PRESENT
- Loading indicator — PRESENT
- Empty state message — PRESENT

### Adversarial findings
1. `onTap` in the subscription list is empty (no navigation to detail). Missing feature but not part of D6.
2. Minor lints: `avoid_catches_without_on_clauses`, `unnecessary_underscores`.

### Verdict: **PASS**
**Confidence:** High
**Reason:** Subscription list UI is fully implemented. Unchanged from previous passes.

---

## D7 — flutter analyze exit code 0

**Criterion (loop.md):** `flutter analyze` が exit code 0
**Task instruction:** Run `flutter analyze` in the project root and check exit code

### Primary source verified
- Command run: `cd /home/daito/podcast-player && flutter analyze`
- Exit code: **1** (not 0)
- Issues found: **21** (all info-level, no errors)
  - `prefer_int_literals` (2)
  - `sort_constructors_first` (1)
  - `only_throw_errors` (2)
  - `directives_ordering` (2)
  - `always_put_control_body_on_new_line` (2)
  - `avoid_catches_without_on_clauses` (2)
  - `unnecessary_underscores` (4)
  - `prefer_if_elements_to_conditional_expressions` (1)
  - `avoid_redundant_argument_values` (3)
  - `sort directive sections` (2)

### Adversarial findings
1. The criterion explicitly requires exit code 0. The actual exit code is 1.
2. All 21 issues are info-level lints (no errors or warnings). `flutter analyze` returns exit code 1 when ANY issues (info, warning, or error) are present.
3. The test compilation errors from previous passes are FIXED — no more errors in test files.

### Verdict: **FAIL**
**Confidence:** Certain
**Reason:** `flutter analyze` returned exit code 1 with 21 info-level lints. The criterion requires exit code 0. While the test file compilation errors are fixed, the pre-existing code style lints still cause a non-zero exit code.

---

## Summary

| Criterion | Verdict | Confidence | Key Issue |
|-----------|---------|------------|-----------|
| D1 | FAIL | Certain | Tests compile but fail at runtime — `response.data` cast bug in source + network dependency |
| D2 | FAIL | High | Exception test passes (fix confirmed), but first test fails — requires live network |
| D3 | FAIL | Certain | Tests compile but fail at runtime — `Binding not initialized` (needs platform channels) |
| D4 | PASS | High | Search UI complete (unchanged) |
| D5 | FAIL | High | Subscribe path throws `UnimplementedError` — only unsubscribe works |
| D6 | PASS | High | Subscription list UI complete (unchanged) |
| D7 | FAIL | Certain | `flutter analyze` exit code is 1 (21 info-level lints, no errors) |

**Overall: 2 PASS, 5 FAIL**

### Maker progress since 2nd pass
- D1: Compilation fixed (getter names corrected). Tests now compile but fail at runtime due to source bug + network ❌
- D2: Exception type test fixed (now uses `AppException`). Second test passes. First test still requires network ❌
- D3: Compilation fixed (import added). Tests now compile but fail at runtime due to missing binding initialization ❌
- D7: Test compilation errors fixed. No more errors, but 21 info lints remain ❌

### Key blocker pattern
The compilation errors are fixed, but the tests are fundamentally integration tests that require:
1. Network access (D1, D2 first test)
2. Platform channels / real database (D3)

The tests were written as if they were unit tests but actually exercise live external dependencies. To make them true unit tests, the code needs dependency injection with mocked HTTP client (D1, D2) and mocked database (D3).

Additionally, D1 exposes a real bug: `itunes_api_client.dart:29` casts `response.data` to `Map<String, dynamic>` but Dio returns a `String` when the response isn't auto-parsed as JSON.
