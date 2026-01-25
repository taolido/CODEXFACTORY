# 新プロジェクトの始め方

CODEXFACTORYを使って新しいプロジェクトを開発する方法。

---

## 方法1: Codex Cloud（Web）

### Step 1: 要件ファイルを作成

```bash
# ローカルで要件を追加
cd /mnt/c/myproject/CODEXFACTORY
```

```markdown
# requirements/my-new-project.md

## プロジェクト名
My New Project

## 概要
○○をする API

## 機能要件
1. ユーザー登録
2. ログイン
3. データCRUD

## 技術スタック
- Python / FastAPI
```

```bash
git add requirements/my-new-project.md
git commit -m "Add my-new-project requirements"
git push
```

### Step 2: Codex Cloudでタスク投げる

https://chatgpt.com/codex にアクセスして：

```
requirements/my-new-project.md を読んで、
AGENTS.md のワークフローに従って実装して。
テストも書いてPRを作成して。
```

→ Codexが自律で動いてPRが来る

---

## 方法2: Codex CLI

### Step 1: 同じく要件ファイル作成

```bash
cd /mnt/c/myproject/CODEXFACTORY
# requirements/my-new-project.md を作成
```

### Step 2: CLIでタスク実行

```bash
# 対話モード
codex

# または直接実行
codex "requirements/my-new-project.md を読んで実装して"

# 放置したいなら
codex --full-auto "requirements/my-new-project.md を読んで実装してPR作成"

# Cloudで実行（完全放置）
codex cloud exec "requirements/my-new-project.md を読んで実装してPR作成"
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
requirements/my-new-project.md を実装して
```

### 詳細版

```
requirements/my-new-project.md を読んで、
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
- requirements/docs.md → ドキュメント作成
```

---

## 実際の流れ

```
[あなた]
   ↓
requirements/ に要件を書く
   ↓
git push
   ↓
codex cloud exec "..." または Web
   ↓
[放置]
   ↓
PR来たらレビュー＆マージ
```

---

## Tips

| ポイント | 説明 |
|----------|------|
| 要件は具体的に | 曖昧だとCodexが迷う |
| 1要件1ファイル | 管理しやすい |
| 技術スタック明記 | 使いたい技術を指定 |
| AGENTS.md参照を促す | 「AGENTS.mdに従って」と書く |
