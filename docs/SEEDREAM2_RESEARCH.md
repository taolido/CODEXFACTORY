# SEEDREAM 2.0 総合リサーチレポート

> リサーチ日: 2026-04-05
> 情報源: arXiv論文、公式サイト、X(Twitter)、Bilibili、知乎、Reddit、YouTube、各種テックブログ

---

## 目次

1. [Seedreamとは何か](#1-seedreamとは何か)
2. [技術アーキテクチャ（Seedream 2.0）](#2-技術アーキテクチャseedream-20)
3. [シリーズ進化タイムライン（1.0→5.0）](#3-シリーズ進化タイムライン105.0)
4. [アクセス方法・使い方](#4-アクセス方法使い方)
5. [料金体系](#5-料金体系)
6. [プロンプトエンジニアリング](#6-プロンプトエンジニアリング)
7. [ComfyUI統合・ワークフロー](#7-comfyui統合ワークフロー)
8. [SeedEdit（画像編集機能）](#8-seededit画像編集機能)
9. [動画生成（Seedance 2.0）](#9-動画生成seedance-20)
10. [競合モデルとの比較](#10-競合モデルとの比較)
11. [SNS・コミュニティの反応](#11-snsコミュニティの反応)
12. [商用利用・ライセンス](#12-商用利用ライセンス)
13. [制限事項・注意点](#13-制限事項注意点)
14. [プラットフォーム関係図](#14-プラットフォーム関係図)
15. [参考リンク集](#15-参考リンク集)

---

## 1. Seedreamとは何か

Seedream 2.0は、**ByteDance（TikTok親会社）のSeedチーム**が開発した**ネイティブ中国語・英語バイリンガル画像生成基盤モデル**。2024年12月初旬にDoubao（豆包）アプリおよびJimeng（即梦）でリリースされ、**1億人以上のエンドユーザー**に利用されている。

論文は2025年3月13日にarXivで公開: 「Seedream 2.0: A Native Chinese-English Bilingual Image Generation Foundation Model」

---

## 2. 技術アーキテクチャ（Seedream 2.0）

### コアアーキテクチャ

| 要素 | 詳細 |
|------|------|
| ベース | Diffusion Transformer (DiT) + VAE |
| パラメータ数 | 約39億（3.9B） |
| 設計思想 | Stable Diffusion 3のMMDiT原則に準拠 |
| Transformerブロック | 各ブロックに1つのSelf-Attention層、画像・テキストトークンを同時処理 |
| MLP | モダリティ別（画像用・テキスト用を分離） |
| 正規化 | Adaptive Layer Norm（AdaLN）で注意層とMLP層を変調 |
| 位置エンコーディング | Scaled RoPE（未学習解像度への汎化対応） |

### テキストエンコーダ（2系統）

1. **自社開発バイリンガルLLM**: Decoder-onlyアーキテクチャ。CLIP/T5ではなく独自開発。中英両言語のセマンティクスを深く理解
2. **Glyph-Aligned ByT5**: 文字レベルのテキストレンダリング用。複雑な漢字の正確なレンダリングを実現

### 学習データ

- **規模**: 約2.5億の画像テキストペア
- **言語比率**: 中国語70%、英語30%
- **前処理**: 重複排除、審美フィルタリング、不適切コンテンツ除去の多段階クリーニング
- **知識融合**: 「四次元トポロジカルネットワーク」による品質と知識の動的バランス

### ポストトレーニング最適化

1. **Continue Training (CT) + SFT**: 美的品質向上
2. **RLHF**: 3つのリワードモデル使用（画像テキスト整合性RM、美的RM、テキストレンダリングRM）
3. **Prompt Engineering (PE)**: ファインチューニングLLMで美的品質と多様性を改善
4. **Refinerモデル**: 解像度アップスケーリング + 構造エラー修正

### ベンチマーク成績（Seedream 2.0）

| ベンチマーク | 結果 |
|-------------|------|
| EvalMuse総合スコア | **0.8031**（最高位） |
| 構造的側面 | 1位 |
| 画像テキスト整合性 | 2位（Midjourney v6.1を上回る） |
| 審美性 | 2位（Ideogram 2.0を上回る） |
| テキストレンダリング | 中英両言語で最高精度 |
| HPSv2スコア | 最高得点 |

---

## 3. シリーズ進化タイムライン（1.0→5.0）

| バージョン | 時期 | 主な特徴 |
|-----------|------|---------|
| **1.0** | 2023年初頭 | 中国語文字配置に特化 |
| **2.0** | 2024年12月（論文2025年3月） | バイリンガル基盤モデル、MMDiTアーキテクチャ、1億ユーザー達成 |
| **3.0** | 2025年4月 | 2K解像度対応、4〜8倍高速化、GPT-4o超え主張、混合解像度トレーニング |
| **4.0** | 2025年9月 | 画像生成+編集の統合、2K画像1.4秒生成、4K対応、ELOランキング1位 |
| **4.5** | 2025年12月 | 4K解像度、テキストレンダリング94%精度、14枚同時参照画像 |
| **5.0** | 2026年2月 | **Web検索統合（業界初）**、論理的推論、ドメイン知識搭載 |
| **5.0 Lite** | 2026年3月 | 軽量版、API価格$0.035/枚 |

### 姉妹モデル

| モデル | 用途 | 最新バージョン |
|--------|------|-------------|
| **Seedream** | 画像生成・編集 | 5.0 Lite |
| **Seedance** | 動画生成 | 2.0 |
| **Seaweed** | 動画生成基盤（約70億パラメータ） | - |

---

## 4. アクセス方法・使い方

### 方法1: Dreamina（最も手軽・無料あり）

1. https://dreamina.capcut.com にアクセス
2. Googleアカウントで登録
3. 「AI画像」をクリック
4. モデルのドロップダウンからSeedreamバージョンを選択
5. プロンプトを入力（日本語・英語・中国語対応）
6. アスペクト比と出力解像度を設定
7. 「Create」ボタンで生成
8. 生成画像をダウンロード

**毎日225クレジット無料**（1生成≒1クレジット）

### 方法2: API（BytePlus ModelArk）

1. https://console.byteplus.com でアカウント作成
2. ModelArkセクションでAPIキーを発行
3. モデルリストからSeedreamモデルを「Activate」
4. APIエンドポイントでText-to-Image / Image-to-Image を実行
5. **無料トライアル: 200枚**

### 方法3: サードパーティAPI

| プラットフォーム | 対応バージョン | URL |
|---------------|-------------|-----|
| Together AI | 4.0 | https://www.together.ai/models/bytedance-seedream-4-0 |
| fal.ai | 4.0/4.5 | https://fal.ai/models/fal-ai/bytedance/seedream/ |
| WaveSpeed AI | 各種 | https://wavespeed.ai/collections/seedream |
| getimg.ai | 5.0 Lite | https://getimg.ai/models/bytedance-seedream |
| Segmind | 一部 | https://blog.segmind.com/quick-start-guide-seedream/ |
| Replicate | 4.0 | https://replicate.com/bytedance/seedream-4 |
| Kie.ai | 各種 | https://kie.ai/seedream-api |
| OpenRouter | 4.5 | https://openrouter.ai/bytedance-seed/seedream-4.5 |

### 方法4: 即夢/Jimeng（中国版、フル機能）

- URL: https://jimeng.jianying.com
- 中国電話番号が必要
- 月額69元〜
- 国際版より機能が豊富

---

## 5. 料金体系

### API料金（BytePlus ModelArk経由）

| モデル | 料金/枚 |
|-------|---------|
| Seedream 3.0 | $0.03 |
| Seedream 4.0 | $0.03 |
| Seedream 4.5 | $0.04-0.045 |
| Seedream 5.0 Lite | $0.035 |

### サブスクリプション（Dreamina経由）

| プラン | 月額 | 特徴 |
|-------|------|------|
| 無料 | $0 | 毎日225クレジット |
| Pro | 約$23.9-29.99 | 商用ライセンス付き |
| Max/Team | 約$63.9-99.99 | チーム向け、完全商用権利 |

---

## 6. プロンプトエンジニアリング

### 基本構造

Seedreamのプロンプト理解の優先順位:

**Subject（主題） > Style（スタイル） > Composition（構図） > Lighting（照明）**

推奨フォーマット:
```
[アクション] + [対象物] + [属性/詳細]
```

例:
```
A girl in a lavish dress walking under a parasol along a tree-lined path, in the style of a Monet oil painting
```

### プロンプトのベストプラクティス

| 項目 | 推奨 |
|------|------|
| 語数 | 30〜100語が最適 |
| 形容詞 | 3〜5個の的確な修飾語（20個の弱い形容詞より効果的） |
| テキスト挿入 | ダブルクォーテーションで囲む（例: "Hello World"） |
| 複数キャラ | 参照画像にラベル付けしてプロンプトで参照 |
| 照明 | golden hour, dramatic side lighting, soft diffused light 等 |
| カメラ設定 | shot on 85mm lens, shallow depth of field, 4K detail 等 |

### ネガティブプロンプト（15〜25語推奨）

**一般品質:**
```
blurry, low resolution, noisy, jpeg artifacts, overexposed, underexposed, watermark, logo, signature
```

**人体:**
```
extra fingers, distorted hands, deformed eyes, asymmetrical face, bad anatomy, missing fingers, mutated limbs
```

**品質調整:**
```
pixelated, plastic skin, unrealistic shading, exaggerated proportions, oversaturated colors
```

### 解像度・アスペクト比

| 用途 | 推奨比率 |
|------|---------|
| ポートレート | 4:5 |
| プロダクト | 3:2 |
| グリッド | 1:1 |
| 縦型動画 | 9:16 |
| 最大解像度 | 4K (2048x2048) |

### 視覚レイヤー分解テクニック（MaisonAI発）

プロンプトを以下のレイヤーで構築:
1. 被写体
2. シーン
3. 構図
4. 照明
5. レンズ/スタイル
6. カラーパレット
7. 後処理

### 一貫性キャラクター生成テクニック（Sider.ai発）

- クリーンで正面向きの参照画像（1024x1024、影なし）を使用
- 外見/顔ロックを中〜高（70-85%）に設定
- 顔のジオメトリを尊重するよう指示

---

## 7. ComfyUI統合・ワークフロー

### セットアップ手順

1. BytePlusコンソール（console.byteplus.com）でアカウント作成
2. ModelArkセクションでAPIキーを発行
3. 環境変数に設定: `SEEDREAM_API_KEY`, `SEEDREAM_ENDPOINT`
4. ComfyUIカスタムノードをクローン:
   - **公式**: https://github.com/kookliu/ComfyUI-Custom-Nodes
   - **即梦API版**: https://github.com/fkxianzhou/ComfyUI-Jimeng-API
5. custom_nodesディレクトリに配置、依存関係インストール
6. `.env.example`を`.env`にコピーしてAPIキーを記入

### 利用可能なワークフロー

- テキスト→画像生成
- 画像編集
- 最大5枚のリファレンス画像を使ったマルチリファレンス生成
- バッチ自動化（CSV/JSONでプロンプト変数をスワップ → RESTエンドポイント経由）

### 送信パラメータ

`prompt`, `negative_prompt`, `width`, `height`, `steps`, `cfg_scale`, `seed`

### リソース

- ComfyUI公式ブログ: https://blog.comfy.org/p/seedream-40-now-available-in-comfyui
- Seedream 5.0 Lite: https://blog.comfy.org/p/seedream-50-lite-now-available-in
- Civitaiワークフロー: https://civitai.com/models/1968364
- 無料テンプレート: https://www.comfy.org/workflows/model/seedream-4-0/
- note.com解説: https://note.com/seal309midorin/n/n4cd3147d4c6d

---

## 8. SeedEdit（画像編集機能）

Seedream 2.0は、指示ベースの画像編集モデル「SeedEdit」に容易に適応可能。

### 特徴

- 指示追従と画像一貫性のバランスが取れた強力な編集能力
- 合成画像と実写画像の両方で優れた編集品質
- 顔の類似性保持の改善（SeedEdit V1.0の課題を、拡散損失と顔損失の組み合わせで解決）
- 既存のSoTAの学術・製品ベンチマークを上回る性能

### 編集プロンプトの書き方

- **アクション指定**: "remove", "replace", "add", "change", "transform"
- **対象指定**: "background", "object", "text", "lighting"
- **属性付与**: 色、スタイル、条件（例: "without distortions"）
- **位置指定**: 「左のキャラクター」「ボウルの中の赤いリンゴ」など具体的に記述
- 1つのプロンプトに多くの変更を詰め込まず、ステップに分割するのが効果的

---

## 9. 動画生成（Seedance 2.0）

### 特徴

- **4つの入力モダリティ同時受付**: テキスト、画像（最大9枚）、動画クリップ（最大3本）、オーディオ（最大3トラック）
- **ネイティブ2K解像度**出力
- **オーディオ同期生成**: 音声を後付けではなく同時生成
- **マルチショット生成**: ストーリーボードからシネマティックプレビュー
- **キャラクター一貫性**: @リファレンスシステムで複数角度の参照画像をバインド
- **最大12の同時リファレンス入力**

### 映像制作での活用

- ストーリーボードからのプリビジュアライゼーション
- カメラパスの計画・確認
- マルチシーンシーケンスの精査
- ゲーム開発・アニメーション制作のビジュアル化

### アクセス方法

- Dreamina: https://dreamina.capcut.com/tools/seedance-2-0
- CapCut: 動画編集アプリ内から利用
- API: Jimeng / Volcengine APIで提供

### 関連モデル: Seaweed

- 約70億パラメータのDiffusion Transformer動画生成基盤モデル
- 1000台のH100 GPU相当で学習
- 1280x720（24fps）リアルタイム動画生成
- 2560x1440（2K QHD）へのアップサンプル可能
- 公式: https://seaweed.video/

---

## 10. 競合モデルとの比較

### 総合比較表

| 観点 | Seedream 2.0+ | FLUX 2 Pro | Midjourney | DALL-E 3/4o | Stable Diffusion |
|------|-------------|------------|------------|-------------|-----------------|
| フォトリアリズム | 中〜高 | 最高 | 高 | 高 | 中 |
| アーティスティック | 中〜高 | 高 | 最高 | 中〜高 | 中 |
| テキストレンダリング | **最高（中英）** | 高 | 中 | 中〜高 | 低 |
| バイリンガル対応 | **最高** | 英語中心 | 英語中心 | 多言語 | 英語中心 |
| 生成速度 | 高速（4.0以降） | 高速 | 中 | 高速 | 構成依存 |
| コスト | 低〜中 | 中 | 高 | 中 | 低（OSS） |
| オープンソース | 非公開 | 一部公開 | 非公開 | 非公開 | 完全公開 |
| 画像編集統合 | 内蔵 | 別途必要 | 限定的 | 限定的 | 別途必要 |

### Seedream 2.0固有の優位性

1. **バイリンガルテキストレンダリング**: 中英両言語の文字を画像内に正確に描画（2.0時点で業界トップ）
2. **文化的ニュアンス理解**: 中国語コンテンツの文化的文脈（書道、祭り、建築等）
3. **独自LLMテキストエンコーダ**: CLIP/T5に依存しない深いセマンティクス理解
4. **コスト効率**: 大量生成ワークフローでMidjourney/FLUXより優位

### 用途別推奨モデル

| ユースケース | 推奨モデル | 理由 |
|------------|-----------|------|
| Eコマースヒーロー画像 | Flux 2 Pro | 鮮明なテクスチャ、正確なマテリアル |
| テキスト入り製品画像 | Ideogram V3 | テキスト配置の精度 |
| 大量ライフスタイル画像 | **Seedream** | コスパが最も良い |
| 芸術的・創造的作品 | Midjourney | シネマティックな美学 |
| 中国語テキスト入り画像 | **Seedream** | バイリンガルテキストレンダリング |

---

## 11. SNS・コミュニティの反応

### X（Twitter）の主要インフルエンサー

| アカウント | 反応 |
|-----------|------|
| **@TheoMediaAI** (Theoretically Media) | 「Here's the Seedream 2.0 Rundown! Amazing model! ByteDance really cooked here!」と絶賛。多数の実例を共有 |
| **@gavinpurcell** (Gavin Purcell) | 「seedream 2.0 is the first AI video model in a long while that I'm going to pay for through the API」API課金する意欲を表明 |
| **@Xianbao_QIAN** (Tiezhen WANG) | 論文公開を告知、技術コミュニティに拡散 |
| **@koltregaskes** | Seedream 2.0画像生成モデルの情報共有 |
| **@dreamina_ai** (公式) | Seedance 2.0 + Seedream 5.0 Liteの利用開始を公式発表 |
| **@karim_yourself** | BytePlusのPlaygroundでの具体的な使い方を解説 |

### 肯定的な評価

- 「画像のリアリズムが驚異的で、本物との区別がほぼ不可能」
- 「スタイル転送、ブランドロゴ、クリエイティブポスターの処理が優秀」
- 「検閲が少なく、創造的自由度が高い」
- TechRadar: 「これまで見た中で最高のAI画像ジェネレーター」

### 批判的な評価

- 「手、足、影、布地の細部ではNano Bananaの方がまだ強い」
- 「高スコアは拒否回数の少なさが一因で、純粋な画像品質だけではない」
- 「オープンソースでない点が残念」
- 「バズがマーケティング主導だ」という指摘も一部あり
- 特殊なリクエスト（例: 溢れないワイングラス）には依然として苦戦

### 中国語圏コミュニティ

**Bilibili:**
- 「Nano Bananaを背刺する」Seedream 4.0深度評測動画（BV1LcHzzrEiB）
- 「AI生成画像の新王」即梦Seedream 4.0全網最全玩法（BV19LWGzPE9k）
- Seedream 5.0二次元風景の季節変更応用例（BV1M8c7zSERT）
- 豆包APIバッチ画像生成ツール紹介（BV1obWwzyEeu）

**知乎 (Zhihu):**
- 「字節公開Seedream 2.0技術細節」技術解説記事
- 「中国版Nano-Banana！即梦4.0完整使用指南」チュートリアル
- 「AI視頻的大結局？Seedance 2.0掀桌子了!」動画生成AI評価

**Douyin:**
- 即梦AI公式アカウントがコンテンツ発信
- コマースクリエイターが広告クリエイティブ制作に活用（**制作コスト最大40%削減**の報告）

### コミュニティ

- **Seedance 2.0 Discord**: discord.com/invite/zZFUeA8ZQF（小規模、約29メンバー）
- **Product Hunt**: Seedream 2.0が登録済み
- **Reddit**: AI画像生成サブレディットでSeedreamシリーズの話題は活発だが専用サブレディットはなし
- **バイラル**: Seedance 2.0はElon Muskも関心を示したと報道。「ハリウッドを揺るがす」との評価も

---

## 12. 商用利用・ライセンス

### Dreaminaプラットフォーム経由

| プラン | 商用利用 | 詳細 |
|-------|---------|------|
| 無料 | 限定的 | 基本的な生成・利用のみ |
| 有料（Pro以上） | **完全な商用利用権** | 販売、クライアントワーク、商標登録可。帰属表示不要 |

### API経由

- BytePlus / ModelArkの利用規約に準拠
- エンタープライズプランで明確な商用権利

### 注意事項

- ユーザーがアップロードしたコンテンツについて、プラットフォームにワールドワイド・非独占的・ロイヤリティフリーのライセンスが付与される（利用規約）
- 2026年3月にハリウッドスタジオとの著作権紛争により一部APIが停止された経緯あり

---

## 13. 制限事項・注意点

### Seedream 2.0固有

1. **視覚的忠実度**: FLUX/Midjourneyに比べフォトリアリズムが劣る面あり（3.0以降で改善）
2. **推論速度**: 競合に比べ不利（3.0で4〜8倍に高速化）
3. **オープンソースではない**: モデルウェイトは非公開
4. **2.0単体のAPI提供なし**: 技術は後続バージョンに統合済み

### シリーズ全体

- 小さい文字の繰り返し・劣化が発生する場合あり
- 画像編集精度の限界
- ぼかし・クロッピング問題（4.5で時折発生）
- AI生成感が残る場合あり
- 人体プロポーション問題
- 地域制限（一部機能は中国国内版のみ）
- コンテンツフィルタリング: BytePlus APIにデフォルトのプレフィルタースイッチあり（一部プラットフォームでは無効化可能）

---

## 14. プラットフォーム関係図

```
ByteDance Seedチーム
  │
  ├── Seedream（画像生成モデル）
  │     ├── Dreamina / 即梦 / Jimeng（コンシューマー向け）
  │     ├── CapCut / 剪映（動画編集アプリ内統合）
  │     ├── BytePlus / ModelArk（エンタープライズAPI）
  │     ├── 小云雀 / Oriental Skylark（中国国内）
  │     └── サードパーティ（fal.ai, Together AI, Replicate等）
  │
  ├── Seedance（動画生成モデル）
  │     └── 上記と同じプラットフォームで提供
  │
  ├── Seaweed（動画生成基盤モデル）
  │
  └── Doubao / 豆包（AIアシスタント - Seedreamと連携）
```

---

## 15. 参考リンク集

### 論文

| タイトル | URL |
|---------|-----|
| Seedream 2.0 (arXiv) | https://arxiv.org/abs/2503.07703 |
| Seedream 2.0 (HTML版) | https://arxiv.org/html/2503.07703v1 |
| Seedream 3.0 Technical Report | https://arxiv.org/abs/2504.11346 |
| HuggingFace Papers | https://huggingface.co/papers/2503.07703 |
| ResearchGate | https://www.researchgate.net/publication/389748435 |

### 公式

| サイト | URL |
|-------|-----|
| ByteDance Seed公式 | https://seed.bytedance.com/en/ |
| Dreamina公式 | https://dreamina.capcut.com |
| 即梦 (Jimeng) | https://jimeng.jianying.com |
| BytePlus ModelArk | https://console.byteplus.com |
| Seaweed | https://seaweed.video/ |

### 日本語チュートリアル・ガイド

| タイトル | URL |
|---------|-----|
| Seedream 5.0使い方 Dreamina公式 | https://dreamina.capcut.com/ja-jp/resource/how-to-use-seedream-5-0 |
| Seedream 4.0完全解説（図解） | https://ai-workstyle.com/ai-seedream4-0/ |
| Seedream 4.0使い方完全ガイド | https://ai-gaido.com/seedream-4-0-use-guide/ |
| Seedream 4.5徹底解説（WEEL） | https://weel.co.jp/media/tech/seedream-4-5/ |
| ComfyUIで使う方法（note.com） | https://note.com/seal309midorin/n/n4cd3147d4c6d |
| プロンプトのコツ（note.com） | https://note.com/genel/n/n97c215fddc7c |
| プロンプト攻略ガイド（note.com） | https://note.com/tasty_dunlin998/n/n5472617b9feb |
| romptn Magazine Seedream 4.0解説 | https://romptn.com/article/73378 |
| Seedream実践編プロンプト（MaisonAI） | https://maisonai.io/en/blogs/guidebook/seedream-imagegereration-2 |

### 英語チュートリアル・ガイド

| タイトル | URL |
|---------|-----|
| Complete Tutorial 4.0→5.0 (WaveSpeed) | https://wavespeed.ai/blog/posts/seedream-4-0-to-5-0-complete-tutorial-image-generation-editing/ |
| Seedream 5.0 Complete Guide (WaveSpeed) | https://wavespeed.ai/blog/posts/seedream-5-0-preview-complete-guide-intelligent-image-generation/ |
| Guide to Seedream 4 (getimg.ai) | https://getimg.ai/blog/guide-to-bytedance-seedream-4-ai-image-model |
| Prompt Engineering Guide (Segmind) | https://blog.segmind.com/mastering-seedream-prompt-engineering-guide/ |
| Seedream v4.5 Prompt Guide (fal.ai) | https://fal.ai/learn/devs/seedream-v4-5-prompt-guide |
| 公式Prompt Guide (BytePlus) | https://docs.byteplus.com/en/docs/ModelArk/1829186 |
| 70 Styles Prompt Book (Sider.ai) | https://sider.ai/blog/ai-tools/seedream-4-0-prompt-book-70-styles-for-portraits-fashion-and-products |
| Consistent Characters Guide (Sider.ai) | https://sider.ai/blog/ai-tools/how-to-use-seedream-4-0-for-consistent-characters-a-step-by-step-playbook |
| Quick Start Guide (Segmind) | https://blog.segmind.com/quick-start-guide-seedream/ |
| Seedream 4o Prompting Guide (Atlabs) | https://www.atlabs.ai/blog/seedream-4o-prompting-guide |
| How to use Seedream 4.5 (Artlist) | https://artlist.io/blog/how-to-use-seedream-4-5/ |
| API Guide 4.0-5.0 (BytePlus) | https://docs.byteplus.com/en/docs/ModelArk/1824121 |
| FLUX 2 vs Seedream比較 | https://wavespeed.ai/blog/en/blog/posts/flux-2-vs-seedream-comparison-2026/ |
| 5.0 vs Nano Banana 2テキスト比較 | https://blog.segmind.com/seedream-5-0-lite-vs-nano-banana-2-a-text-rendering-showdown-across-7-real-world-use-cases/ |

### ComfyUI

| タイトル | URL |
|---------|-----|
| 公式ブログ Seedream 4.0 | https://blog.comfy.org/p/seedream-40-now-available-in-comfyui |
| 公式ブログ Seedream 5.0 Lite | https://blog.comfy.org/p/seedream-50-lite-now-available-in |
| カスタムノード (kookliu) | https://github.com/kookliu/ComfyUI-Custom-Nodes |
| Jimeng API版 (fkxianzhou) | https://github.com/fkxianzhou/ComfyUI-Jimeng-API |
| Civitaiワークフロー | https://civitai.com/models/1968364 |
| 無料テンプレート | https://www.comfy.org/workflows/model/seedream-4-0/ |

### API・サードパーティ

| サービス | URL |
|---------|-----|
| Together AI | https://www.together.ai/models/bytedance-seedream-4-0 |
| fal.ai | https://fal.ai/models/fal-ai/bytedance/seedream/ |
| Replicate | https://replicate.com/bytedance/seedream-4 |
| Kie.ai | https://kie.ai/seedream-api |
| OpenRouter | https://openrouter.ai/bytedance-seed/seedream-4.5 |
| Jimeng無料API (GitHub) | https://github.com/wwwzhouhui/jimeng-free-api-all |
| Seedream 5.0 Lite API Guide | https://help.apiyi.com/en/seedream-5-0-lite-api-guide-cheaper-than-4-5-en.html |

### X (Twitter) 注目投稿

| 投稿者 | URL/内容 |
|-------|---------|
| @TheoMediaAI | Seedream 2.0 Rundownと高評価 |
| @gavinpurcell | API課金する意欲を表明 |
| @dreamina_ai | Seedance 2.0 + Seedream 5.0 Lite公式発表 |
| @karim_yourself | BytePlus Playgroundでの使い方解説 |

### 中国語圏リソース

| サイト | URL |
|-------|-----|
| 知乎: Seedream 2.0技術解説 | https://zhuanlan.zhihu.com/p/29658716094 |
| 知乎: 即梦4.0完整使用指南 | https://zhuanlan.zhihu.com/p/1949046485430834996 |
| Bilibili: Seedream 4.0深度評測 | https://www.bilibili.com/video/BV1LcHzzrEiB/ |
| Bilibili: 全網最全玩法 | https://www.bilibili.com/video/BV19LWGzPE9k/ |
| Bilibili: Seedream 5.0応用 | https://www.bilibili.com/video/BV1M8c7zSERT/ |
| Bilibili: バッチ生成ツール | https://www.bilibili.com/video/BV1obWwzyEeu/ |
| RAR Design: 即夢AI完整介紹 | https://rar.design/posts/jimeng-ai-dreamina-guide |
| AIBase: Seedream 2.0ニュース | https://www.aibase.com/news/16216 |
| 36Kr: Seedream 5.0リリース | https://eu.36kr.com/en/p/3677025348395653 |

### モデル比較・レビュー

| タイトル | URL |
|---------|-----|
| FLUX vs Seedream vs Midjourney vs GPT vs Gemini | https://imagewise.app/blog/flux-seedream-midjourney-gpt-image-vs-gemini |
| AI Image Model Comparison (Artificial Analysis) | https://artificialanalysis.ai/image/models |
| FLUX 2 vs Seedream比較 (WaveSpeed) | https://wavespeed.ai/blog/en/blog/posts/flux-2-vs-seedream-comparison-2026/ |
| Seedream vs Midjourney (SourceForge) | https://sourceforge.net/software/compare/Midjourney-vs-Seedream/ |
| 5.0 vs Nano Banana 2テキスト比較 (Segmind) | https://blog.segmind.com/seedream-5-0-lite-vs-nano-banana-2-a-text-rendering-showdown-across-7-real-world-use-cases/ |
| Community Review (AllAboutAI) | https://www.allaboutai.com/ai-reviews/seedream/ |
| TechRadar レビュー | https://www.techradar.com/ai-platforms-assistants/tiktok-creators-new-ai-image-generator-is-the-best-ive-ever-seen-and-its-terrifying |

### その他

| サイト | URL |
|-------|-----|
| Product Hunt | https://www.producthunt.com/products/seedream-2-0 |
| Seedance Discord | https://discord.com/invite/zZFUeA8ZQF |
| Doubao完全ガイド (PhotoGrid) | https://www.photogrid.app/blog/what-is-doubao/ |
| Global Times Seedance 2.0 | https://www.globaltimes.cn/page/202602/1355164.shtml |
| Prompt Guide (Scenario.com) | https://www.scenario.com/blog/craft-prompts-gemini-seedream |
| Seedream Evolution (getimg.ai) | https://getimg.ai/blog/guide-to-bytedance-seedream-4-ai-image-model |
