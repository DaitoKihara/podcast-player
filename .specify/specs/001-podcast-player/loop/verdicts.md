# Checker Verdicts

Adversarial verification of D1-D7 against primary sources.
Checker: independent session (adversarial grader) — SIXTH PASS
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

### Fourth pass findings
1. **Cast bug FIXED.** The `response.data` cast is now handled correctly with a type check:
   ```dart
   final data = response.data is String
       ? jsonDecode(response.data as String) as Map<String, dynamic>
       : response.data as Map<String, dynamic>;
   ```
   This properly handles both cases — when Dio returns a parsed Map and when it returns a raw JSON string.
2. **Both tests PASS.** `flutter test test/unit/itunes_api_client_test.dart` exits with code 0. Both `searchPodcasts` and `getPodcastById` tests pass.
3. **Tests still require network access.** These remain integration tests that call the live iTunes API. They work now but will fail in offline/CI environments without network.

### Verdict: **PASS** ✅
**Confidence:** High
**Reason:** The `response.data` cast bug is fixed with proper type checking. Both tests pass with exit code 0. The criterion requires `flutter test` to pass, which it now does.

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

### Sixth pass findings
1. **Test FAILS with type mismatch.** Test expects `throwsA(isA<Exception>())` but actual thrown type is `FeedParseException` (an `AppException` sealed class). `AppException` does NOT implement `Exception` (it's a freezed sealed class extending `Object`), so `isA<Exception>()` returns false.
2. **Parser has a cast bug.** The actual error triggering the failure is: `type '_Map<String, dynamic>' is not a subtype of type 'String' in type cast` at `rss_feed_parser.dart:18`. The line `RssFeed.parse(response.data as String)` assumes response.data is always a String, but Dio returns a `Map<String, dynamic>` for error responses (e.g., from invalid URLs). This is a genuine parser bug — the cast should be conditional like in `itunes_api_client.dart`.
3. **`flutter test` exit code: 1.** Test fails, so overall test suite fails.
4. **Test is now a proper unit test (no network).** The test uses an invalid URL, so it doesn't require network access — this is an improvement. But the test itself has the wrong exception type matcher.

### Verdict: **FAIL**
**Confidence:** High
**Reason:** Test fails for two reasons: (1) `AppException` doesn't implement `Exception`, so `isA<Exception>()` matcher fails; (2) parser has a cast bug where `response.data as String` throws for non-String responses. Both issues need fixing for `flutter test` to pass.

---

## D3 — PodcastRepository subscribe/unsubscribe

**Criterion (loop.md):** `flutter test` でリポジトリのユニットテストが通る
**Task instruction:** Check that podcast_repository.dart exists with subscribe/unsubscribe methods

### Primary source verified
- File: `lib/data/repositories/podcast_repository.dart` — EXISTS
- Class `PodcastRepository` — PRESENT
- Method `subscribe(Podcast podcast)` — PRESENT
- Method `unsubscribe(int podcastId)` — PRESENT
- Getter `subscribedPodcasts` — PRESENT
- Test file: `test/unit/podcast_repository_test.dart` — EXISTS

### Sixth pass findings
1. **Three compilation errors in test file:**
   - **`undefined_function: InMemoryDatabase`** (line 13): `AppDatabase.forTest(InMemoryDatabase())` — `InMemoryDatabase` from `package:drift/native.dart` is not usable as a constructor in this context. The test passes `InMemoryDatabase()` but `AppDatabase.forTest` expects a `QueryExecutor`. The correct approach is to use `VmDatabase.inMemory()` or similar Drift test utility.
   - **`ambiguous_import: isNotNull`** (line 47): `isNotNull` is imported from both `package:drift/.../query_builder.dart` (SQL operator) and `package:matcher/src/core_matchers.dart` (test matcher). Conflict.
   - **`ambiguous_import: isNull`** (line 71): Same conflict for `isNull`.
2. **Test file does not compile.** `flutter test` cannot load the test file.
3. **`flutter test` exit code: 1.**

### Verdict: **FAIL**
**Confidence:** Certain
**Reason:** Test file has 3 compilation errors: wrong `InMemoryDatabase` usage, and ambiguous imports for `isNotNull`/`isNull`. The test cannot even be loaded by `flutter test`.

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
1. `onTap` in the result list is empty (no navigation to detail). Missing feature but not part of D4.
2. Minor lints only.

### Verdict: **PASS**
**Confidence:** High
**Reason:** Search UI is fully implemented.

---

## D5 — PodcastDetailScreen subscribe toggle

**Criterion (loop.md):** 詳細画面をビルドしてボタンが動作
**Task instruction:** Check that podcast_detail_screen.dart exists with subscribe toggle

### Primary source verified
- File: `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart` — EXISTS
- Class `PodcastDetailScreen` (StatefulWidget) — PRESENT
- Subscribe/Unsubscribe button — PRESENT
- `_repository` field — PRESENT

### Fifth pass findings
1. **Subscribe path FIXED.** `_toggleSubscription` now calls `_repository.subscribeById(widget.podcastId)` (line 48) instead of throwing `UnimplementedError`.
2. **`subscribeById` method exists in repository.** `podcast_repository.dart` lines 62-67: queries the podcast by ID via `db.select(db.podcasts)..where((t) => t.id.equals(podcastId))`, then delegates to `subscribe(podcast)` which inserts into both `podcasts` and `subscriptions` tables.
3. **Unsubscribe path unchanged.** Still calls `_repository.unsubscribe(widget.podcastId)` (line 46).
4. **Error handling present.** `on Exception catch (e)` shows SnackBar with error message.

### Verdict: **PASS** ✅
**Confidence:** High
**Reason:** Subscribe action now calls `subscribeById` which is fully implemented in the repository. Toggle is fully functional — both subscribe and unsubscribe paths work.

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
1. `onTap` is empty. Missing feature but not part of D6.

### Verdict: **PASS**
**Confidence:** High
**Reason:** Subscription list UI is fully implemented.

---

## D7 — flutter analyze exit code 0

**Criterion (loop.md):** `flutter analyze` が exit code 0
**Task instruction:** Run `flutter analyze` in the project root and check exit code

### Primary source verified
- Command run: `cd /home/daito/podcast-player && flutter analyze`
- Exit code: **1** (not 0)
- Issues found: **17** (3 errors, 14 info-level)

### Sixth pass breakdown
**Errors (3):**
- `test/unit/podcast_repository_test.dart:13:36` — `undefined_function: InMemoryDatabase`
- `test/unit/podcast_repository_test.dart:47:19` — `ambiguous_import: isNotNull`
- `test/unit/podcast_repository_test.dart:71:19` — `ambiguous_import: isNull`

**Info-level lints (14):**
- `sort_constructors_first` (2) — `app_database.dart:111`, `itunes_api_client.dart:110`
- `directives_ordering` (1) — `podcast_repository.dart:5`
- `always_put_control_body_on_new_line` (2) — `podcast_repository.dart:45`, `home_screen.dart:35`
- `unused_catch_clause` (1, warning) — `home_screen.dart:35`
- `unnecessary_underscores` (4) — `home_screen.dart:65`, `search_screen.dart:107`
- `avoid_redundant_argument_values` (3) — `search_screen.dart:32,33`, `itunes_api_client_test.dart:16`, `podcast_repository_test.dart:23`

### Adversarial findings
1. The criterion requires exit code 0. Actual is 1.
2. 3 errors are from D3 test file compilation (inherited from D3 issues).
3. 14 info-level lints remain from production code.
4. **D2 test file has no analyze errors** (it compiles, just fails at runtime).

### Verdict: **FAIL**
**Confidence:** Certain
**Reason:** `flutter analyze` returned exit code 1 with 3 errors and 14 info-level lints. Criterion requires exit code 0.

---

## Summary

| Criterion | Verdict | Confidence | Key Issue |
|-----------|---------|------------|-----------|
| D1 | **PASS** | High | Cast bug fixed; tests pass with exit code 0 |
| D2 | FAIL | High | Test fails: `AppException` is not `Exception`; parser has cast bug |
| D3 | FAIL | Certain | 3 compilation errors: `InMemoryDatabase`, ambiguous `isNotNull`/`isNull` |
| D4 | PASS | High | Search UI complete (unchanged) |
| D5 | **PASS** | High | Subscribe toggle fully functional via `subscribeById` |
| D6 | PASS | High | Subscription list UI complete (unchanged) |
| D7 | FAIL | Certain | `flutter analyze` exit code is 1 (3 errors, 14 info lints) |

**Overall: 4 PASS, 3 FAIL**

### Sixth pass changes
- **D2: No change.** Test now uses invalid URL (no network needed) — improvement. But `isA<Exception>()` matcher is wrong for `AppException`, and parser has a cast bug on `response.data as String`. Still FAIL.
- **D3: New compilation errors.** The rewritten test file has 3 compilation errors: wrong `InMemoryDatabase` usage and ambiguous imports. Still FAIL.
- **D7: Worse.** Now 3 errors (up from 0) due to D3 test compilation failures, plus 14 info lints (down from 21). Still FAIL.

### Key observations
1. **D2 parser bug:** `rss_feed_parser.dart:18` does `RssFeed.parse(response.data as String)` which crashes when Dio returns a non-String response (e.g., error page as Map). The `itunes_api_client.dart` handles this correctly with a conditional cast — the same fix should be applied to the parser.
2. **D3 import conflict:** The `isNotNull`/`isNull` matchers from `flutter_test` conflict with Drift's SQL operators. Fix: use `isA<T>().having(...)` or import `package:matcher/matcher.dart` with a prefix.
3. **D3 InMemoryDatabase:** `package:drift/native.dart`'s `InMemoryDatabase` is not available in unit test context. Use `VmDatabase.inMemory()` from `package:drift/vm.dart` or `driftDatabase(inMemory: true)` instead.
