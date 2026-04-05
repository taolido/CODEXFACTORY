# SEEDREAM 2.0 / Seedance 2.0 総合リサーチレポート

> 調査日: 2026-04-05
> 調査範囲: 技術論文・公式リソース・SNSバイラル・How-toガイド・プロンプト技法・ベンチマーク・著作権問題・ツール統合

---

## 重要な前提: 2つの別モデルが混同されている

ByteDance Seedチームの「Seed」ブランドには **画像生成** と **動画生成** の2系統が存在し、SNSでは頻繁に混同されている。

| モデル | 種別 | リリース | プラットフォーム |
|--------|------|----------|-----------------|
| **Seedream 2.0** | 画像生成 (Text-to-Image) | 2024年12月（論文: 2025年3月） | Doubao, Dreamina |
| **Seedance 2.0** | 動画生成 (Text-to-Video) | 2026年2月12日 | Dreamina, CapCut |

SNSで爆発的にバズしたのは主に **Seedance 2.0（動画生成）**。Seedream 2.0（画像生成）は研究論文としての注目が中心。本レポートでは両方を網羅する。

---

## 1. Seedream 2.0 — 技術概要

### 1.1 基本情報

- **開発元**: ByteDance Seed チーム（28名の研究者、リード: Lixue Gong, Weilin Huang）
- **正式名称**: Seedream 2.0: A Native Chinese-English Bilingual Image Generation Foundation Model
- **論文公開日**: 2025年3月10日（arXiv）
- **実サービス統合**: 2024年12月時点で Doubao（豆包）および Dreamina（即梦）に統合済み
- **ユーザー規模**: 1億人以上のC向けユーザーにサービス提供

### 1.2 アーキテクチャ

**Unified Diffusion Transformer (DiT)** ベース。以下の主要コンポーネントで構成:

#### (A) VAE（変分オートエンコーダ）
- 独自開発VAEが画像を潜在空間にエンコード → H x W/4トークンに変換

#### (B) Diffusion Transformer (DiT)
- SD3のMMDiT設計に触発
- 画像トークンとテキストトークンを連結し、**単一のself-attention層**で同時処理
- モダリティごとに個別のMLPを使用
- QK-Normによる学習安定性向上
- Adaptive Layer Normで各attention/MLP層を変調
- Fully Sharded Data Parallel (FSDP) による分散学習

#### (C) テキストエンコーダ（独自LLM）
- CLIP/T5の代わりに**独自開発のDecoder-Only LLM**を採用
- 画像-テキストデータでファインチューニング
- 中国語・英語の両プロンプトをネイティブに理解

#### (D) 文字レベルレンダリング（Glyph-Aligned ByT5）
- ByT5ベースの文字レベルエンコーダがグリフ（字形）エンベディングを生成
- MLPプロジェクションでLLMの特徴空間と整合
- LLMのセマンティック特徴 + ByT5のグリフ特徴を連結してDiTに入力
- 複雑な中国語漢字のレンダリングに特に強い

#### (E) Scaled RoPE（位置エンコーディング）
- 画像解像度に基づくスケールファクター設定
- 画像中心付近のパッチが異なる解像度間で類似の位置IDを共有
- **未学習の解像度・アスペクト比にも汎化可能**

#### (F) 解像度
- ベースモデル: 512px → Refinerモデルで1024pxにアップスケール

### 1.3 学習パイプライン

#### 事前学習データ（4構成要素）
1. **高品質データ**: 鮮明さ・美的魅力・ソース分布に基づいて評価
2. **分布維持データ**: ソースによるダウンサンプリング + クラスタリングベースサンプリング
3. **知識注入データ**: 独自分類体系 + マルチモーダル検索エンジン活用、中国文化固有データ含む
4. **対象補完データ**: アクション指向データ + 反事実データ

#### データクリーニング（3段階）
- Stage 1: 一般品質評価（OCR検出含む）
- Stage 2: 専門的美的スコア、特徴エンベディング抽出、重複排除、クラスタリング
- Stage 3: 階層化キャプション（高品位データほど詳細な記述）

