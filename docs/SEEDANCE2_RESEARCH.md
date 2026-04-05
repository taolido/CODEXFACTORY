# SEEDANCE 2.0 総合リサーチレポート

> リサーチ日: 2026-04-05
> 情報源: arXiv論文、公式サイト、X(Twitter)、Bilibili、知乎、Reddit、YouTube、Hacker News、Hollywood Reporter、各種テックブログ

---

## 1. Seedance 2.0とは何か

ByteDance Seedチームが2026年2月8日にリリースした次世代AI動画生成モデル。「デジタル映画監督」の異名を持つ。

業界初の3つの特徴:
- ネイティブ音声映像同時生成（後処理ではない）
- 単一プロンプトからのマルチショットストーリーテリング
- 8言語以上の音素レベルリップシンク

CCTV春節晩会で世界初の大規模実用デモ、**6億7700万人以上**が視聴。AI短編ドラマ「霍去病」が**5億再生**突破。

---

## 2. 技術アーキテクチャ

### Dual-Branch DiT

- **DiTブランチ（空間生成）**: テクスチャ、ライティング、ディテール
- **RayFlow（Rectified Flow Transformer）ブランチ（時間的整合性）**: モーション、物理挙動、トランジション
- **Attention Bridge**: 視覚ブランチとオーディオブランチ間でミリ秒レベルのメタデータ受け渡し

### パラメータ・推論要件

- フルモデル: 96GB以上のVRAM必要
- オープンソース軽量版「Alive」: 120億パラメータ、RTX 3090/4090（24GB VRAM）で動作

### マルチモーダル入力仕様

| 入力タイプ | 最大数 | 備考 |
|-----------|-------|------|
| 画像 | 9枚 | キャラクター参照、シーン設定 |
| 動画クリップ | 3本 | 各最大15秒、モーション/カメラ参照 |
| 音声クリップ | 3本 | 各最大15秒、リズム同期 |
| テキストプロンプト | 1 | 自然言語指示 |
| **合計** | **最大12** | @メンション方式で参照指定 |

### 出力仕様

| 項目 | 仕様 |
|------|------|
| 動画長 | 4〜15秒（単一生成）、最大約20秒 |
| 解像度 | 最大720p（API）、最大2K（プロダクション） |
| アスペクト比 | 16:9, 9:16, 4:3, 3:4, 21:9, 1:1 |
| 音声 | ネイティブ同時生成（効果音+BGM+セリフ） |

### ネイティブ音声生成

動画と音声を**ジョイントディフュージョン**で同時生成:
- セリフ（精密リップシンク、多言語対応）
- 環境音（空間特性に合致）
- 効果音（フレーム単位で映像同期）
- BGM（感情ビートに反応）

### 物理シミュレーション

物理的に不自然なモーションにペナルティを課す学習目標。重力、布ドレープ、流体、オブジェクトインタラクションを説得力ある形で生成。

---

## 3. バージョン進化

| バージョン | 時期 | 主な特徴 |
|-----------|------|---------|
| **1.0** | 2025年6月 | テキスト/画像→動画、1080p/41.4秒、約10倍推論高速化 |
| **1.5 Pro** | 2025年12月 | ネイティブ音声導入、DB-DiT（45億パラメータ）、クロスモーダルジョイント |
| **2.0** | 2026年2月 | 統一マルチモーダル、4種入力同時、2K解像度、30%高速化、ディレクターレベル制御 |

### 1.5→2.0の主要進化

1. **入力**: 個別パイプライン → 4種マルチモーダル統合
2. **音声**: 後付け（2倍コスト） → ネイティブ同時生成
3. **音声精度**: 大まかなイベント同期 → 布の擦れ音レベルまで表現
4. **モーション**: 複雑インタラクションで破綻 → フィギュアスケートのジャンプ・リフトも処理
5. **マルチショット**: 単一ショット → ショット間一貫性を維持した物語生成

---

## 4. アクセス方法・使い方

### Dreamina経由（ステップバイステップ）

