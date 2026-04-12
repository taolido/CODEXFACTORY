# UE5 vs Blender 5 地形スカルプト 徹底比較レポート

> リサーチ日: 2026-04-08
> 目的: UE5の地形スカルプト「手触り」をBlender 5でどこまで再現できるか、何が足りないかを明確化

---

## エグゼクティブサマリー

Blender 5（および4.5 LTS）はVulkan化と大規模リファクタにより、汎用スカルプトの「手触り」では**ZBrushに肉薄するレベル**まで進化した。しかし「**ゲーム前提の大規模地形制作**」という領域では、UE5 Landscapeシステムに対して**機能・パフォーマンス・ワークフロー全ての面で体系的な差**が残っている。

業界の実運用では「Blender で個別アセット作り込み → UE5 で最終配置・ランタイム」という補完的パイプラインが事実上のデファクト。

**Blender 5に最も足りていないもの（優先度順）:**
1. **Landscape Edit Layers相当の非破壊レイヤー編集機構**（最大の欠損）
2. 高品質な組み込みエロージョン
3. ランタイム規模のPCGスキャッター
4. Landmass/Waterスプラインの統合地形変形
5. 非破壊スタンプブラシ
6. 地形専用レイヤーマテリアル + Height Blend UI
7. タイル化 + LOD/ストリーミング
8. チーム同時編集（World Partition相当）
9. スカルプト中のフルルックリアルタイムプレビュー
10. 地形専用ブラシ（Level/Ramp/Slope等 → blackearsアドオンで部分的に補完可）

---

## 1. UE5 Landscapeの全体像

### 1.1 3つのモード

| モード | 役割 |
|-------|------|
| **Manage** | 新規作成・分割・コンポーネント追加・スプライン編集・Edit Layers管理 |
| **Sculpt** | ハイトマップをブラシで盛り上げ/削る |
| **Paint** | マテリアルレイヤーを頂点ペイント |

### 1.2 内部構造

- 規則的な四角グリッドの頂点群（**ハイトフィールド**）
- 各頂点はZ（高さ）値のみを保持
- **オーバーハング・洞窟は原理的に作れない**（5.8 Mesh Terrainで解消予定）
- 推奨サイズ: 127/255/505/1009/2017/4033/8129のいずれか

### 1.3 主要ブラシ（操作感の核）

#### 基本ブラシ
| ブラシ | 機能 |
|-------|------|
| **Sculpt** | 左クリック=盛り上げ、Shift+左クリック=削り |
| **Smooth** | 凹凸を近傍と平均化 |
| **Flatten** | 最初にクリックした高さに揃える（Raise Only/Lower Only/Both） |
| **Noise** | パーリンノイズ風の凹凸を加える |

#### シミュレーション系
| ブラシ | 機能 |
|-------|------|
| **Erosion** | 風化による浸食シミュレーション |
| **Hydro-Erosion** | 水侵食の物理シミュレーション（rain/dissolve/flow/evaporation） |

#### 形状系
| ブラシ | 機能 |
|-------|------|
| **Ramp** | 2点クリックで精密な坂道作成 |
| **Visibility** | Landscape Hole Materialで穴抜け |
| **Retopologize** | 急斜面の頂点XYオフセット再配置 |
| **Mirror** | 中心軸対称コピー |

#### ブラシ形状/減衰
- **Circle Brush**: Smooth/Linear/Spherical/Tipの4種フォールオフ
- **Alpha Brush**: グレースケール画像をストロークに転写
- **Pattern Brush**: テクスチャをタイル状に敷き詰め
- **Component Brush**: コンポーネント単位操作

### 1.4 Photoshop互換ホットキー（手触りの要）

| キー | 機能 |
|------|------|
| `[` `]` | ブラシサイズ |
| `Ctrl+[` `Ctrl+]` | 強度 |
| `Ctrl+Shift+[` `Ctrl+Shift+]` | 減衰 |