#### キャプションシステム
- **汎用キャプション**: 短縮（核心内容）と長文（詳細記述）
- **専門キャプション**: 芸術的（美的要素）、テキスト（画像内テキスト）、シュール（幻想的要素）

### 1.4 ポストトレーニング（4段階最適化）

1. **継続学習 (CT)**: 手動選別された数百万枚の画像。VMixによる美的次元タグ（色彩、照明、テクスチャ、構図）統合

2. **教師あり微調整 (SFT)**: スタイルラベル+精密な美的ラベル付きデータ。モデル生成画像をネガティブサンプルとして活用。データリサンプリングで美的品質と画像-テキスト整合性のバランス維持

3. **RLHF（人間フィードバックによる強化学習）**:
   - 100万件の多次元プロンプト
   - 3つの報酬モデル: 画像-テキスト整合性 / 美的品質 / テキストレンダリング
   - REFLパラダイムに類似した直接最適化
   - 反復的改善: 拡散最適化 → 選好アノテーション → 報酬モデル更新の3段サイクル

4. **プロンプトエンジニアリング (PE)**: ファインチューニング済みLLMがユーザープロンプトを自動最適化。**美的品質30%向上、画像-テキスト整合性5%改善**

5. **TSCD蒸留**: 階層的リファインメント戦略でセグメント数を k=16 → k=1 へ段階的削減。推論効率の大幅改善

---

## 2. ベンチマーク・競合比較

### 2.1 人間評価（Bench-240: 240のバイリンガルプロンプト）

| 指標 | Seedream 2.0 の順位 | 比較対象 |
|------|-------------------|---------|
| ELO スコア（英語） | **最高** | Flux, SD3.5, GPT-4o, Midjourney v6.1, Ideogram 2.0 |
| ELO スコア（中国語） | **最高** | Kolors 1.5, MiracleVision 5.0, Hunyuan |
| 構造的正確性 | **1位** | 全比較モデル中 |
| 画像-テキスト整合性 | **2位** | 全比較モデル中 |
| 美的性能 | **2位** | 全比較モデル中 |

### 2.2 自動評価メトリクス

| メトリクス | Seedream 2.0 | FLUX 1.1 Pro | Midjourney v6.1 | GPT-4o | Ideogram 2.0 |
|-----------|-------------|-------------|----------------|--------|-------------|
| EvalMuse total | **0.682（最高）** | - | - | - | - |
| VQAScore | 0.8031 | 0.7877 | 0.7569 | 0.7974 | 0.8226 |
| HPSv2 | **0.2994（最高）** | 0.2946 | 0.2850 | - | 0.2932 |
| MPS | 13.61 | - | - | - | - |

### 2.3 テキストレンダリング性能

**中国語テキスト（180プロンプトベンチマーク）:**
- テキスト精度: **78%**
- テキストヒット率: **82%**
- 比較: MiracleVision 5.0は65%精度

**英語テキスト:**
- RecraftV3、Ideogram 2.0、Fluxと競争力のある精度とヒット率

### 2.4 中国文化特性評価（350プロンプト）
- 5カテゴリ: 伝統衣装、食文化、建築、工芸、祭り
- **全次元で競合モデルを大幅に上回る**
- モンゴル族と中国チベット族のローブの微妙な違いなど、文化的細部の区別に優れる

### 2.5 競合との位置づけ総括

| 能力 | Seedream 2.0 の強み |
|------|-------------------|
| バイリンガル対応 | 中英両語でネイティブ理解（他モデルは英語偏重） |
| テキストレンダリング | 中国語テキスト描画で圧倒的優位 |
| 文化理解 | 中国文化のニュアンス理解で独壇場 |
| プロンプト追従 | EvalMuse最高スコア |
| 画像品質 | HPSv2最高スコア |
| コスト効率 | 後続バージョンでMidjourney比大幅に安価 |

### 2.6 弱点・留意点
- オープンソースではないため、LoRA・ファインチューニング不可
- フォトリアリズムではFlux 2 ProやImagen 4が上位（2026年時点）
- アーティスティックスタイルではMidjourneyがリーダー
- 解像度はベース512→Refiner 1024で、後継（4.5で4K対応）と比較して低い
- リリース後、ユーザートラフィックが67.4%減少（後継モデル移行のため）

