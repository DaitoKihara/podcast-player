# Feature Specification: Podcast Player App

**Feature Branch**: `feature/001-podcast-player`

**Created**: 2026-09-03

**Status**: Draft

**Input**: User description: "ポッドキャストのAndroidアプリを作りたいと思います。WEBでも動作すれば理想"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Podcast Discovery & Subscription (Priority: P1)

ユーザーがポッドキャストを検索・発見し、購読できる。アプリを開いた際、iTunes Search APIから人気のポッドキャストやキーワード検索で新しい番組を見つけ、ワンタップで購読できる。

**Why this priority**: ポッドキャストプレーヤーの根幹。ユーザーが最初に行う行動であり、これがなければ他の機能は存在意義がない。

**Independent Test**: iTunes Search APIを通じてポッドキャスト一覧を取得し、検索結果から選択して購読リストに追加できることを確認。

**Acceptance Scenarios**:

1. **Given** ユーザーがアプリを開いたとき、**When** 検索画面でキーワードを入力すると、**Then** iTunes Search APIから一致するポッドキャストが一覧表示される
2. **Given** 検索結果が表示されているとき、**When** ポードキャストを選択すると、**Then** ポッドキャスト詳細画面が表示され、エピソード一覧が確認できる
3. **Given** ポッドキャスト詳細画面が表示されているとき、**When** 「購読」ボタンをタップすると、**Then** ポッドキャストが購読リストに追加され、ホーム画面の「購読中」に表示される
4. **Given** 購読中のポッドキャストがあるとき、**When** ホーム画面を開くと、**Then** 購読中のポッドキャスト一覧が更新日時順に表示される
5. **Given** ポッドキャスト一覧画面が表示されているとき、**When** カテゴリフィルター（例: テクノロジー、ビジネス等）を適用すると、**Then** 該当カテゴリのポッドキャストのみが表示される

---

### User Story 2 - Audio Playback (Priority: P1)

エピソードを再生し、基本的な再生制御ができる。再生、一時停止、スキップ、シークが直感的に操作できる。バックグラウンド再生と通知バー/ロック画面でのコントロールに対応する。

**Why this priority**: 再生機能はプレーヤーの中核機能。これがなければアプリとして成立しない。

**Independent Test**: 任意のエピソードを選択して再生し、一時停止、早送り、巻き戻しができることを確認。バックグラウンド移行後も再生が継続し、通知バーからコントロール可能。

**Acceptance Scenarios**:

1. **Given** エピソード一覧画面が表示されているとき、**When** エピソードをタップすると、**Then** 再生が開始され、ミニプレーヤーが画面下部に表示される
2. **Given** ミニプレーヤーが表示されているとき、**When** ミニプレーヤーをタップすると、**Then** フルスクリーンのプレーヤー画面が表示される
3. **Given** 再生中のエピソードがあるとき、**When** 「一時停止」ボタンをタップすると、**Then** 再生が一時停止し、ボタンが「再生」に切り替わる
4. **Given** プレーヤー画面が表示されているとき、**When** シークバーをドラッグすると、**Then** 指定位置から再生が再開する
5. **Given** 再生中、**When** アプリをバックグラウンドに移行すると、**Then** 再生が継続し、通知バーにメディアコントロールが表示される
6. **Given** ロック画面の状態で再生中、**When** ロック画面を表示すると、**Then** アルアートと再生コントロールが表示される
7. **Given** 再生中、**When** スキップフォワード（30秒）ボタンをタップすると、**Then** 30秒先にスキップされる
8. **Given** 再生中、**When** 再生速度ボタンをタップすると、**Then** 速度選択（0.5x〜3.0x）が表示され、選択後に速度が変更される

---

### User Story 3 - Episode Management (Priority: P2)

エピソードの再生状況を管理し、新しいエピソードの通知を受け取る。未聴/既聴の管理やお気に入り機能で、効率的にエピソードを整理できる。

**Why this priority**: 日常的にポッドキャストを聴くユーザーにとって、エピソード管理は必須。購読後の継続利用に直結する。

**Independent Test**: エピソードを既聴にマークし、フィルタリングで未聴のみ表示できることを確認。新しいエピソードが公開された際に通知が届く。

**Acceptance Scenarios**:

1. **Given** エピソード一覧画面が表示されているとき、**When** エピソードを長押しして「既聴」を選択すると、**Then** そのエピソードが既聴としてマークされ、表示がグレーアウトする
2. **Given** フィルターが「すべて」になっているとき、**When** 「未聴のみ」に変更すると、**Then** 未聴のエピソードのみが一覧表示される
3. **Given** エピソードがあるとき、**When** 「お気に入り」ボタンをタップすると、**Then** お気に入りに追加され、ハートアイコンが塗りつぶされる
4. **Given** 購読中のポッドキャストに新しいエピソードが公開されたとき、**When** アプリを開くと、**Then** 新着エピソードに「NEW」バッジが表示される
5. **Given** エピソードが90%以上再生されたとき、**When** 再生を終了すると、**Then** 自動的に既聴にマークされる