ビューポートを見たままピッチ調整できる設計。

### 1.5 Edit Layers（非破壊レイヤー編集）★最重要機能

- Photoshopのレイヤーのようなスタック構造
- 各レイヤーが**ハイトマップ + ペイントテクスチャ**を独立保持
- 可視性ON/OFF、透明度、ブレンドモード、ロック、並べ替え、削除、複製
- 下のレイヤー変更は上のレイヤーに**自動波及**
- **Splines専用レイヤー**: スプライン編集が独立レイヤーで自動更新
- **作成時にしか有効化できない**点に注意

典型的レイヤー構成:
```
Layer 0: ベースノイズ（ハイトマップインポート）
Layer 1: 手Sculptした山脈ブロックアウト
Layer 2: Erosion + Hydro-Erosionの仕上げ
Layer 3: Splinesレイヤー（道路・川）
Layer 4: Water Bodyによる自動掘り込み
Layer 5: 最後の手修正
```

### 1.6 Landmass / Water System / PCG

#### Landmassプラグイン
- **Blueprint Brush**をレイヤースタックに差し込む方式
- `CustomBrush_Landmass`: スプラインで山塊/盆地/島生成、Erosion/CurlNoise/Displacement内蔵
- `CustomBrush_LandmassRiver`: スタティックメッシュをスプラインに沿って地形変形
- `CustomBrush_MaterialOnly`: マテリアル手続きノイズ
- **大規模Landscapeでは編集が重い**という報告あり

#### Water System
- Lakes/Rivers/Oceansの3種Water Body Actor
- スプラインで領域定義 → **自動的にLandscapeに溝を掘る**
- UE 5.6の**Water Tool**で大幅刷新、自動レイヤー挿入
- Buoyancy（浮力）コンポーネントで船・キャラに自動適用

#### PCG (Procedural Content Generation)
- 5.7でProduction Ready
- Landscape高さ・法線・ペイントレイヤー情報を入力に「生態系ルール」を定義
- ランタイム実行可能（プレイヤー近傍で動的生成）
- Electric Dreamsサンプル（4km x 4km ジャングル）が公式デモ

### 1.7 Nanite / Virtual Heightfield Mesh

- **Nanite Landscape**: 距離に応じた自動細分化、ライティング/シャドウ恩恵大
- **VHM (Experimental)**: RVTでZ書き込み、無限テッセレート平面メッシュ

### 1.8 ハイトマップI/O

- **推奨フォーマット**: 16bit PNG（RAWは現状バグあり）
- 8bitはバンディングで実用外
- Gaea/World Creator/Houdini/Instant Terraからハイトマップ+スプラットマップを一括インポート
- ラウンドトリップ（書き出し→外部加工→再インポート）可能

### 1.9 Auto Material（自動マテリアル）

定番5層構成:
```
ベース: 草（平地）
中間: 土（遷移）
斜面: 岩
高所: 雪
低所: 砂
```
- WorldAlignedBlend / Slopeマスク
- Triplanar投影で岩レイヤーの伸び防止
- Landscape Grass Type連動で自動フォリッジ

### 1.10 UE 5.5 / 5.6 / 5.8 のロードマップ

| バージョン | 主な追加 |
|-----------|---------|
| **UE 5.5** | Edit Layers安定化、World Partition統合強化 |
| **UE 5.6** | Water Tool刷新、自動レイヤー挿入、敷居一段低下 |
| **UE 5.8** | **Mesh Terrain**（次世代3D地形、オーバーハング/洞窟ネイティブ対応、Non-destructive Modifiers） |

---

## 2. Blender 5 の標準スカルプト機能

### 2.1 主要ブラシ