---

## 3. アクセス方法・料金

### 3.1 Seedream 2.0 はオープンソースか？

**NO。** モデル重みは非公開。ダウンロードして手元で実行することは不可。論文のみ公開（CC BY 4.0）。

### 3.2 直接アクセス手段

| プラットフォーム | URL | 備考 |
|---------------|-----|------|
| Doubao（豆包） | https://www.doubao.com/chat/create-image | 1日約5回無料。中国国外はVPN必要 |
| Dreamina（即梦・国際版） | https://dreamina.capcut.com | Google/TikTok/Facebook/CapCut/メールで登録 |
| Jimeng（即梦・中国版） | https://jimeng.jianying.com/ai-tool/image/generate | Douyinアカウントでログイン |

### 3.3 サードパーティAPIプロバイダ（後続バージョン）

| プロバイダ | モデル | 料金 |
|-----------|-------|------|
| Atlas Cloud | Seedream 4.5 | $0.036/画像 |
| WaveSpeedAI | Seedream 4.5/5.0 | API料金制 |
| Replicate | Seedream 4 | bytedance/seedream-4 |
| BytePlus（公式海外版） | Seedream 4.0-5.0 Lite | $0.03-0.045/画像 |
| VisualGPT | Seedream 4.0/5.0 | 無料オプションあり |

### 3.4 Seedreamファミリー現行料金

| モデル | 料金/画像 | 無料枠 |
|-------|----------|-------|
| Seedream 4.0 | $0.03 | 200枚 |
| Seedream 4.5 | $0.035-0.045 | 200枚 |
| Seedream 5.0 Lite | $0.035 | 200枚 |

---

## 4. Seedreamモデルファミリーの系譜

| バージョン | 時期 | 主な進化 |
|-----------|------|---------|
| 初期バージョン | ~2024 | 中国語テキスト配置と構造化レイアウト生成に特化 |
| **Seedream 2.0** | 2024年12月 | バイリンガル基盤モデル、RLHF、Glyph-Aligned ByT5 |
| Seedream 3.0 | 2025年4月 | グローバル競争力を持つ最初のバージョン。高速化、スタイル多様化 |
| SeedEdit 3.0 | 2025年6月 | 画像編集特化モデル |
| Seedream 4.0 | 2025年9月 | 画像生成+画像編集の統合アーキテクチャ、ID一貫性 |
| Seedream 4.5 | 2025年後半 | 4K出力、テクスチャ・ライティング改善、マルチサブジェクト対応 |
| Seedream 5.0 / 5.0 Lite | 2026年2月 | Web検索連携生成、深層思考能力、マルチターン編集 |

### ByteDance/TikTokとの関連
- **Seedチーム**: ByteDanceのAI研究チーム（2023年設立）
- **Doubao（豆包）**: ByteDanceのAIアシスタントプラットフォーム
- **Dreamina（即梦）**: クリエイティブAIプラットフォーム（海外版）
- **CapCut**: TikTok系動画編集アプリ（Seedance 2.0統合済み）
- **BytePlus**: ByteDanceのエンタープライズ向けクラウドサービス

---

## 5. Seedance 2.0 — 動画生成モデル

### 5.1 基本スペック

| 項目 | 仕様 |
|------|------|
| リリース日 | 2026年2月12日 |
| 解像度 | ネイティブ2K（2048x1080） |
| 動画長 | 5-12秒 |
| FPS | 30FPS前後 |
| 入力モダリティ | テキスト + 画像(最大9枚) + 動画(最大3本) + 音声(最大3トラック) |
| 速度 | 1.5 Pro比30%高速化 |
| プラットフォーム | Dreamina, CapCut |

### 5.2 @タグ参照システム（Seedance 2.0独自の武器）

最大12ファイルをアップロードし、プロンプト内で参照可能:
- `@Image1` ~ `@Image9`
- `@Video1` ~ `@Video3`
- `@Audio1` ~ `@Audio3`

これが他のAI動画ツールとの最大の差別化ポイント。

### 5.3 Seedanceファミリー

