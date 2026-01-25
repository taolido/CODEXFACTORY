# 新プロジェクトの始め方

CODEXFACTORYを使って新しいプロジェクトを開発する方法。

---

## プロジェクト作成

### スクリプトで自動生成

```bash
cd /mnt/c/myproject/CODEXFACTORY
./scripts/create-project.sh my-new-project
```

これで以下が作成される：

```
/mnt/c/myproject/my-new-project/
├── .codex/
│   └── config.json
├── agents/
│   ├── AGENT.md (project-manager)
│   ├── developer.md
│   ├── tester.md
│   └── reviewer.md
├── src/
├── tests/
├── requirements/
│   └── TEMPLATE.md
├── tasks/
├── docs/
│   └── WORKFLOW.md
├── AGENTS.md
└── .gitignore
```

### GitHubにpush

```bash
cd /mnt/c/myproject/my-new-project
gh repo create my-new-project --public -y
git remote add origin https://github.com/YOUR_USERNAME/my-new-project.git
git push -u origin main
```

---

## 開発開始

### 方法1: Codex Cloud（Web）

1. https://chatgpt.com/codex にアクセス
2. 作成したリポジトリを接続
3. タスクを投げる：

```
requirements/xxx.md を読んで、
AGENTS.md のワークフローに従って実装して。
テストも書いてPRを作成して。
```

### 方法2: Codex CLI

```bash
cd /mnt/c/myproject/my-new-project

# 対話モード
codex

# 直接実行
codex "requirements/xxx.md を読んで実装して"

# 放置したいなら
codex --full-auto "requirements/xxx.md を読んで実装してPR作成"

# Cloudで実行（完全放置）
codex cloud exec "requirements/xxx.md を読んで実装してPR作成"
```

---

## 比較表

| やりたいこと | コマンド / 操作 |
|-------------|----------------|
| 対話しながら | `codex` |
| ローカルで放置 | `codex --full-auto "..."` |
| Cloudで放置 | `codex cloud exec "..."` |
| Webで放置 | chatgpt.com/codex でタスク入力 |

---

## 推奨プロンプト例

### シンプル版

```
requirements/my-feature.md を実装して
```

### 詳細版

```
requirements/my-feature.md を読んで、
AGENTS.md と docs/WORKFLOW.md に従って開発して。

1. タスクを tasks/ に分解
2. src/ に実装
3. tests/ にテスト作成
4. 全テスト通過後にPR作成
```

### 並列実行版（Cloud推奨）

```
以下を並列で実行して：
- requirements/api.md → バックエンド実装
- requirements/frontend.md → フロントエンド実装
```

---

## 実際の流れ

```
[スクリプトでプロジェクト作成]
   ↓
[GitHubにpush]
   ↓
[requirements/ に要件を書く]
   ↓
[codex cloud exec "..." または Web]
   ↓
[放置]
   ↓
[PR来たらレビュー＆マージ]
```

---

## Tips

| ポイント | 説明 |
|----------|------|
| 要件は具体的に | 曖昧だとCodexが迷う |
| 1要件1ファイル | 管理しやすい |
| 技術スタック明記 | 使いたい技術を指定 |
| AGENTS.md参照を促す | 「AGENTS.mdに従って」と書く |