1. https://dreamina.capcut.com にアクセス
2. Google/TikTok/Facebook等でサインアップ
3. 「AI Video」→「Seedance 2.0」を選択
4. 入力モードを選択:
   - **首尾フレームモード**: 最初（+最後）のフレーム画像+テキスト
   - **全能参照モード**: 画像+動画+音声を組み合わせ（最大12ファイル）
5. `@Image1`, `@Video1`, `@Audio1` タグを使った構造化プロンプトを記述
6. 出力設定（動画尺4-15秒、解像度、アスペクト比）
7. 「Generate」→ プレビュー → ダウンロード

### API経由

**公式APIは著作権紛争により一般公開停止中**（2026年4月時点）

サードパーティ経由でアクセス可能:
- **muapi.ai**: T2V/I2Vエンドポイント
- **fal.ai**: APIホスティング
- **PiAPI**: Dreamina経由API
- **BytePlus ModelArk**: 新規200万無料トークン

### ComfyUI連携

- **seedance2-comfyui** (Anil-matcha): muapi.ai経由
- **seedance_2_Comfy_UI_Node** (Cameraptor): Sjinn.ai経由
- **muapi-comfyui** (SamurAIGPT): 100+モデル対応汎用ノード

### CapCut統合（2026年3月〜）

CapCut内「Media」→「AI Media」→「AI Video」からアクセス。
初期展開: ブラジル、インドネシア、マレーシア、メキシコ、フィリピン、タイ、ベトナム

---

## 5. 料金体系

### 即梦/Jimeng（中国）

| プラン | 料金 |
|-------|------|
| 無料 | 毎日約260クレジット |
| 有料 | 69 RMB/月〜（約1,350円〜） |
| お試し | 1元で7日間トライアル |

### Dreamina（海外）

| プラン | 料金 | 内容 |
|-------|------|------|
| 無料 | $0 | 毎日60+クレジット |
| 有料 | $18〜84/月 | クレジットベース |

10秒720p動画 ≒ 1,880クレジット（約$1.91〜$4.60/本）

---

## 6. プロンプトエンジニアリング

### 6ステップ・フォーミュラ

```
[カメラ/ショット] + [被写体] + [アクション/動き] + [環境] + [照明] + [スタイル/ムード]
```

### 重要ルール

| ルール | 詳細 |
|-------|------|
| 文字数 | 30-200語が最適 |
| 1ショット1動詞 | 動作動詞は1つだけ |
| 人物数 | 1-2人に制限 |
| ネガティブプロンプト | **非対応** |
| 最重要要素 | **照明記述** |
| **禁句** | **"Fast"は最も品質を劣化させるキーワード** |

### カメラ記述のコツ

```
悪い例: "Dolly zoom, 35mm lens"
良い例: "The camera slowly drifts forward, closing the distance between the viewer and the subject"
```

### マルチショット・タイムスタンプ構造

```
[00:00] Wide establishing shot: A fog-covered mountain pass at dawn,
        golden light breaking through clouds
[00:04] Medium shot: @Character1 emerges from the mist, determined expression,
        camera slowly tracks right
[00:07] Close-up: Hands gripping a weathered map, rain droplets falling
```

### キャラクター一貫性

- リファレンス画像は**最大3枚**（正面+3/4角度+横顔）
- 6枚→2枚に絞ることでドリフト約60%減少
- キャラクター説明を**一字一句同じ**に使い回す → 95%以上の顔一貫性

### オーディオ同期

- クリアで高品質な音声を使用
- 会話ペースの音声が最適
- 長フレーズ間にマイクロポーズを入れるとリップアラインメント向上

---

## 7. 競合比較

### Artificial Analysis リーダーボード

**Text-to-Video Arena:**

| 順位 | モデル | Elo |
|-----|-------|-----|
| 1 | **Seedance 2.0 720p** | **1273** |
| 2 | SkyReels V4 | 1245 |
| 3 | PixVerse V6 | 1242 |
| 4 | Kling 3.0 1080p | 1241 |

**Image-to-Video Arena:**

