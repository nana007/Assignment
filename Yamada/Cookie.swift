

import SpriteKit
//cookieをゲーム画面上に印刷するためにprintableプロトコルを追加
//hashvalueを使用するためHashableを追加
class Cookie: Printable, Hashable {
    //Int型の変数をcolumnの名前で定義
    var column: Int
    //Int型の変数をrowの名前で定義
    var row: Int
    //cookietTyepeを定義
    let cookieType: CookieType
    
    //spriteをオプショナル型で宣言
    var sprite: SKSpriteNode?
    
    //cookieを2dgridに配置するためにcolumとrowを指定する
    init(column: Int, row: Int, cookieType: CookieType) {
        //columnの定義
        self.column = column
        //rowの定義
        self.row = row
        //cookieRypeの定義
        self.cookieType = cookieType
    }
    //descriptionの定義し文字列で出力
    var description: String {
        //クッキーのtypeとsquareの値で返す
        return "type:\(cookieType) square:(\(column),\(row))"
    }
    //Hashableプロトコルを使用するためにhashValueの定義
    var hashValue: Int {
        //row×10 + columnの値で返す
        return row*10 + column
    }
}

//enumを使用する
enum CookieType: Int, Printable {
    //cookieの名前に数字を割り振る
    case Unknown = 0, akemi, alice, kimura, pops, suzuki, yamada
    //spritenameの定義
    var spriteName: String {
        //spriteNameに名前を格納する
        let spriteNames = [
            //やまだくんとおともだち
            "akemi",
            "alice",
            "kimura",
            "pops",
            "suzuki",
            "yamada"]
        /*cookietypeは1からが始まるの一方で、
        spriteNamesのarrayは0から始まるので-1を引く
        spriteのNamesで返す*/
        return spriteNames[rawValue - 1]
    }
    
    //プレイヤーにタップされたときにクッキーが光るようにzhighlightedの画像を指定する。
    var highlightedSpriteName: String {
        //spriteName に "-Highlighted"　nameで返す
        return spriteName + "-Highlighted"
    }
    
    //ゲーム画面上にランダムに表示させる
    static func random() -> CookieType {
        //indexを見つけるためにenumの最新の値をintegerに変換する
        /*１をプラスすることで１から６までの乱数を生成する。
        そのままだとUInt32なのでint型に変換する
        cookietypeで受け取る*/
        return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
    }
    //descriptionを定義し文字列で出力
    var description: String {
        //spriteNameの値を戻す
        return spriteName
    }
}
//同じタイプのクッキーを比較するために演算子の実装を要求
func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    //返り値の設定
    //左側のcolumnは右側のcolums+左側のrowと等しく、且つ右側のrowと等しくなる値で返す
    return lhs.column == rhs.column && lhs.row == rhs.row
}