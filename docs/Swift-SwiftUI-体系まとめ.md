# Swift & SwiftUI 体系まとめ

> JS/TS 経験者が Swift / SwiftUI を**土台から**理解するための個人用リファレンス。
> Scrumdinger チュートリアルで詰まったときの辞書として使う。
> 各所に「JS/TS との対比」と「実際に詰まったポイント」を併記。

---

## 全体像（地図）

```
Swift言語の基礎（土台）
  型 ─┬─ struct / enum（値型）
      ├─ class（参照型）
      └─ protocol（契約）
        └ 型が持つもの：プロパティ（データ） / メソッド（動作）
            └ 2軸：instance / static、stored / computed

          ↑ この上に乗る ↑

SwiftUIの仕組み
  View（＝画面の「設計図」）
    └ body（設計図を返す computed property）
        └ modifier / VStack / makeBody …
  SwiftUIが設計図を読んで実際に描く（宣言的UI）
```

**最重要の一文**：
> Swiftは**すべて「型」でできている**。型は**プロパティとメソッド**を持ち、それぞれ **instance/static**・**stored/computed** に分かれる。SwiftUIはこの土台の上に乗っている。

---

# 第1部：Swift言語の基礎

## 1. 型システムの全体像

### すべての値は「型のインスタンス」
`5` は `Int`、`"hi"` は `String`、`true` は `Bool`。そして **`Int` も `String` も struct**。Swiftに「素のプリミティブ」は無く、全部ちゃんとした型。

> **JS対比**：JSは `string`（プリミティブ）と `String`（オブジェクト）が別物で、メソッドはオートボクシングで一時ラッパー経由。Swiftは最初から全部 struct で、メソッドが型に直接ある。

### 型を作る4つの道具
| 道具 | 何を作る | 種類 | 例 |
|---|---|---|---|
| `struct` | 値をまとめた型 | 値型（コピー） | `CardView`, `DailyScrum`, `Int` |
| `enum` | 決まった選択肢の型 | 値型（コピー） | `Theme`, `ColorScheme` |
| `class` | 値をまとめた型 | 参照型（共有） | （SwiftUIでは少なめ） |
| `protocol` | **型ではなく契約** | — | `View`, `LabelStyle` |

`struct/enum/class` は実体（インスタンス）を作れる。`protocol` は作れない（契約）。

### 型が持つもの
- **プロパティ** = データ（`scrum.title`）
- **メソッド** = 動作（`makeBody()`, `5.isMultiple(of: 2)`）

### 分類の2軸（最重要）
| 軸 | 選択肢 | 何の話 |
|---|---|---|
| **A. instance / static** | 各実物が持つ / 型に1個 | 誰に属するか |
| **B. stored / computed** | 保存 / 毎回計算 | 値の出どころ（※プロパティのみ） |

**4マス表**（今まで悩んだものが全部ここに収まる）：
| | stored | computed |
|---|---|---|
| **instance** | `var title` | **`var body`** |
| **static** | `sampleData` | `trailingIcon` |

> ⚠️ **「computed」はプロパティ専用の言葉**。メソッドには付かない（"computed method" は存在しない）。メソッドに付く軸は instance/static だけ。

---

## 2. 値型と参照型

違いは**コピーか共有か**だけ。

```swift
// 値型（struct）= コピー
struct Point { var x: Int }
var a = Point(x: 1)
var b = a        // 写しを作る（別物）
b.x = 99
a.x // 1 ← 無傷

// 参照型（class）= 共有
class Box { var x = 1 }
let c = Box()
let d = c        // 同じ実体を指す
d.x = 99
c.x // 99 ← 連動
```

| | `b = a` | 連動する？ |
|---|---|---|
| struct（値型） | コピー | しない |
| class（参照型） | 共有 | する |

- SwiftUIのViewは **struct（値型）** 中心。独立してて予測しやすいから。
- ⚠️ **Array / String / Dictionary も値型（コピー）**。JSの配列は参照（共有）なので**逆**。要注意。

---

## 3. プロパティ（stored / computed）

