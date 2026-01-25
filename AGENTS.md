# AGENTS.md - Codex Configuration

このリポジトリはOpenAI Codexによる自律駆動開発のためのファクトリーです。

## プロジェクト構成

```
CODEXFACTORY/
├── agents/                 # エージェント定義
│   ├── project-manager/    # オーケストレーター
│   ├── developer/          # 実装担当
│   ├── tester/             # テスト担当
│   └── reviewer/           # レビュー担当
├── requirements/           # 要件定義ファイル
├── tasks/                  # タスクファイル
└── docs/                   # ドキュメント
```

## 自律駆動ワークフロー

1. `requirements/` に要件定義を配置
2. Project Manager Agentがタスクを分解
3. 各専門エージェントが並列実行
4. Reviewer Agentが品質チェック
5. PRを自動生成

## コーディング規約

- 未使用コードを残さない
- 進捗・完了宣言を書かない
- 冗長なコメントを書かない
- セキュリティ脆弱性を作り込まない
- 過度な抽象化を避ける

## 使用技術

- Python (FastAPI, bpy)
- TypeScript (React, Next.js)
- Node.js
