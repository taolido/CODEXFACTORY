# AGENTS.md - Codex Configuration

このリポジトリはOpenAI Codexによる自律駆動開発のためのファクトリーです。

## プロジェクト構成

```
CODEXFACTORY/
├── .codex/                 # Codex設定
│   └── config.json
├── agents/                 # エージェント定義
│   ├── project-manager/    # オーケストレーター
│   ├── developer/          # 実装担当
│   ├── tester/             # テスト担当
│   └── reviewer/           # レビュー担当
├── requirements/           # 要件定義ファイル
├── tasks/                  # 分解されたタスク
├── src/                    # ソースコード
├── tests/                  # テストコード
└── docs/                   # ドキュメント
```

## エージェント

| Agent | Role | 詳細 |
|-------|------|------|
| Project Manager | オーケストレーター | [agents/project-manager/AGENT.md](agents/project-manager/AGENT.md) |
| Developer | 実装 | [agents/developer/AGENT.md](agents/developer/AGENT.md) |
| Tester | テスト | [agents/tester/AGENT.md](agents/tester/AGENT.md) |
| Reviewer | レビュー | [agents/reviewer/AGENT.md](agents/reviewer/AGENT.md) |

## 自律駆動ワークフロー

詳細: [docs/WORKFLOW.md](docs/WORKFLOW.md)

1. `requirements/` に要件定義を配置
2. Project Manager Agentがタスクを分解 → `tasks/`
3. Developer Agentが実装 → `src/`
4. Tester Agentがテスト → `tests/`
5. Reviewer Agentが品質チェック
6. PRを自動生成

## コミュニケーション

- **すべてのやり取りは日本語で行う**
- コミットメッセージ: 日本語
- PRタイトル・説明: 日本語
- コメント: 日本語
- エラー報告: 日本語

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