| カテゴリ | ブラシ |
|---------|-------|
| 基本 | Draw, Draw Sharp |
| 粘土系 | Clay, Clay Strips, Clay Thumb |
| エッジ | Crease |
| 集約/拡散 | Pinch, Magnify |
| 膨張 | Inflate, Blob |
| 平滑/平坦 | Smooth, Flatten, Fill, Scrape, Multi-plane Scrape |
| 大規模変形 | Grab, Snake Hook, Thumb, Nudge, Rotate, Elastic Deform |
| 物理 | Cloth, Pose, Boundary, Simulation |
| マスク | Mask, Draw Face Sets |
| カラー | Paint, Smear, Blur (5.1新) |
| ジェスチャー | Trim, Project, Line, Box, Lasso |

### 2.2 トポロジー管理

#### Dynamic Topology (Dyntopo)
- スカルプト中にメッシュをリアルタイム再分割
- **Blender 5で大幅リファクタ**: 属性サポート、境界処理改善、Topology Rake
- ブラシ使用時のみテッセレート（パフォーマンス改善）
- Detail Mode: Relative/Constant/Brush/Manual

#### Voxel Remesh
- ボクセルベース均一リメッシュ
- Interactive Voxel Size（Rキー）でビューポート調整

#### Multiresolution Modifier
- 最大12サブディビレベル（6700万ポリゴン超）
- Viewport/Sculpt/Render個別設定
- **Conform Base** (Blender 5新): ベース頂点をサブディバイド位置に移動
- Bake from Multires でディスプレイスメントマップ生成

### 2.3 Blender 5.0 のスカルプトリファクタ（数値実績）

| 項目 | 改善 |
|------|------|
| スカルプトモード突入 | **5倍以上**高速化（16M面: 11秒→1.9秒） |
| ブラシ評価 | **8倍**高速化 |
| メモリ使用量 | **30%削減** |
| GPUメモリ | 約**2倍削減** |
| BVH | トライアングル→フェイス格納で2.3倍向上 |
| マルチレゾブラシ性能 | struct-of-arraysフォーマットで32%改善 |

### 2.4 Blender 5.1 の追加機能

- **Blur ブラシ**（カラー専用）
- **Temporary Mask toggle**: Alt+LMBでマスク一時切替
- オーバーレイ警告
- 厚みのない面ストリップ処理
- Sculpt Curvesに Lasso/Box/Circle 選択追加
- Shift+X+LMBでカラーパレット追加
- **Winter of Quality 2026**: 350件超のバグ修正

### 2.5 Vulkan バックエンド（4.5+ → 5.x標準）

- Compute Shader対応
- **2000万ポリゴンのスムーズスカルプト実現**
- フレームヒッカップ軽減
- 数百万ポリゴンでのインタラクション改善

### 2.6 ブラシアセットシステム（4.3+）

- **Asset Shelf**: 3D Viewport下部に横表示
- **Essentials ライブラリ**: 130デフォルトブラシ
- Asset Catalogs方式
- Shift+Spaceでポップアップ選択
- BlenderKit / Superhive / ArtStation / Fab で追加ブラシ豊富

---

## 3. Blender 地形作成専用ツール

### 3.1 A.N.T. Landscape（標準アドオン）

- 旧Blender 4.1まではバンドル、現在はBlender Extensions（限定サポート）
- Shift+A → Mesh → Landscape
- ノイズタイプ豊富（Hetero_Terrain, Ridged, Hybrid, Musgrave）
- 球体への切り替え（惑星地形）
- 内蔵Erosionパネル

### 3.2 True-Terrain 5 ★最有力商用

- **True-VFX、2024年12月リリース**
- レイヤーベース地形システム（**非破壊レイヤー編集** - UE5 Edit Layersに最も近い）
- ワンクリックランドスケープ
- リアル浸食実装済み
- 動的水システム（波/フォーム/コースティクス/分散）
- スキャッタツール（220+アセット内蔵）
- マテリアルプリセット（地面/草/雪/土/岩）
- 200+プリセット

### 3.3 blackears Terrain Sculpting Tools（無料 / OSS）

GitHub: https://github.com/blackears/blenderTerrainSculpt
**Blender 5.0対応**

