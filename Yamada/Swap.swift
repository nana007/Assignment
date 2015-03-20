

//構造体を定義
struct Swap: Printable, Hashable {

    //cookieAを定義
    let cookieA: Cookie
    //cookieBを定義
    let cookieB: Cookie
    
    //イニシャライザをしてcookieAとBをCookieと定義
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    //文字列で出力
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
    //Hashableプロトコルを使用するためにhashValueの定義
    var hashValue: Int {
        //cookiAとcookieBの値を比較してビット演算子(xor)で返す
        return cookieA.hashValue ^ cookieB.hashValue
    }
}
//左側のswapと右側のswapが等しいか確認
func ==(lhs: Swap, rhs: Swap) -> Bool {

    //左側のcookieAは右側のcookieAと左側のcookieBと等しく且つ
    //右側のcookieBと等しい、又は
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB)||
        //左側のcookieBは右側のcookieAと左側のcookieAと等しく且つ右側のcookieBを等しくする
        (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}
