# 自律駆動開発ワークフロー

## 概要

```
[要件定義]
    ↓
[Project Manager] ─→ タスク分解
    ↓
┌───┴───┐
↓       ↓
[Developer] [Developer]  ← 並列実行
    ↓       ↓
[Tester] [Tester]
    ↓       ↓
└───┬───┘
    ↓
[Reviewer]
    ↓
[PR作成]
```

## フェーズ詳細

### Phase 1: 要件分析
- Project Managerが `requirements/` を読む
- タスクに分解
- 依存関係を特定
- `tasks/` に書き出し

### Phase 2: 実装
- Developerがタスクを取得
- 並列で実装
- 基本動作確認

### Phase 3: テスト
- Testerがテストコード作成
- テスト実行
- 失敗時はDeveloperに差し戻し

### Phase 4: レビュー
- Reviewerが品質チェック
- セキュリティ確認
- 承認またはリジェクト

### Phase 5: 統合
- Project Managerが統合
- PR作成
- 完了報告

## タスクの状態

```
pending → in_progress → testing → reviewing → completed
                ↓           ↓
            blocked     rejected
```

## ファイル構成

```
requirements/
  └── {project-name}.md    # 要件定義

tasks/
  └── TASK_{id}.md         # 分解されたタスク

src/
  └── ...                  # 実装コード

tests/
  └── ...                  # テストコード
```
