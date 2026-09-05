# Feature Specification: Architecture Improvements — State Management, Navigation & DI

**Feature Branch**: `002-architecture-improvements`

**Created**: 2026-09-04

**Status**: Draft

**Input**: "すぐに修正すべきものの3つを先に対応します。speckitで進めてください"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consistent State Management (Priority: P1)

開発者がコードベース全体で一貫した状態管理パターンを使用できる。現在、HomeScreen・SearchScreen・PodcastDetailScreen は `StatefulWidget + setState` を使っているが、PlayerScreen などは Riverpod を使っている。この混在はバグの原因となり、新機能開発の速度を落とす。

**Why this priority**: アーキテクチャの不整合は、バグの温床となり、コードレビューのコストを高める。早急に統一すべき根本問題。

**Independent Test**: 全ての画面が Riverpod の `ConsumerWidget` または `ConsumerStatefulWidget` として実装され、`setState` が使われていないことを確認。

**Acceptance Scenarios**:

1. **Given** HomeScreen が表示されているとき、**When** 購読リストを読み込むと、**Then** Riverpod の `FutureProvider` または `StreamProvider` を通じてデータが取得され、UI が更新される
2. **Given** SearchScreen が表示されているとき、**When** 検索を実行すると、**Then** Riverpod の `Notifier` を通じて検索状態が管理され、結果が表示される
3. **Given** PodcastDetailScreen が表示されているとき、**When** 購読ボタンをタップすると、**Then** Riverpod の `Notifier` を通じて購読状態が更新され、UI に即座に反映される
4. **Given** 全ての画面が Riverpod ベースで、**When** `flutter analyze` を実行すると、**Then** エラーや警告（未使用インポート等）が出ない

---

### User Story 2 - Working Navigation (Priority: P1)

ユーザーが画面間をシームレスに移動できる。現在、HomeScreen と SearchScreen の `onTap` がコメントアウトされており、タップしても何も起こらない。

**Why this priority**: ナビゲーションが機能しないと、ユーザーはアプリを使えない。最優先で修正必須。

**Independent Test**: 各画面から適切な遷移先へ `go_router` を使って遷移できることを確認。

**Acceptance Scenarios**:

1. **Given** HomeScreen の購読一覧が表示されているとき、**When** ポードキャストをタップすると、**Then** `context.push('/podcast/:id')` が呼び出され、PodcastDetailScreen に遷移する
2. **Given** SearchScreen の検索結果が表示されているとき、**When** ポッドキャストをタップすると、**Then** `context.push('/podcast/:id')` が呼び出され、PodcastDetailScreen に遷移する
3. **Given** PodcastDetailScreen が表示されているとき、**When** エピソードをタップすると、**Then** 再生が開始され、ミニプレーヤーが表示される
4. **Given** ミニプレーヤーが表示されているとき、**When** タップすると、**Then** `context.push('/player')` が呼び出され、PlayerScreen に遷移する
5. **Given** どの画面からでも、**When** バックボタンを押すと、**Then** 前の画面に戻る

---

### User Story 3 - Dependency Injection via Riverpod (Priority: P1)

全ての依存関係（Repository, Service, Database）が Riverpod プロバイダーから取得される。現在、一部のクラスで `AppDatabase.instance` を直接参照しており、テスト時に差し替えられない。

**Why this priority**: DI が機能しないと、ユニットテストでモック注入ができず、テスト品質が低下する。

**Independent Test**: 全てのリポジトリ・サービスが Riverpod プロバイダーから取得され、テスト時にモック差し替えが可能であることを確認。

**Acceptance Scenarios**:

1. **Given** テスト環境で、**When** `AppDatabase` をモックデータベースにオーバーライドすると、**Then** 全てのリポジトリがモックデータベースを使用する
2. **Given** テスト環境で、**When** `EpisodeRepository` をモックにオーバーライドすると、**Then** 依存する全てのプロバイダーがモックを使用する
3. **Given** プロダクション環境で、**When** アプリを起動すると、**Then** 全てのプロバイダーがデフォルトの実インスタンスを返す
4. **Given** 全ての依存関係が Riverpod 経由で、**When** `AppDatabase.instance` の直接参照を除去すると、**Then** コードベースに `AppDatabase.instance` の直接参照が残っていない