| バージョン | 主な特徴 |
|-----------|---------|
| Seedance 1.0 | text-to-video、image-to-video、マルチショット、1080p |
| Seedance 1.5 Pro | ネイティブ音声・映像同時生成、多言語リップシンク |
| **Seedance 2.0** | 4モーダル入力、ネイティブ2K、大幅高速化 |

---

## 6. SNSバイラル・著名投稿

### 6.1 世界的に最もバズった投稿

#### トム・クルーズ vs ブラッド・ピット格闘動画
- **作者**: Ruairi Robinson（アイルランドの映画監督）
- **内容**: たった2行のプロンプトで生成した屋上格闘シーン
- **反響**: X上で **160万回以上の再生**
- 全米主要メディア（Variety, Hollywood Reporter, Deadline）が一斉報道

#### 主要なバイラル投稿者

| 投稿者 | 内容 | リンク |
|--------|------|--------|
| @HashemGhaili (Hashem Al-Ghaili) | 「Chaos」— 30分でText-to-Videoだけで制作。「VFXのゲームチェンジャー」 | https://x.com/HashemGhaili/status/2022364200295645336 |
| @minchoi (Min Choi) | 1分のシネマティック動画を5分で生成（15秒x4ショット） | https://x.com/minchoi/status/2020989515939148146 |
| @dreamina_ai (Dreamina公式) | Seedance 2.0 + Seedream 5.0 Lite正式公開告知 | https://x.com/dreamina_ai/status/2036292154671374493 |
| @saasjunctionhq | 「2026 is the year of Hollywood level AI Movies」 | Threads |

### 6.2 バイラルになった動画例

| 内容 | 作者 | 反響 |
|------|------|------|
| トム・クルーズ vs ブラッド・ピット格闘 | Ruairi Robinson | 160万再生、全米メディア報道 |
| Game of Thronesの別エンディング | 不明 | MPAが名指しで批判 |
| ロッキー・バルボア & オプティマスプライム (ファストフード店) | 不明 | MPA報告で言及 |
| Friends (キャラをカワウソに変換) | 不明 | SNSでバイラル |
| ウィル・スミス vs 赤目スパゲッティモンスター | 不明 | SNSでバイラル |
| 高市首相 vs ウルトラマン | 不明 | 日本政府が問題視 |
| 孫悟空 vs ドラえもん | 不明 | 日本の著作権調査の契機 |

### 6.3 日本語圏でのバズ

- X/TikTokで日本のIPキャラ（ウルトラマン、名探偵コナン、ドラゴンボールの孫悟空、ドラえもん、フリーレン等）の無断生成動画が大量出現
- 「高市首相 vs ウルトラマン」の動画が特に物議
- ITmedia、映画.com、テクノエッジなど主要メディアが一斉報道

### 6.4 コミュニティの反応

#### 肯定的
- 「AIだと言われなければ、どの俳優が演じたか考え込むレベル」
- 「過去はハリウッド映画に数百万ドル必要だったが、今は1人と電気代だけで可能」
- Hashem Al-Ghaili: 「VFXの真のゲームチェンジャー」
- Elon Muskも注目（中国でDeepSeekに匹敵すると比較）

#### 否定的・批判
- **Rhett Reese**（Deadpool脚本家）: 「残念ながら我々にとっては終わりだ」
- **SAG-AFTRA**（俳優組合）: 「著作権者の声と肖像の無断使用は容認できない」
- **MPA**（米映画協会）: 「公開1日で大規模な著作権侵害が発生した」
- 2026年3月下旬には「初期のhypeに見合わない」という冷静な評価も。テキスト描画の崩壊、背景の低品質、物理法則の不正確さ等の問題が報告

---

## 7. 著作権問題の時系列

