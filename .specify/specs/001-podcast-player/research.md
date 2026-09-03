# Phase 0: Research — Podcast Player App

**Date**: 2026-09-03

## 1. iTunes Search API

### Rate Limits
- **約20回/分**（IPアドレス単位）
- APIキー不要、認証不要
- 超過時はレスポンス遅延 → 429エラー

### Response Format (JSON)
```json
{
  "resultCount": 50,
  "results": [
    {
      "collectionId": 123456789,
      "collectionName": "Podcast Name",
      "artistName": "Author Name",
      "artworkUrl600": "https://...",
      "feedUrl": "https://.../rss.xml",
      "genres": ["Technology"],
      "trackCount": 150
    }
  ]
}
```

### Search Parameters
| Param | Description |
|-------|-------------|
| `term` | 検索キーワード |
| `media` | `podcast` を指定 |
| `limit` | 1-200（デフォルト50） |
| `offset` | ページネーション |

### CORS
- **サーバー側**: CORSヘッダー不要（Appleが対応済み）
- **Flutter Web**: 直接呼び出し可能

---

## 2. just_audio + Background Playback

### パッケージ構成
| パッケージ | 役割 |
|-----------|------|
| `just_audio` | 音声再生エンジン |
| `just_audio_background` | バックグラウンド再生 + 通知/ロック画面コントロール |

### Android セットアップ
```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

<service android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
  <intent-filter>
    <action android:name="android.media.browse.MediaBrowserService"/>
  </intent-filter>
</service>
```

### 初期化
```dart
await JustAudioBackground.init(
  androidNotificationChannelId: 'com.daitokihara.podcast.channel.audio',
  androidNotificationChannelName: 'Podcast Playback',
  androidNotificationOngoing: true,
);
```

### 注意点
- Android 12+ では `FOREGROUND_SERVICE_MEDIA_PLAYBACK` が必須
- フォアグラウンドサービスが正しく動作しないと、BG再生が数分で停止する
- 通知チャンネルの設定が必須

---

## 3. Isar Database

### スキーマ設計
```dart
@collection
class Podcast {
  Id id = Isar.autoIncrement;
  int? itunesId;
  String title;
  String author;
  String description;
  String artworkUrl;
  String rssUrl;
  String category;
  DateTime subscribedAt;
}

@collection
class Episode {
  Id id = Isar.autoIncrement;
  int? podcastId;
  String title;
  String description;
  String audioUrl;
  int duration; // seconds
  DateTime publishDate;
  bool isPlayed;
  int playedPosition; // seconds
  bool isFavorite;
  String? localPath; // ダウンロード時
}
```

### マイグレーション
- Isarは自動マイグレーションをサポート（後方互換性あり）
- スキーマバージョン変更時は `onSchemaVersionChanged` コールバックで対応
- 手動マイグレーションも可能（SharedPreferencesでバージョン管理）

### メリット
- 高速なローカルクエリ
- リアクティブなウォッcher対応
- 型安全
- Web対応（IndexedDB）

---

## 4. RSS Feed Parsing

### パッケージ: `rss_dart`
- RSS 2.0 / Atom 対応
- エピソード情報の抽出: `title`, `description`, `enclosure.url`, `pubDate`, `duration`

### エッジケース
- 不正なXML → エラーハンドリング必須
- 大きなフィード → ページネーション or ストリーミング
- 重複エピソード → GUID/URLで一意制約

---

## 5. Flutter Web Audio

### CORS 問題
- **問題**: ポッドキャストの音声ファイル（`audioUrl`）がCORS制約でブロックされる
- **解決策**:
  1. プロキシサーバー経由（CORSヘッダー追加）
  2. ダウンロード後にローカル再生
  3. `audio_service` のWeb対応は限定的 → フォールバック実装が必要

### Web Audio API
- `just_audio` はWeb Audio APIを使用
- ブラウザ間の互換性に差異あり（Chrome/Firefox/Safari）
- 自動再生ポリシー: ユーザー操作が必要

### 推奨アプローチ
- Web版は **ストリーミング再生** を基本とする
- CORS問題が解決しない場合は **ダウンロード後再生** にフォールバック
- プロキシ: Cloudflare Workers 等でCORSヘッダー追加

---

## 6. アーキテクチャパターン

### Riverpod + Freezed + Isar
```
Presentation Layer (Widgets)
    ↓ watch/read
State Layer (Riverpod Providers)
    ↓ call
Domain Layer (UseCases)
    ↓ use
Data Layer (Repositories + DataSources)
    ↓
Isar (Local) / iTunes API + RSS (Remote)
```

### メリット
- **テストしやすさ**: 各レイヤーを独立してモック可能
- **型安全性**: freezedでimmutableモデル
- **リアクティブ**: Riverpodで状態変更を自動反映
- **保守性**: 関心の分離が明確

---

## 7. クロスプラットフォーム同期

### 選択肢
| オプション | メリット | デメリット |
|-----------|---------|-----------|
| Firebase Firestore | リアルタイム同期、認証連携 | コスト、ベンダーロックイン |
| Supabase | オープンソース、PostgreSQL | ホスティング要 |
| 自作API | 完全制御 | 開発コスト大 |

### v1 推奨
- **ローカルファースト**: Isarでオフライン完結
- **同期はv2**: 認証・クラウド同期は後回し
- **共有機能**: エクスポート/インポートで代替

---

## 8. パフォーマンス最適化

### リスト表示
- `ListView.builder` + `AutomaticKeepAliveClientMixin`
- 画像キャッシュ: `cached_network_image`
- 仮想スクロール: 1000+エピソード対応

### メモリ管理
- オーディオリソースの確実な解放
- `dispose()` でのキャンセル処理
- Isarインスタンスのシングルトン管理

### バッテリー
- フォアグラウンドサービスの最適化
- 不要なネットワーク通信の削減
- バックグラウンドでのRSS更新はバッテリー考慮

---

## まとめ

| 技術 | 結論 |
|------|------|
| iTunes API | 20回/分制限、CORS対応済み、APIキー不要 |
| just_audio | `just_audio_background` でBG再生対応必須 |
| Isar | 高速、型安全、Web対応、自動マイグレーション |
| RSS | `rss_dart` でパース、エラーハンドリング必須 |
| Web Audio | CORS問題あり、プロキシ or ダウンロード後再生 |
| アーキテクチャ | Riverpod + Freezed + Isar の3層構成 |
| 同期 | v1はローカルファースト、v2でクラウド対応 |