専用ブラシモード:
| モード | 用途 |
|-------|------|
| Draw | 指定高度まで盛り上げ（段地状） |
| **Level** | ストローク開始位置の高さで平坦化 |
| Add/Subtract | 既存ジオメトリへの加減 |
| **Slope (S)** | カーソル下の平均勾配を計算して適用 |
| Smooth | 平均高度の平坦面 |
| **Ramp** | ドラッグでスロープ作成 |
| Plane | 平均勾配で頂点を均す |

`[` `]` でブラシ半径（UE5互換）。**Blender標準のキャラ向けブラシでは不足する地形ブラシを補完**する重要アドオン。

### 3.4 Terrain Mixer（無料 / Blender Extensions）

- Boonar Studio
- 9つの高さ入力をMulti-Input Mixing
- 15種16Kハイトマップ + 10種8Kハイトマップ + 56種skyテクスチャ
- **Erosion Mixer**: ハイトマップブレンドで浸食シミュ
- Eevee/Cycles両対応

### 3.5 Easy Terrain Generator v2.1+

- 完全Geometry Nodesベース
- 12+地形タイプ
- **ハイドロリック浸食シミュレーション**（アニメ再生で過程観察可）
- 水・植生・雲・カーブ調整

### 3.6 Terrain Nodes（GPU加速）

- **NVIDIA CUDA GPUベース**（compute capability 3.5+）
- ノードインターフェース
- **Hydraulic / Thermal / Sediment Slope** 浸食
- GTX 1070で4096×4096を3-4秒（高速）

### 3.7 Procedural Terrain 2.0（Studio156、$15）

- Geometry Nodes + Shader Nodes
- 自動マテリアル（ハイトベース）
- **ビルトインLODシステム**（最大6レベル円形LOD）
- ベイク不要、毎フレームスクリプト不要

### 3.8 BlenderGIS（実世界データ / 無料）

- Shapefile/GeoTIFF DEM/OpenStreetMap対応
- **NASA SRTMの実標高データ取得**
- 3DビューでWebマップ表示
- ジオリファレンス管理、Delaunay三角形分割

### 3.9 Blosm（旧Blender-OSM）

- Google 3Dシティ、OpenStreetMap、地形を数クリックインポート
- グローバルカバレッジ

### 3.10 Sculpt Layers アドオン

- Blender 4.0-5.0対応
- 非破壊スカルプトワークフロー
- レイヤー追加/非表示/ロック/独立調整/結合/分離
- Multires併用可
- ZBrushレイヤーインポート対応
- **公式実装**は#132533で設計議論進行中（リリース時期未定）

### 3.11 Bbrush（AIGODLIKE、無料）

- ZBrushライクなショートカット・ツール・シルエットプレビュー

---

## 4. 浸食シミュレーション比較

| ツール | 価格 | 浸食タイプ | 実装 |
|-------|------|----------|------|
| **ErosionR** | 無料 OSS | 河川 | A.N.T.Landscape併用必須 |
| **Hydra** | 無料 OSS/MIT | 水（粒子+パイプ）/熱/雪/色輸送/流れマップ | ModernGL 5.10+ |
| **Erosion Add-on** | 有料 | 水流ベース、河川/湖生成 | カスタムメッシュ対応 |
| **Terrain Nodes** | 有料 | Hydraulic + Thermal + Sediment | NVIDIA CUDA |
| **Easy Terrain Gen v2** | 有料/無料版 | Hydraulic | Geometry Nodes |
| **Terrain Mixer** | 無料 | Erosion Mixer（ブレンド） | Geometry Nodes |
| **True-Terrain 5** | 有料 | リアル浸食 | 独自 |

**結論**: 品質ではGaea / World Creator / Houdini Heightfield に依然及ばず、Blender Artistsでも「Blenderには本物の侵食システムが無い」という声が定番。

---

## 5. UE5 vs Blender 5 主要機能比較

