# 自然物3Dモデル生成AI 総合リサーチレポート

> リサーチ日: 2026-04-12
> 対象: 畑、森、雪山、岩、植物、水などの自然物3D生成が得意なAIツール・サービス

---

## エグゼクティブサマリー

2026年時点で「自然物3D」のAI生成は**3つのレイヤー**に分かれる:

1. **個別アセット生成AI** — Meshy/Tripo/Rodin/TRELLIS-2等でテキスト/画像から岩・木・植物を1個ずつ生成
2. **シーン/ワールド生成AI** — Genie 3/World Labs/Meta WorldGen/Infinigen等で自然環境全体を生成
3. **プロシージャル専門ツール** — SpeedTree/Gaea/World Creator/Houdini等（AI非使用だが圧倒的品質）

**結論:** 現時点で「畑・森・雪山」のAAA品質3Dモデルを1ツールで完結できるAIは存在しない。最も近いのは**Infinigen**（Princeton大学、Blenderベース、無料、全自然物対応）と**World Creator**（プロダクション品質、UE5/Blender連携）の組み合わせ。

---

## 1. 個別アセット生成AI（テキスト/画像 → 3Dモデル）

### 自然物対応の得意度マトリクス

| ツール | 森/木 | 岩 | 雪山 | 畑/草原 | 植物 | 品質 | 価格 |
|-------|:---:|:---:|:---:|:---:|:---:|------|------|
| **Rodin Gen-2** | B | A | B | C | C | 最高（4K PBR） | $20-30/月 |
| **TRELLIS-2** | B | A | B | C | B | 高（1536³） | **完全無料OSS** |
| **Meshy AI** | C | B | C | C | C | 中（有機物70-80%） | 無料枠+Pro $20/月 |
| **Tripo AI 3.0** | C | B | C | C | C | 中〜高 | 無料枠+Pro有料 |
| **Hunyuan3D 2.1** | C | B | C | C | C | 中〜高 | **OSS** / fal.ai $0.16 |
| **Luma AI Genie** | C | B | C | C | C | 中 | Lite $9.99/月 |
| **Sloyd AI** | - | C | - | - | C | ハードサーフェス向き | 無料枠あり |

(A=得意, B=対応可, C=基本対応/要調整, -=非対応)

### 主要ツール詳細

#### Rodin Gen-2（Hyper3D / Deemos）★高品質
- BANG（Block-wise ANalytical Generation）アーキテクチャ
- **4K PBRテクスチャ**、quad/triangle選択可、ポリカウント段階設定
- 自然物の岩・地形表現に特に強い
- Creator $20-30/月（30クレジット）、Business $60-120/月

#### TRELLIS-2（Microsoft Research）★無料で高品質
- **40億パラメータ**オープンソースモデル
- 最大**1536³解像度**、PBRマテリアル（透明/半透明含む）
- H100で512³が約3秒、1536³が約1分
- .glb出力（Blender/Unity/UE5直接対応）
- **完全無料・ローカルデプロイ可能**
- GitHub: https://github.com/microsoft/TRELLIS.2

#### Meshy AI
- テキスト/画像→3Dの総合プラットフォーム
- **.blend形式で直接エクスポート**可能
- 有機物精度70-80%（手動調整が必要な場合あり）
- Free 100クレジット/月、Pro $20/月
- 得意: プロップ・建築物。自然物はプロトタイプ向き

#### Tripo AI 3.0
- ゲーム向けクリーンなトポロジー、自動リトポ・リギング
- **公式Blenderプラグイン**あり
- 今後「3D Scenario Generator」で環境全体の生成機能追加予定
- Free 300クレジット/月（公開限定）

#### Hunyuan3D 2.1（Tencent）
- **完全オープンソース**、ローカルデプロイ可能
- テキスト/画像/スケッチ→3D、PBR対応
- fal.aiで$0.16/生成
- GitHub: https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1

---

## 2. シーン/ワールド生成AI

### Google DeepMind Genie 3 ★最先端
- 世界初のリアルタイムインタラクティブ汎用ワールドモデル（**24fps**）
- 森林、海洋、山岳、砂漠、草原、川など**多様な自然環境をフォトリアル生成**
- 天候変更・物体追加などリアルタイム修正可能
- **制限**: 標準3Dメッシュのエクスポートには非対応（インタラクティブ体験向け）
- Google AI Ultra（米国のみ）で利用可能

### World Labs Marble 1.1 Plus
- Fei-Fei Li共同創業（評価額$1B超）
- 単一画像/テキストから**ナビゲート可能な3D世界**を生成
- Gaussian Splats（.spz/.ply形式）でレンダリング
- 自動拡張で最大5つの「ダイナミックキューブ」
- 物理法則ベースの固体感・深度感
- **制限**: 人物・動物は最適化対象外。環境特化

### Meta WorldGen ★ゲームエンジン直接出力
- テキストプロンプトから約5分で**50×50mのインタラクティブ3Dワールド**生成
- LLMによるシーンレイアウト推論 + プロシージャル生成 + Diffusion 3D生成
- **Unity/UEに直接エクスポート可能（追加変換不要）**
- 研究段階。50×50m制限