---

### User Story 4 - Offline Download (Priority: P2)

エピソードをダウンロードして、オフラインでも聴ける。モバイルデータ使用量を気にするユーザーは、Wi-Fi接続時のみダウンロードする設定ができる。

**Why this priority**: 通勤中や圏外での利用シーンで重要。差別化機能となる。

**Independent Test**: Wi-Fi接続時にエピソードをダウンロードし、機内モード/オフライン状態でも再生可能であることを確認。

**Acceptance Scenarios**:

1. **Given** エピソード詳細画面が表示されているとき、**When** 「ダウンロード」ボタンをタップすると、**Then** ダウンロードが開始し、プログレスバーが表示される
2. **Given** ダウンロード中のとき、**When** ダウンロードが完了すると、**Then** ボタンが「ダウンロード済み」に変わり、ローカル保存完了のトーストが表示される
3. **Given** オフライン状態でアプリを開いたとき、**When** 「ダウンロード済み」タブを表示すると、**Then** ダウンロード済みエピソードが一覧表示される
4. **Given** 設定で「Wi-Fiのみダウンロード」が有効で、**When** モバイルデータ接続中にダウンロードを試みると、**Then** Wi-Fi接続待ちのダイアログが表示される
5. **Given** ストレージ容量が不足しているとき、**When** ダウンロードを試みると、**Then** 容量不足のエラーメッセージが表示される

---

### User Story 5 - Sleep Timer & Bookmarks (Priority: P3)

就寝時にタイマーで自動停止したり、特定のタイムスタンプをブックマークしたりできる。

**Why this priority**: 利便性向上機能。既存のプレーヤーとの差別化になる。

**Independent Test**: スリープタイマーを設定し、指定時間後に再生が停止することを確認。ブックマークを追加し、後からその位置にジャンプできる。

**Acceptance Scenarios**:

1. **Given** プレーヤー画面が表示されているとき、**When** 「スリープタイマー」アイコンをタップして時間を選択すると、**Then** 指定時間後に再生が自動停止する
2. **Given** スリープタイマーが動作中のとき、**When** タイマーをキャンセルすると、**Then** 再生がそのまま継続される
3. **Given** プレーヤー画面で再生中、**When** 「ブックマーク」ボタンをタップすると、**Then** 現在の再生位置にブックマークが追加される
4. **Given** ブックマークがあるエピソードを再生中、**When** ブックマークリストから選択すると、**Then** その位置にシークされて再生が開始される

---

### User Story 6 - Cross-Platform Sync (Priority: P3)

AndroidアプリとWebブラウザで再生位置や購読リストを同期できる。

**Why this priority**: ユーザビリティを高める付加機能。スマホとPCシームレスに使える体験を提供する。

**Independent Test**: Androidで再生した位置情報がWebアプリに反映され、同じ位置から再生開始できることを確認。

**Acceptance Scenarios**:

1. **Given** ユーザーがログインしているとき、**When** ポッドキャストを購読すると、**Then** 他のデバイスにも購読が同期される
2. **Given** Androidでエピソードを途中まで再生したとき、**When** Webブラウザで同じエピソードを開くと、**Then** 前回の再生位置から再生が再開される
3. **Given** Webブラウザで購読を解除したとき、**When** Androidアプリを開くと、**Then** 購読が解除されている

---

### Edge Cases

- **What happens when** ネットワーク接続が切断された場合、Now Playing画面ではオフライン再生を継続し、ブラウザ画面ではエラーメッセージを表示する
- **What happens when** RSSフィードが無効/削除された場合、次回更新時に検知してユーザーに通知する
- **What happens when** 音声ファイルのダウンロードに失敗した場合、リトライボタンを表示し、自動リトライ（最大3回）する
- **What happens when** エピソードの再生位置情報が破損した場合、先頭から再生を開始する
- **What happens when** バックグラウンド再生中にメモリ不足でアプリが強制終了された場合、最後の再生位置を復元する
- **How does system handle** 重複する購読（同じポッドキャストを再度追加）→ 既存の購読を維持し、重複を防ぐ

## Requirements *(mandatory)*

### Functional Requirements

#### Discovery & Subscription
- **FR-001**: System MUST iTunes Search APIを通じてポッドキャスト検索を提供する
- **FR-002**: System MUST カテゴリ別ポッドキャスト一覧を表示する
- **FR-003**: System MUST ポッドキャストのRSSフィードを取得・解析してエピソード一覧を表示する
- **FR-004**: System MUST ポッドキャストの購読/解除機能を提供する
- **FR-005**: System MUST 購読中のポッドキャスト一覧を更新日時順に表示する