### 5.1 機能マトリクス

| 機能 | UE5 | Blender 5 標準 | Blenderアドオン |
|------|-----|--------------|---------------|
| 地形専用ブラシ | ◎ Sculpt/Smooth/Flatten/Ramp/Erosion/Hydro | △ 汎用のみ | ○ blackears Terrain Sculpt |
| **非破壊レイヤー** | ◎ Edit Layers | × 無し | △ True-Terrain 5 / Sculpt Layers |
| Erosionシミュ | ○ ブラシ内蔵 | × 無し | △ Hydra / ErosionR / Terrain Nodes |
| ハイドロエロージョン | ◎ Hydro-Erosion | × | △ Hydra |
| Landmass相当 | ◎ Blueprint Brush | × | △ True-Terrain 5 |
| Water System | ◎ 統合自動掘削 | × Ocean Modifier(波のみ) | △ Physical Open Waters |
| **PCGスキャッター** | ◎ ランタイム実行 | △ Geometry Nodes (オフライン) | - |
| **タイル化/ストリーミング** | ◎ World Partition | × | △ Procedural Terrain 2.0 (LOD) |
| **チーム同時編集** | ◎ OFPA | × .blendバイナリ単一ファイル | - |
| ハイトマップI/O | ◎ 16bit PNG/RAW | ○ Displace Modifier | - |
| Auto Material | ◎ 5層斜度判定 | × | ○ True-Terrain 5 |
| **Stamp非破壊** | ◎ Blueprint Brush | × 焼き込み | - |
| Photoshopホットキー | ◎ `[`/`]` | △ ブラシ毎 | ○ blackears |
| **リアルタイムフルルック** | ◎ Lumen/Nanite | × Sculptモード簡易 | - |
| 大規模メッシュ | ◎ コンポーネント分割 | △ Vulkanで20Mまで実用 | - |
| 実世界データ取込 | △ プラグイン | - | ◎ BlenderGIS / Blosm |
| 汎用モデリング/UV | △ Modeling Mode | ◎ 強力 | ◎ |
| ベイク（Hi→Low） | △ | ◎ Multires Bake | ◎ |
| キャラスカルプト | × | ◎ Vulkan で ZBrush代替級 | ◎ |
| オフラインレンダ品質 | △ Path Tracer | ◎ Cycles | ◎ |
| 価格 | $0 + 5%ロイヤリティ | **完全無償GPL** | 無料〜有料 |

### 5.2 操作感の差

#### ブラシのレスポンシブネス
- **UE5**: ハイトマップテクスチャ書き換え方式（GPUシェーダー）→ 数十平方km規模でも安定
- **Blender**: メッシュ頂点直接編集 → 解像度に対して線形に重くなる
- Blender 4.5+のVulkan化で「ZBrush近い手触り」評価あり（Pablander Academy）だが、これはキャラ規模の話。広大な地形板への適用は依然厳しい

#### リアルタイムプレビュー
- **UE5**: Lumen/Nanite/Virtual Shadow Mapを含む最終ルックそのままで彫れる
- **Blender**: SculptモードはWorkbench相当、EEVEE Nextルックは別モード切替必要

#### 大規模メッシュ
- **UE5**: Landscapeコンポーネントが最初からタイル化、編集タイルだけGPU再計算
- **Blender**: 1枚のMeshで扱う前提、巨大はチャンク分割必須（自前）

### 5.3 ワークフロー差

| 観点 | UE5 | Blender |
|------|-----|---------|
| 制作環境 | リアルタイム前提 | オフライン前提 |
| プレビュー | 制作中=ランタイムのフィデリティ | モード切替必要 |
| チームコラボ | OFPA/World Partitionで同時編集 | .blendは単一バイナリ |
| 修正サイクル | Edit Layer単位で非破壊 | アドオン依存 |

---

## 6. Blenderで「ある程度」UE5地形を再現するスタック

### 6.1 ベース地形生成