### Infinigen（Princeton大学）★Blenderベース・無料
- **完全プロシージャルな自然世界ジェネレーター**
- 植物、動物、地形、火、雲、雨、雪など**自然界のあらゆるオブジェクト**を生成
- **Blenderベース**（完全統合）
- 無限のバリエーション、ランダム化された数学ルールで生成
- **完全無料（BSD 3-Clause）**
- GitHub: https://github.com/princeton-vl/infinigen

### Tencent HunyuanWorld 1
- テキスト/画像から没入型インタラクティブ3Dワールドを生成
- オープンソースフレームワーク

### Promethean AI ★UE5統合
- AIアシスタントがアーティストと協働してバーチャルワールドを構築
- 自然言語/音声コマンドでシーンを記述 → AIがアセット配置を提案
- PlayStation Studios含む10,000+ユーザー、Disney Accelerator支援
- **UE5と深く統合**
- **注意**: 自然物を「生成」ではなく既存アセットから「配置」する方式

---

## 3. プロシージャル専門ツール（非AI / 最高品質）

### 地形生成

| ツール | 特徴 | AI要素 | 価格 | 連携 |
|-------|------|-------|------|------|
| **Gaea 2.2** (QuadSpinner) | 業界デファクト。GPU加速侵食/堆積。Erosion 2で10倍高速 | **明確にAI不使用** | Community無料/Pro有料 | UE5,Unity,Houdini |
| **World Creator** | リアルタイムWYSIWYG。侵食/水/雪/砂シミュ | 限定的 | Indie $99~/永久 | UE5,Unity,Blender,Houdini |
| **Instant Terra** | 超高速ノードベース。数十億クワッド | なし | $149~/永久 | UE5,Houdini |
| **World Machine** | 老舗。AAA実績多数 | なし | 有料 | UE5,Unity |

### 植生・樹木

| ツール | 特徴 | AI要素 | 価格 |
|-------|------|-------|------|
| **SpeedTree** | 業界標準。7000+植物ライブラリ。風アニメ対応 | なし（プロシージャル） | Indie $19/月~ |
| **Xfrog** | プロシージャル有機3Dモデラー。7000+植物 | なし | ライブラリ購入型 |

### Houdini
- プロシージャル自然環境生成の**究極の柔軟性**
- Tree tools、TOPsバリエーション、地形/海洋/雲
- PDGでML/AIデータパイプライン構築可能
- SpeedTree Controller 3.0との統合（USD/Solaris）
- Indie $269/年、FX $6,995

---

## 4. 植生AI研究の最前線

### Foliager（SIGGRAPH 2025 Poster）
- **LLMと実世界の生物学データを組み合わせた森林生成**
- 自然言語で生態系タイプ・気候プロファイル・林齢等を指定
- 土壌水分・太陽放射・温度を入力に月次タイムステップで成長シミュレーション
- **科学的に妥当な3D森林生態系を数分で生成**

### FloraForge（arXiv 2025年12月）
- **LLM支援型プロシージャル植物3Dモデル**（農業向け）
- 自然言語→生物学的に正確な完全パラメトリック3D植物モデル
- Depth ControlNet + LoRA微調整 + 階層B-spline表面
- YAML形式で全パラメータ編集・バージョン管理可

### PlantDreamer（ICCV 2025 Workshop）
- 拡散モデル + Gaussian Splattingを組み合わせた3D植物生成
- GaussianDreamerを全植物種でPSNRスコア上回り

---

## 5. フォトグラメトリ / 3Dスキャン系

### Polycam
- iOS/Android/Web。1分以内で360度屋外シーン取得
- Stable Diffusion系技術で欠損部分を補完
- ドローン映像から広大な3Dモデル生成可能
- 無制限スキャン提供

### Agisoft Metashape 2.3
- プロフェッショナル向けフォトグラメトリにAI大幅統合
- AI深度マップ、AIテクスチャ強化、ニューラルインペインティング
- **Natural ブレンドモード**: 屋外シーン（雲の移動/影の変化）で滑らかな遷移
- $179-$3,499

### Quixel Megascans / Fab
- 18,000+の実世界フォトスキャンアセット
- 1,500+の無料スターターパック（3D植物/樹木含む）
- UE5 Nanite/Lumen対応

---

## 6. 3D Gaussian Splatting / NeRF

### 3DGS（2025年の進展）
- **GaRe**: 制約なし写真コレクションから屋外Relightable 3DGS
- **Two-Stage/Two-Shell GS**: 前景/背景分離で空や遠景のアーティファクトフリー
- 植生の不規則で複雑な形状は依然課題

### NeRF
- **BirdNeRF**: 航空画像から大規模シーン再構築
- **AG-NeRF**: ドローンから衛星レベルまでの高度差対応

### 比較

| 項目 | 3DGS | NeRF |
|------|------|------|
| 計算効率 | 高い（リアルタイム可） | 低い |
| 植生隠蔽部分 | 弱い | より良好 |
| リアルタイム性 | 可能（ゲーム/VR向き） | 困難（映画VFX向き） |

---

