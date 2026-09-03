# Loop Contract

## Purpose
1. Phase 3 (User Story 1: Podcast Discovery & Subscription) の全タスクを実装完了し、チェック基準をすべてパスするまで反復する。

## Done-criteria
| ID | Criterion (checkable) | How the checker verifies it | Status |
|----|-----------------------|-----------------------------|--------|
| D1 | iTunes Search APIでポッドキャスト検索が動作する | `flutter test` でAPIクライアントのユニットテストが通る | checker-pass |
| D2 | RSSフィードパーサーがエピソード一覧を取得できる | `flutter test` でパーサーのユニットテストが通る | checker-fail |
| D3 | PodcastRepositoryで購読・解除ができる | `flutter test` でリポジトリのユニットテストが通る | checker-fail |
| D4 | SearchScreenで検索結果が表示される | 検索画面をビルドして結果が表示される | checker-pass |
| D5 | PodcastDetailScreenで購読トグルができる | 詳細画面をビルドしてボタンが動作 | checker-fail |
| D6 | HomeScreenで購読一覧が表示される | ホーム画面をビルドしてリストが表示 | checker-pass |
| D7 | `flutter analyze` がエラーなし | `flutter analyze` が exit code 0 | checker-fail |
| D8 | コードカバレッジが80%以上 | `flutter test --coverage` で80%以上 | pending |

Statuses: pending → maker-ready → checker-pass | checker-fail → human-signed.

## Budget
- Max iterations: 8
- Iterations run: 1
- Isolation: none

## Roles
- Maker: produces work toward the criteria (/speckit.loop.run).
- Checker: independent, adversarial grader (/speckit.loop.check). MUST be a
  separate agent/session from the maker.

## Allowed tools / connectors
- core Spec Kit workflow only

## Automation trigger
- manual

## Guardrails
- Human sign-off required before done: true
- Comprehension debt tracked: true
- Open blocking debt blocks done: true

## State
- Phase: running
- Last updated: 2026-09-03 (4th checker pass)
- Iterations run: 1 (4th pass: D1 cast bug fixed — now 3 PASS, 4 FAIL)