| 推奨 | 用途 |
|------|------|
| **A.N.T. Landscape** | 公式同梱、小～中規模、ノイズベース |
| **True-TERRAIN 5** | 最有力商用、Landmass+Water+Layer統合 |
| **Procedural Terrain 2.0** | Geometry Nodes、LOD付き |
| **Terrain Mixer** | 9枚ハイトマップ合成+浸食ミックス |

### 6.2 浸食

| 推奨 | タイプ |
|------|-------|
| **Hydra** | 粒子/パイプ水力侵食+熱侵食 |
| **ErosionR** | 河川 |
| **Easy Terrain Generator v2** | Geometry Nodes内蔵 |

### 6.3 スカルプト補助

- **blackears/blenderTerrainSculpt** (Blender 5.0対応): Level/Ramp/Slope専用ブラシ

### 6.4 非破壊レイヤー風運用

- Multires + Shape Key（Multires併用に制約あり）
- Sculpt Layersアドオン（Superhive、有償）
- blender-sculpting-layers (FadiMHussein, GitHub, 無償)
- True-TERRAIN 5の純正レイヤー

### 6.5 ペイントレイヤー

- Vertex Color/Attribute + Geometry Nodes + シェーダーで Weight Blend手組み
- True-TERRAIN 5のマテリアルシステム

### 6.6 水

- Ocean Modifier（波のみ）
- Physical Open Waters（リアルタイム海面）
- True-TERRAIN 5の水システム

**総評**: UE5の50-70%程度は再現可能。ただしUI統一感、チーム編集、ランタイムプレビュー、大規模ストリーミング、Edit Layersの完全非破壊性は依然埋められない。

---

## 7. 代替DCC外専用ツール

### 7.1 Gaea (QuadSpinner)
- **業界デファクト**
- GPU加速の侵食/堆積シミュ、ノードベース
- UE5/Unity/Houdiniに直接出力
- 2.x で UI 一新、3.x で Blender/Maya プラグイン予定

### 7.2 World Creator
- リアルタイムWYSIWYG
- ブラシ感覚で操作
- Blender連携公式

### 7.3 World Machine
- 老舗、ノードベース、AAA実績多数

### 7.4 Houdini Heightfield
- 究極の柔軟性
- サイエンティフィックシミュ + 完全プロシージャル + USD統合
- 学習コスト極高

### 7.5 Instant Terra
- GPUベース、リアルタイム編集

### 7.6 GeoGen (JangaFX)
- 新興、JangaFXの地形ツール

**典型的AAAパイプライン:**
```
Gaeaでベース地形+侵食
  ↓ Heightmap
UE5 LandscapeへImport
  ↓
UE5 Landmass/Water/PCGで最終調整
  ↓
Blenderで個別岩・建物アセット制作
  ↓
UE5に戻してPCG散布
```

Blenderは地形そのものの主役ではなく、**アセット工房**として位置付けられている。

---

## 8. Blender 5に「はっきり足りていない」もの（優先度順）

| # | 不足機能 | 重要度 |
|---|---------|-------|
| 1 | **Landscape Edit Layers相当の非破壊レイヤー編集機構** | ★★★★★ |
| 2 | 品質の高い組み込みエロージョン/ハイドロエロージョン | ★★★★★ |
| 3 | ランタイムスケールのPCGスキャッター | ★★★★ |
| 4 | Landmass/Waterスプラインの統合地形変形 | ★★★★ |
| 5 | 非破壊スタンプブラシ（配置・順序編集・後修正可能） | ★★★★ |
| 6 | 地形専用レイヤーマテリアルペイント+Height Blend UI | ★★★★ |
| 7 | Landscapeタイル化+LOD/ストリーミング | ★★★ |
| 8 | チーム同時編集（World Partition/OFPA相当） | ★★★ |
| 9 | スカルプト中のフルルック統合リアルタイムプレビュー | ★★★ |
| 10 | 地形向け専用ブラシセット（平坦化/ランプ/傾斜拘束） | ★★ ※blackearsで部分補完 |