### stored（保存型）＝ 値を保存
```swift
var title: String = "Design"   // = で値を入れる
```

### computed（計算型）＝ アクセスのたびに計算して返す（保存しない）
```swift
var summary: String { "会議: \(title)" }   // { } で毎回計算
```

**見分け方**：`= 値` → stored / `{ ... }` → computed。

> **JS対比（これが一番効く）**：
> - **stored ＝ 普通のフィールド / `useState`**（値を保存）
> - **computed ＝ JSの `getter` / React の派生値**（毎回計算、保存しない）
> ```js
> get area() { return this.r * this.r * Math.PI; }  // ← Swiftのcomputedと完全一致
> ```

### ⚠️ computed はキャッシュではない（むしろ逆）
毎回計算し直し、結果は保存しない。「一度だけ保存」したいなら `lazy var`。

| | 保存する？ |
|---|---|
| stored（`var x = 5`） | 常に保存 |
| computed（`var x { }`） | **保存しない（毎回計算）** |
| `lazy var` | 一度だけ保存（≒キャッシュ） |

### let/var と stored/computed は別の軸
- **let/var** … 再代入できるか（`x = ...`）
- **stored/computed** … 保存か計算か（値の出どころ）

```swift
let a = 5            // 保存 × 再代入不可
var b = 5            // 保存 × 再代入可
var c: Int { 3 + 4 } // 計算（常に var。でも読み取り専用なら代入不可）
```

「値が変わる」も理由が違う：**var＝自分で再代入、computed＝自動で再計算**。

---

## 4. メソッドと関数

```swift
func add(_ a: Int, _ b: Int) -> Int { a + b }
//        ↑引数              ↑戻り値の型
```

### ★ 引数 と プロパティ の違い（頻出の混乱）
| | 何 | データの出どころ |
|---|---|---|
| **プロパティ** | 型が**持っている**データ | 自分の中 |
| **引数** | 呼ぶとき**外から渡す**データ | 呼び出し側 |

```swift
func greet(name: String) { ... }   // name は【引数】（外からもらう）
struct Person {
    var name: String                // name は【プロパティ】（自分が持つ）
    func greet() { "Hello, \(name)" } // 引数なしで自分のを読む
}
```

### メソッドも instance / static に分かれる
- instance method … `scrum.summary()`（実物から）
- static method … `DailyScrum.makeDefault()`（型名から）

### 引数ラベルと `_`
Swiftの引数は呼ぶとき**ラベル**を付ける。`_` は「ラベル不要」の指定。
```swift
func add(_ a: Int, _ b: Int)  // ラベルなし → add(2, 3)
func add(a: Int, b: Int)      // ラベルあり → add(a: 2, b: 3)
func move(from a: Int, to b: Int) // 別ラベル → move(from: 0, to: 5)
```
`_ a` = ラベル `_`（なし）+ 内部名 `a`。**JSの `_`（private慣習）とは無関係**。

---

## 5. プロトコルと準拠（契約）

- **プロトコル** = 契約（用意すべきもののリスト）
- **準拠（`: View`）** = 「契約を守る」宣言 → 要件を実装する**義務**が生じる

```swift
protocol Greetable { func greet() -> String }   // 契約（中身なし）
struct Person: Greetable {
    func greet() -> String { "Hi" }             // 義務を果たす
}
```

| 契約 | 必ず用意するもの |
|---|---|
| `View` | `var body` |
| `LabelStyle` | `func makeBody(configuration:)` |

**便利な理由**：中身を知らなくても契約だけで扱える。SwiftUIは `CardView` を知らなくても「Viewなら `body` を持つ」と分かるから描画できる。

- プロトコルは**型ではない**（`View()` は不可。実体化できない）。
- 自動合成/デフォルト実装がある契約は書かなくても準拠できる（`Codable`, `CaseIterable` など）。
- 1つの型が複数の契約を同時に守れる（`enum Theme: String, CaseIterable, Identifiable, Codable`）。