| 日付 | 出来事 |
|------|--------|
| 2026/2/12 | Seedance 2.0リリース |
| 2026/2/13-14 | トム・クルーズ vs ブラッド・ピット動画がバイラル化 |
| 2026/2/14 | MPA（米映画協会）が「大規模著作権侵害」と非難 |
| 2026/2/14-15 | SAG-AFTRA（俳優組合）が「露骨な侵害」と声明 |
| 2026/2/15 | ディズニーがByteDanceに是正要求書送付 |
| 2026/2/16 | 日本のアニメIP無断利用 → 業界団体がTikTokに問い合わせ |
| 2026/2/16 | 日本政府（小野田紀美AI担当大臣）が「看過できない」と声明 |
| 2026/2月中旬 | ByteDanceが実在人物の顔写真入力機能を制限 |
| 2026/3/15 | グローバル展開一時停止 |
| 2026/3/26 | CapCutにSeedance 2.0統合（TechCrunch報道） |

---

## 8. プロンプトエンジニアリング（実践ガイド）

### 8.1 Seedance 2.0 公式プロンプト6ステップフォーミュラ

```
[被写体] + [アクション] + [環境] + [カメラ] + [スタイル] + [制約]
```

**具体例:**
```
A young woman in a white dress, slowly turns around with breeze blowing the skirt,
in a seaside at dusk with golden glow, camera slow push-in, cinematic film tone 35mm,
avoid jitter and bent limbs
```

**最適な文字数:** 60-100語

### 8.2 8種類のカメラムーブメント

1. Push-in / Dolly in（寄り）
2. Pull-out / Dolly out（引き）
3. Pan / Lateral motion（パン）
4. Tracking shot（追従）
5. Orbit / Arc（周回）
6. Aerial / Drone shot（空撮）
7. Handheld（手持ち風）
8. Fixed / Locked-off（固定）

**鉄則: カメラ指示は1シーンにつき1つだけ**

### 8.3 絶対やってはいけないこと

- 「**fast**」は品質劣化の最大原因。高速カメラ移動+高速カット+複雑なシーンの組み合わせ → ジッター・アーティファクト確実発生
- カメラの動きと被写体の動きを混同しない
- 「amazing」「beautiful」等の曖昧な形容詞は効果なし
- fps、f値等の技術パラメータ指定は無意味（リズムの描写で代替）
- 複数のカメラ指示を同時に入れない
- ネガティブプロンプトは非サポート → ポジティブな制約文で記述

### 8.4 最も効果的なテクニック

- **ライティング描写が最高のレバレッジ**: 形容詞10個追加 < ライティング1つ追加
- **実在のリファレンス**: 「Apple keynote style」「Wes Anderson symmetry」のように実在の参照 → 一貫性が劇的向上
- **タイムスタンプ制御**: 複数ビートのシーンでタイムスタンプ指定 → ペーシングを精密制御
- **品質サフィックス**: "4K, Ultra HD, Rich details, Sharp clarity, Cinematic texture"等

### 8.5 Seedream（画像生成）のプロンプトTips

- 推奨フォーマット: 被写体 + シーン/雰囲気 + アクション + カメラ + スタイル/ライティング
- 中国語・英語どちらもネイティブ処理（バイリンガル設計）
- 中国語テキストレンダリング: 書道・方言・技術用語を理解する専用データセットで訓練済み
- 1つのプロンプトに1つの主動作（複数の動作動詞は混乱の原因）

---

## 9. ツール統合・ワークフロー

### 9.1 ComfyUI統合