| 順位 | モデル | Elo |
|-----|-------|-----|
| 1 | **Seedance 2.0 720p** | **1356** |
| 2 | PixVerse V6 | 1344 |
| 3 | grok-imagine-video | 1334 |

### 用途別比較

| モデル | 強み | 弱み |
|-------|------|------|
| **Seedance 2.0** | 構造制御、ネイティブ音声、マルチモーダル参照 | 720p制限、海外API停止 |
| **Sora 2** | 物理リアリズム、長尺物語整合性 | ChatGPT依存 |
| **Kling 3.0** | 人体モーション、4K60fps、最速生成 | マルチモーダル柔軟性低 |
| **Runway Gen-4.5** | シネマティック色彩、Motion Brush | 構造制御で劣る |

---

## 8. SNS・コミュニティの反応

### X (Twitter) バイラル投稿

| 投稿者 | 内容 |
|-------|------|
| **@minchoi** | 「Seedance 2.0 broke the Internet in China overnight. 10 wild examples」大拡散 |
| **@deedydas** | 「Most advanced video generation model in the world. Drastic step up from Veo 3.1/Sora 2」 |
| **@AngryTomtweets** | 「AI made this in 20 seconds. Basically a film studio in your pocket」 |

### 著名人の反応

| 人物 | 発言 |
|------|------|
| **Elon Musk** | 「It's happening fast」 |
| **Rhett Reese**（Deadpool脚本家） | 「I hate to say it. It's likely over for us」 |
| **馮驥**（黒神話悟空CEO） | 「地表最強のビデオモデル」「AGCの幼少期は終わった」 |
| **賈樟柯**（映画監督） | Seedance 2.0で短編映画を3日で制作 |

### バイラル映像

- Tom Cruise vs Brad Pitt 格闘シーン（最も拡散）
- Avengers: Endgame リミックス
- Optimus Prime vs Godzilla
- Ye & Kim Kardashian 中国宮廷ドラマ
- Game of Thrones 別エンディング

### Bilibili

- 「全30集保姆級教程」マルチ主体制御、微表情制御の30エピソード
- 「30個用法案例実測+完整提示詞大公開」30ケーステスト
- 「360度全景図控制法」独自手法+ソースコード共有
- 「10集変現9.9万」10エピソードで約200万円収益化ガイド
- ローカルデプロイによる検閲回避方法

### ハリウッド著作権紛争

MPA、Disney、Warner Bros、Paramount、Netflix、Sony、SAG-AFTRAが排除措置命令。ByteDanceは実在人物参照機能を停止、2026年3月15日に海外APIローンチを一時停止。

---

## 9. 商用利用・ライセンス

- 有料プランに商用ライセンス含む
- 全生成コンテンツにAI生成不可視ウォーターマーク埋め込み
- 新規契約チーム: 約100万元（約2,000万円）の保証金が必要との情報

---

## 10. 制限事項

- **著作権問題**: 海外APIローンチ一時停止中
- **解像度**: 720pでは群衆ディテールほぼゼロ
- **微表情**: 繊細な人間の感情表現は弱い
- **検閲**: AI生成架空キャラまでブロックする過剰検閲
- **海外アクセス**: 中国携帯番号認証必須（一部サードパーティルートあり）
- **待ち時間**: 海外ユーザーは5秒480p動画に6-8時間待ちの報告

---

## 11. Seaweedとの関係

- **Seaweed（Seed-Video）**: 約70億パラメータの動画生成基盤研究モデル、1000台H100 GPU相当で学習
- **Seedance**: Seaweedの研究基盤上に構築された消費者向け・プロダクション向けモデル

---

## 12. 論文

| 論文 | arXiv ID |
|------|---------|
| Seedance 1.0 Technical Report | 2506.09113 |
| Seedance 1.5 Pro Technical Report | 2512.13507 |
| Seaweed-7B Technical Report | 2504.08685 |
| **Seedance 2.0 論文は未公開** | - |

---

## 13. 参考リンク集

### 公式
- ByteDance Seed: https://seed.bytedance.com/en/seedance2_0
- Dreamina: https://dreamina.capcut.com/tools/seedance-2-0
- Seaweed: https://seaweed.video/