### ⚠️ 「宣言」と「実装」は別の場所
- プロトコル側：`makeBody` の**宣言だけ**（中身なし）
- struct側：`makeBody` の**実装**（実際のコード）

→ structの `makeBody` は **override ではなく「最初の実装」**（置き換える親実装が無いから）。

---

## 6. extension（型を拡張）

既存の型に、後から機能を足す（元ソースを書き換えずに）。

```swift
extension String {                 // Apple製の型にも足せる
    var isBlank: Bool { trimmingCharacters(in: .whitespaces).isEmpty }
}
```

| 足せる ✅ | 足せない ❌ |
|---|---|
| メソッド / 計算プロパティ / static プロパティ / イニシャライザ / プロトコル準拠 | **インスタンスの保存型プロパティ**（メモリの形が変わるから） |

- **プロトコルにも拡張可**（デフォルト実装を与えられる）。
- ⚠️ **struct に継承は無い**（継承は class だけ）。**extension はオーバーライドではなく「追加」**。
- structの機能共有は**継承ではなくプロトコル準拠**で行う。

---

## 7. ジェネリクス・Self・where

### ジェネリクス `<T>` ＝ 型の代役
```swift
func wrap<T>(_ x: T) -> [T] { [x] }
wrap(5)     // T = Int と推論
wrap("hi")  // T = String と推論
```
`T` は値の変数ではなく「型の代役」。具体型は**使うときに推論**される。

### `Self`（大文字）＝ プロトコルでの「準拠した自分の型」
```swift
protocol Copyable { func makeCopy() -> Self }
struct Dog: Copyable {
    func makeCopy() -> Self { Dog() }   // ここでは Self = Dog
}
```

> ⚠️ **`Self`（大）= 型、`self`（小）= インスタンス（JSの `this`）**。別物！
> 見分け：**大文字始まり＝型、小文字始まり＝値**（Swiftの命名ルール）。

### `where` ＝ 条件で絞る
```swift
extension Array where Element == Int {   // 要素がIntの配列だけ
    func sum() -> Int { reduce(0, +) }
}
```
`where Self == TrailingIconLabelStyle` の `==` は **代入ではなく「等しいか」の条件**。

---

## 8. 文法こまごま

### `\(...)` ＝ 文字列補間（エスケープではない）
```swift
"\(scrum.attendees.count)"   // 値を文字列に埋め込む（JSの `${...}` と同じ）
```
`Int` を `String` の場所に直接渡せない（Swiftは型に厳格）ので、補間で変換する。

### `:` の2つの意味
| 文脈 | 例 | 意味 | TSだと |
|---|---|---|---|
| **値名の後** | `var x: Int` | 型注釈（〜の型は） | `:`（同じ） |
| **型名の後（定義）** | `struct CardView: View` | 準拠/継承 | `implements`/`extends` |

見分け：**`:` の左が小文字（値）→ 型注釈、型名→準拠/継承**。
⚠️ プロパティの `:` は**型注釈（その値の型）**であって「属するstruct」ではない。属するstructは**書かれている場所**で決まる。

---

# 第2部：SwiftUIの仕組み

## 9. View ＝ 「設計図」（最重要の転換）

> **`Text("Hello")` は画面のピクセルそのものではない。「ここにHelloと出して」という"設計図（軽いデータ）"**。

Viewはstruct（値型）。あなたは「設計図を書く人」、SwiftUIは「それを読んで実際に描く人」。

> **React対比**：View（struct・設計図） ≒ Virtual DOM（軽い説明）。

## 10. App → Scene → View の階層
```
@main struct ScrumdingerApp: App   ← アプリ全体（1つ）
  var body: some Scene
    WindowGroup { ContentView() }  ← Scene（ウィンドウ）
                                     └ View へ橋渡し
```

## 11. body
- **常に instance × computed property**。static にはならない。
- 引数を取らない（プロパティだから）。代わりに**自分のプロパティ（`self.scrum`）を読む**。
- 返すのは **`some View`**（設計図）。
- 役割：「この(自作)Viewを、もっと小さいViewの組み合わせで説明する」。

