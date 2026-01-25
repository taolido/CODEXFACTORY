#!/bin/bash
# 新規プロジェクト生成スクリプト
# Usage: ./scripts/create-project.sh <project-name> [github-repo-name]

set -e

PROJECT_NAME=$1
REPO_NAME=${2:-$PROJECT_NAME}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FACTORY_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$(dirname "$FACTORY_DIR")/$PROJECT_NAME"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./scripts/create-project.sh <project-name> [github-repo-name]"
    echo "Example: ./scripts/create-project.sh my-api"
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR already exists"
    exit 1
fi

echo "Creating project: $PROJECT_NAME"
echo "Target: $TARGET_DIR"
echo ""

# ディレクトリ作成
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# 基本構造作成
mkdir -p .codex agents src tests docs requirements tasks

# CODEXFACTORYからファイルをコピー
cp "$FACTORY_DIR/.codex/config.json" .codex/
cp "$FACTORY_DIR/agents/project-manager/AGENT.md" agents/
cp "$FACTORY_DIR/agents/developer/AGENT.md" agents/developer.md
cp "$FACTORY_DIR/agents/tester/AGENT.md" agents/tester.md
cp "$FACTORY_DIR/agents/reviewer/AGENT.md" agents/reviewer.md
cp "$FACTORY_DIR/docs/WORKFLOW.md" docs/
cp "$FACTORY_DIR/requirements/TEMPLATE.md" requirements/

# AGENTS.md を生成
cat > AGENTS.md << 'EOF'
# AGENTS.md

## プロジェクト構成

```
├── .codex/           # Codex設定
├── agents/           # エージェント定義
├── src/              # ソースコード
├── tests/            # テストコード
├── requirements/     # 要件定義
├── tasks/            # タスク
└── docs/             # ドキュメント
```

## エージェント

| Agent | 詳細 |
|-------|------|
| Project Manager | [agents/AGENT.md](agents/AGENT.md) |
| Developer | [agents/developer.md](agents/developer.md) |
| Tester | [agents/tester.md](agents/tester.md) |
| Reviewer | [agents/reviewer.md](agents/reviewer.md) |

## ワークフロー

1. `requirements/` に要件を配置
2. タスク分解 → `tasks/`
3. 実装 → `src/`
4. テスト → `tests/`
5. レビュー → PR

## コミュニケーション

- **すべてのやり取りは日本語で行う**
- コミットメッセージ: 日本語
- PRタイトル・説明: 日本語

## コーディング規約

- 未使用コードを残さない
- 過度な抽象化を避ける
- セキュリティ脆弱性を作り込まない
EOF

# .gitignore を生成
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.venv/
__pycache__/
*.pyc

# Build
dist/
build/
*.egg-info/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local

# Logs
*.log

# Test
coverage/
.pytest_cache/
EOF

# Git初期化
git init
git add -A
git commit -m "Initial project setup from CODEXFACTORY template"

echo ""
echo "✓ Project created: $TARGET_DIR"
echo ""
echo "Next steps:"
echo "  cd $TARGET_DIR"
echo ""
echo "  # GitHubにリポジトリ作成してpush"
echo "  gh repo create $REPO_NAME --public -y"
echo "  git remote add origin https://github.com/\$(gh api user -q .login)/$REPO_NAME.git"
echo "  git push -u origin main"
echo ""
echo "  # 要件を追加"
echo "  # requirements/TEMPLATE.md を参考に要件ファイル作成"
echo ""
echo "  # Codexで開発開始"
echo "  codex cloud exec \"requirements/xxx.md を実装して\""