### 日本語チュートリアル
- Dreamina公式(日本語): https://dreamina.capcut.com/ja-jp/resource/how-to-use-seedance-2-0
- WEEL解説: https://weel.co.jp/media/tech/seedance-2-0/
- videoweb.ai: https://videoweb.ai/ja/blog/detail/Seedance-2-0-Video-Generation-Guide-Tutorial-Prompts-578fb91b8f46/
- Uravation: https://uravation.com/media/seedance-20-video-ai-guide/
- LumeFlow: https://www.lumeflow.ai/jp/ai-tools/seedance-2-guide/
- note.com究極ガイド: https://note.com/old_pgmrs_will/n/n442174cf60ed

### 英語チュートリアル
- Curious Refuge: https://curiousrefuge.com/blog/how-to-use-seedance-2-omni
- WaveSpeed完全ガイド: https://wavespeed.ai/blog/posts/seedance-2-0-complete-guide-multimodal-video-creation/
- WaveSpeedキャラクター一貫性: https://wavespeed.ai/blog/posts/blog-character-consistency-seedance-2-0/
- Seedance.tvプロンプトガイド50+例: https://www.seedance.tv/blog/seedance-2-0-prompt-guide
- GamsGo: https://www.gamsgo.com/blog/how-to-use-seedance
- Cutout.proワークフロー: https://www.cutout.pro/learn/blog-seedance-2-0-complete-workflow/
- Apiyi 5つの使い方: https://help.apiyi.com/en/seedance-2-how-to-use-guide-en.html
- Freepikプロンプト: https://www.freepik.com/blog/how-to-write-prompts-for-seedance-2-0/

### GitHub
- awesome-seedance-2-prompts (500+): https://github.com/YouMind-OpenLab/awesome-seedance-2-prompts
- awesome-seedance: https://github.com/ZeroLu/awesome-seedance
- seedance2.0-how-to: https://github.com/ZeroLu/seedance2.0-how-to
- Seedance-2.0-API: https://github.com/Anil-matcha/Seedance-2.0-API
- seedance2-comfyui: https://github.com/Anil-matcha/seedance2-comfyui

### 中国語
- CSDN手冊: https://blog.csdn.net/seoread/article/details/157937583
- 知乎実操教程: https://zhuanlan.zhihu.com/p/2004523300588643639
- 知乎餵飯教程: https://zhuanlan.zhihu.com/p/2004623893273519265
- Bilibili 30集チュートリアル: https://www.bilibili.com/video/BV1gEfcBKEYR/
- Bilibili 30ケーステスト: https://www.bilibili.com/video/BV1gCcqzkEe7/
- Bilibili 360度パノラマ: https://www.bilibili.com/video/BV1C7QoBZEEk/

### ニュース・レビュー
- TechCrunch CapCut統合: https://techcrunch.com/2026/03/26/bytedances-new-ai-video-generation-model-dreamina-seedance-2-0-comes-to-capcut/
- TechCrunch Hollywood反応: https://techcrunch.com/2026/02/15/hollywood-isnt-happy-about-the-new-seedance-2-0-video-generator/
- Variety MPA声明: https://variety.com/2026/film/news/motion-picture-association-ai-seedance-bytedance-tom-cruise-1236661753/
- Hollywood Reporter: https://www.hollywoodreporter.com/business/business-news/seedance-2-0-sparks-hollywood-backlash-1236505120/
- CNN: https://www.cnn.com/2026/02/20/china/china-ai-seedance-intl-hnk-dst
- Curious Refugeレビュー(8.26/10): https://curiousrefuge.com/blog/seedance-2-review
- Variety 賈樟柯短編: https://variety.com/2026/digital/news/jia-zhangke-ai-video-1236665296/
- SAG-AFTRA声明: https://www.sagaftra.org/sag-aftra-statement-seedance-20

### コミュニティ
- Discord: https://discord.com/invite/zZFUeA8ZQF
- Hacker News: https://news.ycombinator.com/item?id=46940720
- Wikipedia: https://en.wikipedia.org/wiki/Seedance_2.0