#### Playback
- **FR-006**: System MUST 音声の再生/一時停止/停止機能を提供する
- **FR-007**: System MUST シークバーによる再生位置の変更を提供する
- **FR-008**: System MUST スキップフォワード（デフォルト30秒）/巻き戻し（デフォルト10秒）機能を提供する
- **FR-009**: System MUST 再生速度変更（0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 2.0x, 3.0x）機能を提供する
- **FR-010**: System MUST バックグラウンド再生をサポートする
- **FR-011**: System MUST 通知バーおよびロック画面にメディアコントロールを表示する

#### Episode Management
- **FR-012**: System MUST エピソードの既聴/未聴ステータスを管理する
- **FR-013**: System MUST 未聴フィルターによる一覧表示を提供する
- **FR-014**: System MUST お気に入りエピソード機能を提供する
- **FR-015**: System MUST 新着エピソードにバッジを表示する
- **FR-016**: System MUST 再生完了（90%以上）時に自動的に既聴としてマークする

#### Download & Offline
- **FR-017**: System MUST エピソードのダウンロード機能を提供する
- **FR-018**: System MUST ダウンロード済みエピソードのオフライン再生を可能にする
- **FR-019**: System MUST Wi-Fiのみダウンロード設定を提供する
- **FR-020**: System MUST ダウンロード状況（進捗/完了/失敗）を表示する
- **FR-021**: System MUST ダウンロード容量制限設定を提供する

#### Sleep Timer & Bookmarks
- **FR-22**: System MUST スリープタイマー（5/10/15/30/60分/エピソード終了時）機能を提供する
- **FR-23**: System MUST 再生位置へのブックマーク追加/削除を提供する
- **FR-24**: System MUST ブックマークからの再生再開を提供する

#### Cross-Platform
- **FR-25**: System MUST ユーザーアカウント作成/ログイン機能を提供する [NEEDS CLARIFICATION: 認証方法 - Email/Google/匿名ログイン？]
- **FR-26**: System MUST 購読リストのクラウド同期を提供する
- **FR-27**: System MUST 再生位置のクラウド同期を提供する
- **FR-28**: System MUST Webブラウザ（Flutter Web）として動作する

#### Settings
- **FR-29**: System MUST 再生スキップ間隔のカスタマイズ設定を提供する
- **FR-30**: System MUST 自動ダウンロード設定を提供する
- **FR-31**: System MUST ダークモード/ライトモード対応を提供する
- **FR-32**: System MUST フォントサイズ調整を提供する

### Key Entities

- **Podcast**: ポッドキャスト番組。id, title, author, description, artworkUrl, rssUrl, category, episodeCount
- **Episode**: エピソード。id, podcastId, title, description, audioUrl, duration, publishDate, isPlayed, playedPosition, isFavorite, localPath (ダウンロード時)
- **Subscription**: 購読情報。podcastId, subscribedAt, autoDownload, notificationsEnabled
- **Bookmark**: ブックマーク。episodeId, position, createdAt, note
- **UserPreference**: ユーザー設定。skipForwardInterval, skipBackwardInterval, defaultPlaybackSpeed, downloadOnlyOnWifi, autoDownload, darkMode, syncEnabled
- **DownloadRecord**: ダウンロード記録。episodeId, localPath, downloadedAt, fileSize, status (pending/downloading/completed/failed)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ユーザーが検索から購読完了まで3操作以内で完了できる
- **SC-002**: タップから音声再生開始まで500ms以内に開始する
- **SC-003**: バックグラウンド再生中にOSによってプロセスが終了しない（フォアーグラウンドサービス維持）
- **SC-004**: ダウンロード失敗率が5%以下である
- **SC-005**: アプリのコールドスタートが2秒以内（中端末基準）
- **SC-006**: バッテリー消費は1時間のバックグラウンド再生で5%以下
- **SC-007**: スクリーンリーダー操作時に全ての主要機能がアクセス可能
- **SC-008**: Web版とAndroid版のUI一貫性が90%以上（ピクセルパーフェクト）

## Assumptions

- **Assumption about target users**: ポッドキャストは1日1回以上聴くリスナー。通勤時間や家事時間に使用。
- **Assumption about scope boundaries**: v1ではAndroidとWebのみ。iOS/Deskotpは将来対応。
- **Assumption about data/environment**: ネットワーク環境は基本的にWi-Fiまたは4G/5Gを想定。
- **Dependency on existing system/service**: iTunes Search APIが無料利用枠（制限あり）で利用可能であること。
- **Assumption about authentication**: 認証にはGoogle Sign-Inを使用（v1ではローカルストレージのみのモードも可能）。
