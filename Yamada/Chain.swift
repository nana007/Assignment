

////cookieをゲーム画面上に印刷するためにprintableプロトコルを追加
//hashvalueを使用するためHashableを追加
class Chain: Hashable, Printable {
    // cookiesはcookieが含まれる配列と定義
    var cookies = [Cookie]()
    
    //ChainTypeという列挙型を定義
    enum ChainType: Printable {
        //列挙値を定義
        case Horizontal
        case Vertical
        
        //dictionaryを文字列で出力
        var description: String {
            //switch文
            switch self {
            //Horizontalという要素の場合"Horizontal"で返す
            case .Horizontal: return "Horizontal"
            ////Verticalという要素の場合"Vertical"で返す
            case .Vertical: return "Vertical"
            }
        }
    }
    //初期値をChainTypeに設定してchainTypeの名前で変数を定義
    var chainType: ChainType
    //初期値を０に設定してscoreの名前で変数を定義
    var score = 0
    //イニシャライザを生成
    init(chainType/*引数*/: ChainType) {
        //chainTypeを定義
        self.chainType = chainType
    }
    //クッキーを追加するイベントの設定
    func addCookie(cookie: Cookie) {
        //cookiesにcookieを追加
        cookies.append(cookie)
    }
    
    //firstCookieのイベントを設定
    //戻り値の型をcookieに指定
    func firstCookie() -> Cookie {
        //０が含まれる配列のcookiesの値で返す
        return cookies[0]
    }
    //lastCookieのイベントの設定
    //戻り値の型をcookieに指定
    func lastCookie() -> Cookie {
        //cookiesのデータ個数−1のcookiesの配列の値で返す
        return cookies[cookies.count - 1]
    }
    //lengthの定義
    var length: Int {
        //cookiesの個数の値で返す
        return cookies.count
    }
    //文字列で出力
    var description: String {
        //chainTypeとcookiesそれぞれの値を出して返す
        return "type:\(chainType) cookies:\(cookies)"
    }
    //
    var hashValue: Int {
        //要素に関数を適用して、得られた値を返す
        return reduce(cookies, 0) { $0.hashValue ^ $1.hashValue }
    }
}
////左側のchainと右側のchainが等しいか確認
func ==(lhs: Chain, rhs: Chain) -> Bool {
    //左側のcookiesと右側のcookiesを等しくする
    return lhs.cookies == rhs.cookies
}