これらを**1つの統合UI**で提供するのがUE5 Landscapeであり、Blender単体では現状どこまでアドオンを積んでも「統合感」という体験価値を再現できない。

---

## 9. Blenderにあって UE5 にないもの（公平性）

| 観点 | Blender優位点 |
|------|-------------|
| 汎用モデリング/リトポ/UV | UE5 Modeling Mode は進化中だが Blender に総合力で劣る |
| ベイク（ハイポリ→ローポリ） | Blender/Marmoset/Substanceの領分 |
| キャラクタースカルプト | Blender 4.5 Vulkan以降は現実的なZBrush代替 |
| オフラインレンダ品質 | Cyclesのパストレーシングが UE5 Path Tracer を上回る場面多 |
| ライセンス | GPL無償完全機能 vs UE5 商用5%ロイヤリティ |
| オフライン完結 | 単体でパイプライン完結 |
| アドオンエコシステム | 巨大 |

---

## 10. 結論

Blender 5は**スカルプトの「手触り」自体は劇的に改善**された（5倍モード突入、8倍ブラシ評価、Vulkan化で20Mポリゴン実用）。しかし「**ゲーム地形を統合UIで非破壊に作り込む**」という UE5 Landscape の体験価値は、アドオンの寄せ集めでも完全には再現できない。

**現実的な選択肢:**

1. **手触り重視のキャラ系/個別アセット** → Blender 5
2. **大規模地形をオフライン制作** → Gaea/World Creator + Blender でアセット
3. **ゲーム前提の統合的地形制作** → UE5 Landscape（または UE 5.8 Mesh Terrain を待つ）
4. **Blender単体で地形にこだわる** → True-TERRAIN 5 + blackears Terrain Sculpt + Hydra

将来的に Blender 5.x で**Sculpting Layers が公式実装**（issue #132533）されれば、最大の欠損が解消される。それまでは「Blender はアセット工房、地形主役は UE5/Gaea」というハイブリッドが現実解。

---

## 11. 参考リンク集