```swift
struct CardView: View {
    let scrum: DailyScrum         // インスタンスごとのデータ
    var body: some View {         // computed・instance
        Text(scrum.title)         // 自分の scrum を読む
    }
}
```

各CardViewが別々の `scrum` を持つ → `body` も各インスタンスが持つ → **instance**（static不可）。

## 12. modifier と スタック

### modifier（修飾子）
`.padding()` `.font(.headline)` `.foregroundStyle(.tint)` など。Viewに装飾を足して**新しいViewを返す**。

### スタック（複数Viewを1つにまとめる入れ物）
| 名前 | 並べ方 |
|---|---|
| `VStack` | 縦 |
| `HStack` | 横 |
| `ZStack` | 重ねる |

`body` はViewを1つしか返せないので、複数表示するときは `VStack` 等でまとめる。

### `.foregroundStyle(.tint)` のような色
- `.foregroundStyle(...)` = 中身（文字・アイコン）の色を変える。
- `.tint` = アプリのアクセントカラー（`Assets.xcassets/AccentColor` で定義。未設定ならシステム標準の青）。

## 13. 宣言的UIと再描画

- あなたは `body` を**呼ばない**。SwiftUIが「描画時」に読みに来る（料理人がレシピを読む）。
- データが変わると、SwiftUIが `body` を**読み直して**最新の設計図を作り、差分だけ描き直す。

**再描画の仕組み（正確に）**：
1. SwiftUIは全プロパティを監視しているわけではない。
2. 渡されるプロパティ（props的）の変化は、**親が新しい値でViewを作り直し→SwiftUIが新旧を比較→違えば body 再実行**。
3. 比較が安いのは **Viewが値型（struct）だから**。
4. 再描画の**元のトリガーは `@State` などの特別な状態**（普通の変数を変えても何も起きない）。

> **React対比**：`body` ≒ render（派生出力）。`@State` ≒ `useState`。props変化で子再描画も同じ。「ただの変数を変えても再描画されない（stateを通す必要）」も共通。

## 14. スタイルのカスタマイズ（LabelStyle / makeBody / configuration）

```swift
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack { configuration.title; configuration.icon }  // title→icon（アイコン右）
    }
}
```

- `LabelStyle` = 「Labelの並べ方」を定義するプロトコル（要件は `makeBody`）。
- **`makeBody` は View を返す**（LabelStyleではなく！）。`body` と同じく「見た目を返す」役割。
- **`body` との違いは引数の有無**：`body` は自分のデータを使う（引数なし）、`makeBody` は中身を持たないので `configuration` で**外からもらう**。
- `configuration` を渡すのは **SwiftUI**。Labelのtitle/iconを詰めて `makeBody` を呼ぶ。
- `configuration.title` / `configuration.icon` = Labelの部品。Styleごとに中身は違う（ButtonStyleなら `.label` / `.isPressed` など）。

---

# 第3部：`.trailingIcon` 完全解剖（総合演習）

第1〜2部の知識を全部使う。これが読めれば土台は完成。

```swift
extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self {
        Self()
    }
}
```

### 1行ずつ
| 部分 | 意味（参照する章） |
|---|---|
| `extension LabelStyle` | プロトコルを拡張（§6） |
| `where Self == TrailingIconLabelStyle` | 条件：Self（準拠した型）がこの型のときだけ（§7） |
| `static var trailingIcon` | static の計算プロパティを足す（§1, §3） |
| `Self` | `where`で `TrailingIconLabelStyle` に確定（§7） |
| `Self()` | `TrailingIconLabelStyle()` を作って返す＝struct初期化（§1） |

### Q. なぜ `extension LabelStyle`（プロトコル）で `Self`？
`.labelStyle(...)` が期待する型は **LabelStyle**。ドット省略（`.trailingIcon`）は**期待される型の名前空間**を探すので、メンバーは **LabelStyle側に置く**必要がある（具体型側だと見つからない）。
`Self` ＋ `where` で「TrailingIconLabelStyleのときだけ・その型を作って返す」を表現。

