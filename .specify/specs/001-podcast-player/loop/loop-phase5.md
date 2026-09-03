# Loop Phase 5: Episode Management

**Feature**: User Story 3 - Episode Management (Priority: P2)
**Goal**: Mark as played, filter unread, favorite episodes
**Branch**: `feature/phase5-episode-management`

## Done Criteria

### D1: 90%再生で自動的に既聴マーク

- [ ] `EpisodeRepository.markAsPlayed()` は90%閾値ロジックを持つ
  - 再生位置がdurationの90%以上 → `isPlayed = true`
  - 90%未満 → 位置のみ更新し、既聴にしない
- [ ] PlayerProviderが再生終了時に自動的に判定して呼び出す
- [ ] ユニットテスト: 90%以上のときにisPlayedがtrueになること
- [ ] ユニットテスト: 90%未満のときにisPlayedがfalseのままになること

### D2: お気に入りトグルの実装

- [ ] `toggleFavorite(int episodeId)` が `player_provider.dart` に Action として追加
- [ ] `EpisodeRepository.toggleFavorite()` が既に実装済み
- [ ] ユニットテスト: toggleFavoriteを呼ぶとisFavoriteが反転すること

### D3: 新着エピソード検出

- [ ] `EpisodeRepository.getNewEpisodes()` が既に実装済み (Stream として)
- [ ] PodcastDetailScreenで新着エピソードのバッジ表示に対応

### D4: EpisodeTile ウィジェット

- [ ] `lib/presentation/widgets/episode_tile.dart` が存在
- [ ] 機能:
  - 再生インジケーター (再生中はアイコン表示)
  - お気に入りトグルボタン (ハートアイコン、塗りつぶし切替)
  - 長押しメニュー (既聴/未聴切り替え)
  - 状態表示: `isNew` (未聴 + 最近), `isPlayed`, `isFavorite`

### D5: エピソード一覧フィルター

- [ ] `lib/presentation/widgets/episode_list.dart` が存在
- [ ] フィルターチップ: All, Unread, Favorites
- [ ] ソプション: 最新順/古い順

### D6: flutter analyze パス

- [ ] `flutter analyze` が exit code 0 (error, warning, info すべてゼロ)

## Files to Create/Modify

### New Files:
1. `lib/presentation/widgets/episode_tile.dart` - エピソード表示ウィジェット
2. `lib/presentation/widgets/episode_list.dart` - エピソード一覧 + フィルター
3. `test/unit/mark_as_played_test.dart` - 90%閾値ロジックのテスト
4. `test/unit/toggle_favorite_test.dart` - お気に入りトグルのテスト

### Modify Files:
1. `lib/presentation/providers/player_provider.dart` - markAsPlayed 追加
2. `lib/domain/entities/player_state.dart` - 必要に応じてフィールド追加
3. `lib/presentation/screens/podcast_detail/podcast_detail_screen.dart` - EpisodeList 統入
4. `test/unit/episode_repository_test.dart` - 既存テストの修正・追加

## Iteration Log

| Iteration | D1 | D2 | D3 | D4 | D5 | D6 | Notes |
|-----------|----|----|----|----|----|----|-------|
| 1 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | All criteria met |