### UE5公式ドキュメント
- [Landscape Sculpt Mode](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-sculpt-mode-in-unreal-engine)
- [Landscape Brushes](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-brushes-in-unreal-engine)
- [Landscape Edit Layers](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-edit-layers-in-unreal-engine)
- [Landscape Erosion Tool](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-erosion-tool-in-unreal-engine)
- [Landscape Hydro-Erosion Tool](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-hydroerosion-tool-in-unreal-engine)
- [Landscape Materials](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-materials-in-unreal-engine)
- [Importing/Exporting Heightmaps](https://dev.epicgames.com/documentation/en-us/unreal-engine/importing-and-exporting-landscape-heightmaps-in-unreal-engine)
- [Using Nanite with Landscapes](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-nanite-with-landscapes-in-unreal-engine)
- [World Partition](https://dev.epicgames.com/documentation/en-us/unreal-engine/world-partition-in-unreal-engine)
- [PCG Overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/procedural-content-generation-overview)
- [Landmass Plugin API](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Plugins/Landmass)
- [Landscape Blueprint Brushes](https://dev.epicgames.com/documentation/en-us/unreal-engine/landscape-blueprint-brushes-in-unreal-engine)

### UE5 5.8 Mesh Terrain
- [Mesh Terrain Early Documentation - 80.lv](https://80.lv/articles/details-on-ue5-s-next-generation-terrain-system-revealed)
- [Next-Gen Mesh Terrain in UE 5.8 - Toolfarm](https://www.toolfarm.com/news/mesh-terrain-unreal-engine-5-8/)

### Blender 5 公式
- [Blender 5.1 Release Notes](https://www.blender.org/download/releases/5-1/)
- [Blender 5.0 Release Notes](https://www.blender.org/download/releases/5-0/)
- [Blender 5.0 Sculpt Release Notes](https://developer.blender.org/docs/release_notes/5.0/sculpt/)
- [Blender 5.0 Geometry Nodes Release Notes](https://developer.blender.org/docs/release_notes/5.0/geometry_nodes/)
- [Sculpt Mode Refactor](https://code.blender.org/2024/11/this-summers-sculpt-mode-refactor/)
- [Winter of Quality 2026](https://code.blender.org/2026/02/winter-of-quality-2026/)
- [Brush Assets is out!](https://code.blender.org/2024/07/brush-assets-is-out/)
- [Vulkan Project Update](https://code.blender.org/2023/10/vulkan-project-update/)
- [Sculpting Layers Design #132533](https://projects.blender.org/blender/blender/issues/132533)

### Blender 地形アドオン
- [A.N.T.Landscape - Extensions](https://extensions.blender.org/add-ons/antlandscape/)
- [True-Terrain 5 - Superhive](https://superhivemarket.com/products/true-terrain)
- [True-Terrain 公式](https://www.true-vfx.xyz/products/true-terrain)
- [blenderTerrainSculpt - GitHub](https://github.com/blackears/blenderTerrainSculpt)
- [Terrain Mixer - Extensions](https://extensions.blender.org/add-ons/terrainmixer/)
- [Procedural Terrain 2.0 - Superhive](https://superhivemarket.com/products/studio156-procedural-terrain-generator)
- [Easy Terrain Generator](https://blenderartists.org/t/easy-terrain-generator-v2-1-erosion-simulation/1591116)
- [Terrain Nodes Documentation](https://iperson.github.io/tn_docs/)
- [Sculpt Layers Addon - Superhive](https://superhivemarket.com/products/sculpt-layers)

### 浸食シミュレーション
- [ErosionR - GitHub](https://github.com/nerk987/ErosionR)
- [Hydra - GitHub](https://github.com/ozikazina/Hydra)

### GIS/実世界
- [BlenderGIS - GitHub](https://github.com/domlysz/BlenderGIS)
- [Blosm - GitHub](https://github.com/vvoovv/blosm)

### 外部DCC
- [QuadSpinner Gaea](https://quadspinner.com/)
- [World Creator](https://www.world-creator.com/)
- [JangaFX GeoGen](https://jangafx.com/software/geogen)

### 比較記事
- [UE5 vs Blender - CG Boost](https://community.cgboost.com/c/discussions/ue5-vs-blender)
- [Terrain in UE5 or Blender - artaux.io](https://artaux.io/detailService/88)
- [Blender to Unreal Workflow - School of Motion](https://www.schoolofmotion.com/blog/blender-to-unreal-engine-workflow)
- [Watch Out ZBrush... Blender 4.5 Vulkan - Pablander Academy](https://www.pablander.academy/tutorials/watch-out-zbrush-blender-4-5-vulkan-is-here)
- [Gaea-inspired Ultimate Blender Solution - 80.lv](https://80.lv/articles/gaea-inspired-ultimate-blender-solution-for-building-any-terrain)
- [Clean Gaea-to-Blender Pipeline - BlenderNation](https://www.blendernation.com/2025/12/29/a-clean-gaea-to-blender-pipeline-for-terrain-fog-and-final-renders/)

### 日本語
- [UE5初心者向け ランドスケープ機能 - CGbox](https://cgbox.jp/2025/01/26/ue5-beginner-landscape/)
- [Landscape ランドスケープ - UE5攻略リンク](https://ue5study.com/unrealengine-landscape/)
- [Unreal Engine 5 ワールドの地形作成 - 電通総研](https://tech.dentsusoken.com/entry/unreal-engine-world-making)

### 設計議論
- [Terrain Creation Workflow Proposal - devtalk](https://devtalk.blender.org/t/terrain-creation-workflow-proposal/22681)
- [Tool - Terrain System Design - devtalk](https://devtalk.blender.org/t/tool-terrain-system-design/12026)
