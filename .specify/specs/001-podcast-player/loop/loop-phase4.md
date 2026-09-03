# Loop Contract — Phase 4: Audio Playback

## Purpose
Phase 4 (User Story 2: Audio Playback) の全タスクを実装完了し、チェック基準をすべてパスするまで反復する。

## Done-criteria
| ID | Criterion (checkable) | How the checker verifies it | Status |
|----|-----------------------|-----------------------------|--------|
| D1 | AudioServiceで再生・一時停止・停止ができる | `flutter test` でAudioServiceのユニットテストが通る | pending |
| D2 | PlayerScreenに再生コントロールが表示される | プレーヤー画面に再生/一時停止/シークが表示される | pending |
| D3 | EpisodeRepositoryでエピソード管理ができる | `flutter test` でリポジトリのユニットテストが通る | pending |
| D4 | PlayEpisodeユースケースが動作する | `flutter test` でユースケースのテストが通る | pending |
| D5 | MiniPlayerが表示され再生状態が反映される | ミニプレーヤーが表示され状態が同期される | pending |
| D6 | PlayerProviderで状態管理ができる | Riverpodプロバイダーが正しく動作する | pending |
| D7 | `flutter analyze` がエラーなし | `flutter analyze` が exit code 0 | pending |
| D8 | バックグラウンド再生が動作する | AndroidManifest.xmlにフォアグラウンドサービス設定がある | pending |

Statuses: pending → maker-ready → checker-pass | checker-fail → human-signed.

## Budget
- Max iterations: 8
- Iterations run: 0
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
- Last updated: 2026-09-03 (maker session start)
- Iterations run: 0