### Q. なぜ `where Self ==` でないとダメ？
1. **汚染防止**：whereなしだと全LabelStyleに `trailingIcon` が付く。
2. **Self()を作るため**：whereなしだと `Self` が「どのLabelStyleか」不明で `Self()` を作れない。`where` で具体型に確定させて初めて作れる。

### Q. なぜ `.labelStyle(.trailingIcon)` が `.labelStyle(TrailingIconLabelStyle())` の代わりになる？
置き換えると同じ：
```
.trailingIcon
= TrailingIconLabelStyle.trailingIcon  （型名省略を戻す）
= TrailingIconLabelStyle()             （trailingIcon の中身）
```
`.red`（= `Color.red`）と同じドット省略。

### Q. 「鳥が先か卵が先か」のモヤモヤは？
循環していない。**定義の順番が一方向**：
1. `struct TrailingIconLabelStyle: LabelStyle { makeBody... }` が**先に独立して存在**（trailingIconに依存しない）。
2. その後 `extension` が①を**参照して** `trailingIcon` を後付け。

`Self == TrailingIconLabelStyle` は**定義ではなく既存の型への参照（条件）**。

### Q. TrailingIconLabelStyle と LabelStyle は同じ？
**違う**。
- `LabelStyle` = 抽象的な契約（「何らかの並べ方」。作れない）。
- `TrailingIconLabelStyle` = 具体的なstruct（「アイコンを右にする」並べ方）。
- 同じ入力（title/icon）でも **makeBody の中身（並べ方）が違う**。これが本質的な差。
- `.trailingIcon`（=`TrailingIconLabelStyle()`）は「TrailingIconLabelStyle であり、かつ LabelStyle」（Dog＝Animal と同じ）。

### Q. `DefaultLabelStyle.trailingIcon` が無いのに使えるのは？
`.trailingIcon` は「全LabelStyleに必要」ではない。**「LabelStyleを生む trailingIcon が1個あればいい」**。Swiftはその1個（TrailingIconLabelStyle用）を見つけて使う。他の型にtrailingIconが無くても無関係（`.red` が `Int` に無くてもいいのと同じ）。

---

# つまずきポイント早見表

| 疑問 | 答え |
|---|---|
| `body` は static？ | **いいえ。常に instance × computed property** |
| `Self` と `self` の違い | **`Self`(大)=型、`self`(小)=インスタンス(JSのthis)** |
| computed はキャッシュ？ | **逆。毎回計算・保存しない**。キャッシュは `lazy var` |
| `scrum` は body の引数？ | **いいえ。プロパティ**。body はそれを「読む」だけ |
| `Color.red` がインスタンス不要なのは値型だから？ | **いいえ。`red` が static（型に属す）だから**。値型は無関係 |
| `.foo` の `foo` は static？ | **型レベルのメンバー**（static プロパティ or enumケース） |
| インスタンス不要 ＝ コンストラクタ不要？ | **使う側が書かなくていいだけ**。staticの中で呼ばれる（enumケースは本当に不要） |
| `\(...)` はエスケープ？ | **いいえ。文字列補間（JSの `${...}`）** |
| struct に継承はある？ | **無い（class だけ）。extension はオーバーライドではなく追加** |
| `makeBody` は何を返す？ | **View**（LabelStyleではない） |
| `_` は private？ | **いいえ。引数ラベルなしの指定** |
| ドット省略できる条件は？ | **期待される型の名前空間の中で、その名前が一意なとき** |
| 一意性が破れたら？ | **ambiguousエラー**。型名を明示して解決 |

---

## 学び方メモ
- ハンズオンで詰まったら、この資料の該当章に戻る。
- 「型・プロパティ・メソッドは別カテゴリ」「computedはプロパティ専用」など、**カテゴリを混ぜない**のが理解のコツ。
- JS/TS の知識（getter、`${}`、`this`、interface）と対比すると速い。ただし React の再レンダリングへ無理に寄せず、自分で対比したいときだけ使う。
