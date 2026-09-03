# Loop Phase 7: Sleep Timer & Bookmarks

**Feature**: User Story 5 - Sleep Timer & Bookmarks (Priority: P3)
**Goal**: Auto-stop playback after timer, bookmark specific timestamps
**Branch**: `feature/phase7-sleep-timer`

## Done Criteria

### D1: SleepTimerServiceが動作する

- [ ] `lib/services/sleep_timer_service.dart` が存在
- [ ] 機能: `setTimer(Duration)`, `cancelTimer()`, `getRemainingTime()`
- [ ] タイマー期限切れ時にAudioServiceをpauseする
- [ ] ユニットテスト: タイマー設定後に残り時間が正しく取得できること
- [ ] ユニットテスト: タイマーがキャンセルできること

### D2: BookmarkRepositoryでブックマーク管理ができる

- [ ] `lib/data/repositories/bookmark_repository.dart` が存在
- [ ] 機能: `addBookmark()`, `deleteBookmark()`, `getBookmarksForEpisode()`, `getBookmark()`
- [ ] ユニットテスト: ブックマークの追加・削除・取得ができること

### D3: PlayerScreenにスリープタイマーUIが表示される

- [ ] PlayerScreenにタイマー選択UI（5/10/15/30/60分、エピソード終了時）
- [ ] タイマー残り時間の表示
- [ ] キャンセルボタン

### D4: PlayerScreenにブックマーク機能が追加される

- [ ] ブックマーク追加ボタン
- [ ] ブックマークリスト表示
- [ ] ブックマーク位置へのジャンプ

### D5: 既存機能との統合

- [ ] SleepTimerServiceがAudioServiceと連携して自動停止
- [ ] ブックマーク追加時にEpisodeRepositoryの位置情報と連動
- [ ] PlayerProviderでタイマー状態を管理

### D6: flutter analyze パス

- [ ] `flutter analyze` が exit code 0 (error, warning, info すべてゼロ)

### D7: 全テストパス

- [ ] `flutter test` が exit code 0
- [ ] 新コードのテストが存在すること

## Files to Create/Modify

### New Files:
1. `lib/services/sleep_timer_service.dart` — スリープタイマーサービス
2. `lib/data/repositories/bookmark_repository.dart` — ブックマークリポジトリ
3. `test/unit/sleep_timer_service_test.dart` — タイマーサービスのテスト
4. `test/unit/bookmark_repository_test.dart` — ブックマークリポジトリのテスト

### Modify Files:
1. `lib/presentation/screens/player/player_screen.dart` — タイマーUI・ブックマークUI追加
2. `lib/presentation/providers/player_provider.dart` — タイマー状態管理追加
3. `lib/services/audio_service.dart` — タイマーによる自動停止連携

## Iteration Log

| Iteration | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Notes |
|-----------|----|----|----|----|----|----|----|-------|
| 1 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | All criteria met |