---

### Edge Cases

- **What happens when** Riverpod プロバイダーのオーバーライドが競合した場合 → 最後に適用されたオーバーライドが優先される（Riverpod の仕様）
- **What happens when** 存在しないパスに遷移した場合 → `go_router` の `errorBuilder` が呼び出され、404 画面が表示される
- **What happens when** プロバイダーの初期化に失敗した場合 → `AsyncValue.error` が返り、UI でエラーメッセージが表示される
- **How does system handle** 循環参照（A が B に依存し、B が A に依存）→ Riverpod は循環参照を検出し、実行時にエラーを投げる

## Requirements *(mandatory)*

### Functional Requirements

#### State Management Unification
- **FR-001**: System MUST 全ての画面を Riverpod ベースの `ConsumerWidget` として実装する
- **FR-002**: System MUST `StatefulWidget` + `setSet` パターンを完全に排除する
- **FR-003**: System MUST データ取得に `FutureProvider` または `StreamProvider` を使用する
- **FR-004**: System MUST 状態変更に `StateNotifier` または `AsyncNotifier` を使用する
- **FR-005**: System MUST ローディング状態・エラー状態を `AsyncValue` で統一的に扱う

#### Navigation Implementation
- **FR-006**: System MUST `go_router` を使って全ての画面遷移を実装する
- **FR-007**: System MUST HomeScreen から PodcastDetailScreen への遷移を実装する
- **FR-008**: System MUST SearchScreen から PodcastDetailScreen への遷移を実装する
- **FR-009**: System MUST PodcastDetailScreen から PlayerScreen への遷移を実装する
- **FR-010**: System MUST MiniPlayer から PlayerScreen への遷移を実装する
- **FR-011**: System MUST エピソードタップで再生が開始される機能を実装する

#### Dependency Injection
- **FR-012**: System MUST `AppDatabase` を Riverpod プロバイダーとして公開する
- **FR-013**: System MUST 全てのリポジトリが Riverpod プロバイダーから `AppDatabase` を取得する
- **FR-014**: System MUST 全てのサービスが Riverpod プロバイダーとして公開される
- **FR-015**: System MUST `AppDatabase.instance` の直接参照を全て除去する
- **FR-016**: System MUST テスト時にプロバイダーのオーバーライドが可能である

### Key Entities

- **AppDatabaseProvider**: `AppDatabase` を提供する Riverpod プロバイダー。テスト時にモックデータベースに差し替え可能。
- **RepositoryProvider**: 各リポジトリを提供する Riverpod プロバイダー。`AppDatabaseProvider` に依存。
- **ServiceProvider**: 各サービスを提供する Riverpod プロバイダー。リポジトリに依存する場合がある。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: コードベースに `StatefulWidget` + `setState` パターンがゼロ件（`grep -r "setState" lib/` で該当なし）
- **SC-002**: コードベースに `AppDatabase.instance` の直接参照がゼロ件（`grep -r "AppDatabase.instance" lib/` で該当なし）
- **SC-003**: 全ての画面が `ConsumerWidget` または `ConsumerStatefulWidget` として実装される
- **SC-004**: 全てのナビゲーションが `go_router` の `context.push` または `context.go` で実装される
- **SC-005**: テスト時にプロバイダーのオーバーライドが正常に動作する
- **SC-006**: `flutter analyze` がエラーなしでパスする
- **SC-007**: 既存のユニットテストが全てパスする

## Assumptions

- **Assumption about scope**: 今回の修正は既存の機能を壊さない。リファクタリングが目的で、新機能追加は含まない。
- **Assumption about Riverpod version**: 既存の `flutter_riverpod: ^2.6.1` を使用し、バージョンアップは行わない。
- **Assumption about go_router version**: 既存の `go_router: ^15.1.2` を使用し、バージョンアップは行わない。
- **Assumption about testing**: 既存のユニットテストは変更なし。ただし、リファクタリングに伴うテストの修正が必要な場合は対応する。
- **Assumption about backward compatibility**: 外部 API（iTunes Search API, RSS フィード）の変更は含まない。