## 7. ゲームエンジン統合型

### UE5向け

| ツール | 特徴 |
|-------|------|
| **RealBiomes** | 3Dスキャンアセット、LIDAR地形、8Kテクスチャ、Nanite/Lumen対応、最大64km²、季節切替、積雪ディスプレイスメント |
| **Promethean AI** | 自然言語でアセット配置、UE5深く統合 |
| **World Creator** | UE5ブリッジプラグイン |
| **Meta WorldGen** | テキスト→UE直接出力（研究段階） |

### Blender向け

| ツール | 特徴 |
|-------|------|
| **Infinigen** | Blenderベース自然世界ジェネレーター（無料） |
| **Tripo3D プラグイン** | Blender内からAI 3D生成 |
| **World Creator プラグイン** | 地形データインポート |

---

## 8. 畑・農地・作物の3D生成

### 現状
- ゲーム/映像向けの高品質「畑」3Dモデル生成ツールは**専用ツールとして未確立**
- 学術研究（精密農業/ロボット収穫向け）が先行

### 学術研究

| プロジェクト | 内容 |
|------------|------|
| **FloraForge** | LLM支援の農業向け3D植物生成（YAML編集可） |
| **AgriField3D / MaizeField3D** | 実圃場スキャン→プロシージャルNURBSで植物再構築 |
| **Crops3D** | 多様な作物種・成長段階の3D点群データセット |
| **CropCraft** | 作物の逆プロシージャルモデリング |
| **LLM-Driven農業3Dシーン** | LLMで農業シミュレーション環境を自動生成（2026年2月 arXiv） |

### 実用的選択肢
- **Megascans農場パック**（中世農場等のスキャンアセット）
- **AI汎用ツール**（Meshy/Tripo）でテキストから畑アセット生成（農学的正確性は保証されない）
- **ドローン+フォトグラメトリ**: 実圃場を2cm精度で3D化

---

## 9. 用途別ベストチョイス

### 個別の自然物3Dモデルを手早く作りたい
1. **Rodin Gen-2** — 最高品質PBR（有料）
2. **TRELLIS-2** — 無料で高品質、ローカル実行
3. **Meshy AI** — 使いやすさと.blend直接出力

### 大規模自然環境を構築したい
1. **World Creator + SpeedTree** — プロダクション標準
2. **Infinigen** — 完全無料・Blender統合・無限バリエーション
3. **RealBiomes** (UE5限定) — AAA品質バイオーム

### 研究・実験的にAI自然環境を体験したい
- **Genie 3** (Google) — フォトリアルリアルタイム環境
- **World Labs Marble** — 画像1枚→3D世界
- **Meta WorldGen** — テキスト→ゲームエンジン互換3D世界

### 低予算で始めたい
- **TRELLIS-2** (Microsoft) — 完全無料OSS
- **Hunyuan3D** (Tencent) — 完全無料OSS
- **Infinigen** (Princeton) — 完全無料・Blenderベース

### Blenderパイプラインで完結したい
1. **Infinigen** で自然シーン自動生成
2. **TRELLIS-2 / Meshy** で個別アセット生成 → Blenderインポート
3. Blender Sculpt + Geometry Nodes で仕上げ

---

## 10. 参考リンク集

### 個別アセット生成AI
- Meshy AI: https://www.meshy.ai/
- Tripo AI: https://www.tripo3d.ai/
- Rodin Gen-2: https://hyper3d.ai/
- TRELLIS-2: https://github.com/microsoft/TRELLIS.2
- Hunyuan3D: https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1
- Luma AI Genie: https://lumalabs.ai/genie
- Sloyd AI: https://www.sloyd.ai/
- CGDream: https://cgdream.ai/features/ai-terrain-3d-model-generator

### シーン/ワールド生成AI
- Google Genie 3: https://deepmind.google/models/genie/
- World Labs: https://www.worldlabs.ai/
- Meta WorldGen: https://arxiv.org/abs/2511.16825
- Infinigen: https://github.com/princeton-vl/infinigen
- Promethean AI: https://www.prometheanai.com/

### プロシージャル専門ツール
- Gaea: https://quadspinner.com/
- World Creator: https://www.world-creator.com/
- SpeedTree: https://store.speedtree.com/
- Instant Terra: https://www.wysilab.com/
- Houdini: https://www.sidefx.com/

### フォトグラメトリ
- Polycam: https://poly.cam/
- Agisoft Metashape: https://www.agisoftmetashape.com/
- Megascans/Fab: https://quixel.com/

### 植生AI研究
- Foliager (SIGGRAPH 2025): https://dl.acm.org/doi/10.1145/3721250.3743024
- FloraForge: https://arxiv.org/abs/2512.11925
- PlantDreamer: https://arxiv.org/abs/2505.15528

### ゲームエンジン統合
- RealBiomes: https://www.realbiomes.com/
- Gaia Pro VS: https://www.procedural-worlds.com/products/professional/gaia-pro/

### Blender連携
- Tripo Blenderプラグイン: https://github.com/VAST-AI-Research/tripo-3d-for-blender
- Infinigen: https://infinigen.org/
