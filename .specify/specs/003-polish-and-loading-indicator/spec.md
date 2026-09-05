# Feature Specification: Polish & Loading Indicator

**Feature Branch**: `003-polish-and-loading-indicator`

**Created**: 2026-09-04

**Status**: Draft

**Input**: "Issue #61: Add loading indicator to refresh button and complete Phase 6 polish"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Refresh Button Loading State (Priority: P1)

ユーザーが PodcastDetailScreen で「更新」ボタンをタップした際、更新中であることが視覚的にフィードバックされる。現在、ローディング状態が表示されないため、ユーザーは更新が完了したか判断できない。

**Why this priority**: ユーザー体験に直結する基本的なフィードバック。操作性の信頼性に影響する。

**Independent Test**: PodcastDetailScreen を開き、更新ボタンをタップすると、ボタンが無効になり、CircularProgressIndicator が表示されることを確認。

**Acceptance Scenarios**:

1. **Given** PodcastDetailScreen が表示されているとき、**When** 更新ボタンをタップすると、**Then** ボタンが無効になり、CircularProgressIndicator が表示される
2. **Given** 更新処理が完了すると、**When** 更新が終了すると、**Then** ボタンが再有効化され、通常のアイコンに戻る
3. **Given** 更新処理中にエラーが発生したとき、**When** エラーが返ると、**Then** ボタンが再有効化され、エラーメッセージが SnackBar で表示される

---

### User Story 2 - Settings Screen Riverpod Migration (Priority: P2)

設定画面が Riverpod で管理され、`setState` が排除される。これにより、状態管理が統一され、テスト容易性が向上する。

**Why this priority**: アーキテクチャの一貫性と保守性の向上。

**Independent Test**: SettingsScreen が ConsumerWidget として実装され、`setState` が使用されていないことを確認。

**Acceptance Scenarios**:

1. **Given** SettingsScreen が表示されているとき、**When** 設定値を変更すると、**Then** Riverpod を通じて状態が更新され、UI に即座に反映される
2. **Given** エラーが発生したとき、**When** エラーが返ると、**Then** AsyncValue.error として適切にハンドリングされる
3. **Given** `grep -r "setState" lib/presentation/screens/settings_screen.dart` を実行すると、**Then** 0 件である

---

### User Story 3 - Repository Pattern Cleanup (Priority: P3)

リポジトリの `prefer_initializing_formals` リントが修正され、コード品質が向上する。また、リアクティブなストリームを使用することで、データ変更が自動的に UI に反映される。

**Why this priority**: コード品質とリアクティブ性の向上。

**Independent Test**: `flutter analyze` で `prefer_initializing_formals` が 0 件であることを確認。

**Acceptance Scenarios**:

1. **Given** `flutter analyze` を実行したとき、**When** 分析が完了すると、**Then** `prefer_initializing_formals` の警告が 0 件である
2. **Given** データベースの内容が変更されたとき、**When** サブスクリプションリストが更新されると、**Then** UI が自動的に再描画される

---

### User Story 4 - Service Provider Injection (Priority: P3)

DownloadService がプロバイダーから注入され、テスト時にモック差し替えが可能になる。

**Why this priority**: テスト容易性の向上。

**Independent Test**: DownloadService をモックにオーバーライドして DownloadsScreen のテストが可能であることを確認。

**Acceptance Scenarios**:

1. **Given** テスト環境で、**When** DownloadService をモックにオーバーライドすると、**Then** DownloadsScreen がモックを使用する
2. **Given** 本番環境で、**When** アプリを起動すると、**Then** 実物の DownloadService が使用される

---

### User Story 5 - Deprecated API Migration (Priority: P3)

`RadioListTile` が `RadioGroup` に移行され、非推奨 API が排除される。

**Why this priority**: Flutter のアップデートに伴う互換性維持。

**Independent Test**: `flutter analyze` で `deprecated_member_use` が 0 件であることを確認。

**Acceptance Scenarios**:

1. **Given** `flutter analyze` を実行したとき、**When** 分析が完了すると、**Then** `deprecated_member_use` の警告が 0 件である
2. **Given** SettingsScreen が表示されているとき、**When** ラジオボタンを選択すると、**Then** 正しく選択状態が更新される

---

### Edge Cases

- **What happens when** ネットワーク接続が不安定で更新が遅延した場合 → ローディングインジケーターが表示され続ける
- **What happens when** ユーザーがローディング中に画面を離れた場合 → ローディング状態は維持され、画面に戻った際に再評価される
- **How does system handle** 複数の設定値を同時に変更した場合 → 各設定は独立して更新される
- **How does system handle** DownloadService モック注入が失敗した場合 → デフォルトの実物が使用されるフォールバックが用意される

## Requirements *(mandatory)*

### Functional Requirements

#### Loading Indicator (P1)
- **FR-001**: System MUST 更新ボタンがローディング中に無効であること
- **FR-002**: System MUST ローディング中に CircularProgressIndicator を表示すること
- **FR-003**: System MUST ローディング完了後にボタンを再有効化すること
- **FR-004**: System MUST エラー発生時に SnackBar でエラーメッセージを表示すること

#### Settings Screen Migration (P2)
- **FR-005**: System MUST SettingsScreen を ConsumerWidget として実装すること
- **FR-006**: System MUST setState を一切使用しないこと
- **FR-007**: System MUST エラー状態を AsyncValue でハンドリングすること

#### Repository Cleanup (P3)
- **FR-008**: System MUST リポジトリの `prefer_initializing_formals` リントを修正すること
- **FR-009**: System MUST `Stream.fromFuture()` を `query.watch()` に置き換えること

#### Service Provider Injection (P3)
- **FR-010**: System MUST DownloadService をプロバイダーから注入すること
- **FR-011**: System MUST テスト時に DownloadService をモックで差し替え可能にすること

#### Deprecated API Migration (P3)
- **FR-012**: System MUST RadioListTile を RadioGroup に移行すること
- **FR-013**: System MUST `deprecated_member_use` 警告を 0 にすること

### Key Entities

- **EpisodesState**: エピソードリストの状態。`isLoading` フィールドを持つ。
- **SearchState**: 検索状態。`isLoading` フィールドを持つ。
- **DownloadState**: ダウンロード状態。`progress` マップと `localPaths` マップを持つ。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 更新ボタンローディング中にボタンが無効である（タップ不可）
- **SC-002**: `grep -r "setState" lib/` が 0 件を返す
- **SC-003**: `flutter analyze` で `prefer_initializing_formals` が 0 件である
- **SC-004**: `flutter analyze` で `deprecated_member_use` が 0 件である
- **SC-005**: DownloadService のモック注入テストが可能である
- **SC-006**: 既存ユニットテスト（101 tests）が全てパスする

## Assumptions

- **Assumption about scope**: 本機能は Phase 6（Polish）の完了を目的とし、新機能追加は含まない。
- **Assumption about backward compatibility**: 外部 API（iTunes Search API, RSS フィード）の変更は含まない。
- **Assumption about Riverpod version**: 既存の `flutter_riverpod: ^2.6.1` を使用し、バージョンアップは行わない。
- **Assumption about testing**: 既存ユニットテストは変更なし。ただし、リファクタリングに伴う修正が必要な場合は対応する。
- **Assumption about Flutter version**: Flutter 3.47+ / Dart 3.13+ を対象とし、RadioGroup はサポートされている。