| リポジトリ | 内容 |
|-----------|------|
| [ComfyUI-Seedream-API](https://github.com/JiangAogo/ComfyUI-Seedream-API) | Volcano Engine API経由。5.0 Lite含む |
| [ComfyUI-Seedream4_Replicate](https://github.com/Saganaki22/ComfyUI-Seedream4_Replicate) | Replicate API経由のSeedream 4 |
| [ComfyUI-Seed-API](https://github.com/FloyoAI/ComfyUI-Seed-API) | BytePlus基盤モデル統合 |
| [ComfyUI公式パートナーノード](https://blog.comfy.org/p/seedream-40-now-available-in-comfyui) | Seedream 4.0のネイティブ統合 |

### 9.2 API

| プロバイダ | エンドポイント | 備考 |
|-----------|-------------|------|
| BytePlus（海外向け） | `console.byteplus.com` | `/v1/images/generations` |
| Volcengine（国内企業向け） | - | エンタープライズSLA、中国語サポート |
| Replicate | `replicate.com/bytedance/seedream-4` | 従量課金 |
| OpenRouter | `openrouter.ai/bytedance-seed/seedream-4.5` | 統合API |

### 9.3 SeedEdit（画像編集）

Seedream 2.0は**SeedEdit**という命令ベースの画像編集モデルに適応可能:
- テキスト指示による画像の部分編集
- スタイル変換
- 顔IDの保持
- 後続のSeedEdit 3.0では顔認識ロスの導入で顔の類似性保持が大幅改善

---

## 10. How-toガイド・チュートリアル一覧

### 10.1 日本語

| 著者 | タイトル | URL |
|------|---------|-----|
| いにしえ@AIクリエイター | Seedance 2.0 究極ガイド | https://note.com/old_pgmrs_will/n/n442174cf60ed |
| lisa | ByteDance Seedance 2.0 チュートリアル | https://note.com/easy_gnu5311/n/nd35e2cb18471 |
| dallen | Seedance 2.0：初めてのAI動画を作る方法 | https://note.com/dallen/n/n76674814b2f6 |
| AIで何でもできると勘違いして解決する部 | 実際に試した解説 | https://note.com/ai_jissennkai/n/nd9eb4bee1337 |
| hirokaji | Seedream特化! 画像プロンプト攻略ガイド | https://note.com/tasty_dunlin998/n/n5472617b9feb |
| リダ / Lida | Seedream4.0 プロンプトガイド + ComfyUI | https://note.com/seal309midorin/n/n4cd3147d4c6d |
| WEEL | Seedance 2.0とは？技術解説 | https://weel.co.jp/media/tech/seedance-2-0/ |
| 株式会社Uravation | 無料でAI動画を作る手順と料金 | https://uravation.com/media/seedance-20-video-ai-guide/ |
| AQUA テックブログ | 「Sora超え」と話題の完全ガイド | https://www.aquallc.jp/seedance-2-complete-guide/ |
| videoweb.ai | 動画生成ガイド完全解説版 | https://videoweb.ai/ja/blog/detail/Seedance-2-0-Video-Generation-Guide-Tutorial-Prompts-578fb91b8f46/ |
| Dreamina公式（日本語） | Seedance 2.0の使い方 | https://dreamina.capcut.com/ja-jp/resource/how-to-use-seedance-2-0 |
| 生成AIビジネス活用研究所 | Seedream Edit完全攻略ガイド | https://gai.workstyle-evolution.co.jp/2025/10/04/seedream-edit-complete-guide/ |

### 10.2 英語

| 著者/メディア | タイトル | URL |
|-------------|---------|-----|
| WaveSpeedAI Blog | Seedream 4.0-5.0 Complete Tutorial | https://wavespeed.ai/blog/posts/seedream-4-0-to-5-0-complete-tutorial-image-generation-editing/ |
| Medium (Cliprise) | Complete Tutorial for ByteDance's Multimodal AI Video Model | https://medium.com/@cliprise/seedance-2-0-guide-the-complete-tutorial-for-bytedances-multimodal-ai-video-model-2026-fbad74a8c6f9 |
| Freepik Blog | How to write prompts for Seedance 2.0 | https://www.freepik.com/blog/how-to-write-prompts-for-seedance-2-0/ |
| No Film School | 映画制作者視点のレビュー | https://nofilmschool.com/seedance-2-0-ai-video-model |
| Dreamina公式 | 18 Powerful Prompts | https://dreamina.capcut.com/resource/seedance-2-0-prompt |
| BytePlus公式 | プロンプトガイド | https://docs.byteplus.com/en/docs/ModelArk/1829186 |
| Atlabs | Seedream 4.0 Prompting Guide | https://www.atlabs.ai/blog/seedream4o-prompting-guide |

### 10.3 GitHubプロンプト集

| リポジトリ | 内容 |
|-----------|------|
| [awesome-seedance](https://github.com/ZeroLu/awesome-seedance) | シネマティック/アニメ/UGC/広告/ミーム向け500+プロンプト |
| [awesome-seedance-2-prompts](https://github.com/YouMind-OpenLab/awesome-seedance-2-prompts) | 500+プロンプト + APIガイド |

---

## 11. 活用ジャンル

- **シネマティック映像**: ハリウッド映画レベルのVFXシーンをテキストだけで生成
- **商品プロモーション/広告**: UGCスタイルのインフルエンサー風動画を自動生成
- **アニメ/マンガ**: キャラクター一貫性テスト、ダイナミックアクションシーケンス
- **ミーム/バイラルコンテンツ**: 超現実的な要素（巨大猫シナリオなど）
- **ショートドラマ/Webシリーズ**: ナラティブ駆動コンテンツ
- **中国語テキスト入り画像**: ポスター、バナー、書道風画像

---

## 12. 公式リソース一覧

| リソース | URL |
|---------|-----|
| arXiv論文 | https://arxiv.org/abs/2503.07703 |
| arXiv HTML版 | https://arxiv.org/html/2503.07703v1 |
| HuggingFace Paper | https://huggingface.co/papers/2503.07703 |
| ByteDance Seed公式 | https://seed.bytedance.com/en/models |
| Semantic Scholar | https://www.semanticscholar.org/paper/fd60d01f49e3afaebac44bbd8ea89551e5a7418b |
| Seedream 3.0論文 | https://arxiv.org/abs/2504.11346 |
| Seedream 4.0公式 | https://seed.bytedance.com/en/seedream4_0 |
| Seedream 4.5公式 | https://seed.bytedance.com/en/seedream4_5 |
| Dreamina（国際版） | https://dreamina.capcut.com |
| BytePlus Seedream | https://www.byteplus.com/en/product/Seedream |
| Product Hunt | https://www.producthunt.com/products/seedream-2-0 |

---

## 13. 報道リソース一覧

| メディア | 記事 | URL |
|---------|------|-----|
| Variety | MPA Denounces Seedance 2.0 | https://variety.com/2026/film/news/motion-picture-association-ai-seedance-bytedance-tom-cruise-1236661753/ |
| Hollywood Reporter | Seedance 2.0 Sparks Hollywood Backlash | https://www.hollywoodreporter.com/business/business-news/seedance-2-0-sparks-hollywood-backlash-1236505120/ |
| Deadline | Cruise Vs Pitt Deepfake | https://deadline.com/2026/02/cruise-vs-pitt-seedance-viral-ai-hollywood-videos-1236717127/ |
| TechCrunch | Seedance 2.0 comes to CapCut | https://techcrunch.com/2026/03/26/bytedances-new-ai-video-generation-model-dreamina-seedance-2-0-comes-to-capcut/ |
| テクノエッジ | Seedance 2.0旋風 | https://www.techno-edge.net/article/2026/02/16/4868.html |
| ITmedia | AI「Seedance 2.0」で日本のアニメ無断利用 | https://www.itmedia.co.jp/aiplus/articles/2602/16/news065.html |
| 映画.com | 米映画業界一斉非難 | https://eiga.com/news/20260216/11/ |
| CineD | Viral AI Fight Triggers Hollywood Backlash | https://www.cined.com/viral-ai-fight-between-tom-cruise-and-brad-pitt-triggers-hollywood-wide-backlash-against-bytedances-seedance-2-0/ |
| No Film School | Seedance 2.0 Review | https://nofilmschool.com/seedance-2-0-ai-video-model |

---

## 14. 現時点での総括

**Seedream 2.0**（画像生成）は2024年12月リリース時点では最先端だったが、2026年4月現在では4世代後の後継（Seedream 5.0 Lite）が存在する。実用目的なら現行のSeedream 4.5/5.0 Liteが合理的。歴史的意義としては、バイリンガルLLMテキストエンコーダとGlyph-Aligned ByT5による中国語テキストレンダリングの革新が後続バージョンすべての基盤技術となった。

**Seedance 2.0**（動画生成）が2026年2月にSNSで爆発的にバズした本命。ハリウッド俳優のディープフェイク動画やアニメIPの無断生成が世界的な著作権論争を引き起こし、主要メディアで一斉報道された。技術的には@タグ参照システムとマルチモーダル入力が革新的だが、著作権問題により2026年3月15日にグローバル展開は一時停止中（3月26日にCapCut統合は進行）。
