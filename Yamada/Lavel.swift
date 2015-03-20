


//Foundationフレームワークをimport
import Foundation

//ゲーム画面上のクッキーを置くセルの数
//縦（行）に９
let NumColumns = 9
//横（列）に９
let NumRows = 9

//levelの構造
class Level {
    //cookiesをゲーム画面上のすべてのクッキーを保持する二次元配列(2D array)のcookieに定義
    private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)
    //tilesをゲーム画面上のすべてのtileを保持する二次元配列(2D array)のtileにに定義
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    //オプショナル型のIntを初期値に設定し、targetScoreの名前で定数を定義する
    let targetScore: Int!
    //オプショナル型のIntを初期値に設定し、 maximumMovesの名前で定数を定義する
    let maximumMoves: Int!
    //ペア合わせが連続で成功する度に獲得できるスコアを倍にしていく
    //０を初期値に設定し、 comboMultiplierの名前で定義する
    private var comboMultiplier = 0
    //イニシャライザ
    init(filename: String) {
        //nilでなかった場合
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
        //"tiles"を含むdictionaryがnilでない場合
        if let tilesArray: AnyObject = dictionary["tiles"] {
            //Int型のtilesArrayの配列の要素の数だけ繰り返す
            for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                 //tileRowsを9-row-1をして逆さまにする
                let tileRow = NumRows - row - 1
                //rowArrayの配列の要素の数だけ繰り返す
            for (column, value) in enumerate(rowArray) {
        //値が１だった場合
        if value == 1 {
            //tileのオブジェクトを生成する
            tiles[column, tileRow] = Tile()
                        }
                    }
                
                    //targetScoreをNSNumber型のtargetscoreを含む
                    //NSInteger型に変換したdictionaryに定義する
                    targetScore = (dictionary["targetScore"] as NSNumber).integerValue
                    //maximumMovesをNSNumber型のmovesを含む
                    //NSInteger型に変換したdictionaryに定義する
                    maximumMoves = (dictionary["moves"] as NSNumber).integerValue
                }
            }
        }
    }
    //シャッフルして、Cookieで返す
    func shuffle() -> Set<Cookie>/*◎*/{
        //新しいクッキーを配置
        //setを定義
        var set: Set<Cookie>
        
        do {
//すべてのクッキーを排除して新しいクッキーでlevelを埋める
            //最初のクッキーを作る
            set = createInitialCookies()
                //始めるごとにどのクッキーがswap可能か検出させる
                detectPossibleSwaps()
        }
            //swap可能なクッキーが０だった場合ループ
            while possibleSwaps.count == 0
        //swap可能になったら再び新しいクッキーを配置させるためにsetに返す
        return set
    }
    //最初のcookieを作るためのメッソドを設定
    //Cookieに返す
    private func createInitialCookies() -> Set<Cookie> {
        //setを定義
        var set = Set<Cookie>()
        //2Darrayの行（0以上9未満の区間）から値を１つずつ取り出して繰り返しの処理
        for row in 0..<NumRows {
            //2Darrayの行（0以上9未満の区間）から値を１つずつ取り出して繰り返しの処理
            for column in 0..<NumColumns {
                //タイルがnilじゃない場合、cookieだけを作成する
                if tiles[column, row] != nil {
                    //cookieTypeを作成
                    var cookieType: CookieType
                    do {
                        //cookieTypeをランダムに生成する？？
                        cookieType = CookieType.random()
                    }
                        //ループする際の条件
                        //同時に、columnは２以上且つ
                        while (column >= 2 &&
                            //column-1とrowの位置にあるcookieがcookieTypeと同じで
                            cookies[column - 1, row]?.cookieType == cookieType &&
                            //column-2とrowの位置にあるcookieがcookieTypeと同じ
                            cookies[column - 2, row]?.cookieType == cookieType)
                            //又は、rowが２以上且つ
                            || (row >= 2 &&
                                 //columnとrow-1の位置にあるcookieがcookieTypeと同じで且つ
                                cookies[column, row - 1]?.cookieType == cookieType &&
                                //columnとrow-2の位置にあるcookieがcookieTypeと同じだった場合
                                cookies[column, row - 2]?.cookieType == cookieType)
                    //新しいクッキーを作り、2D arrayに追加する
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row]/*◎*/ = cookie
                    //setにcookieを追加する
                    set.addElement(cookie)
                }
            }
        }
        //setに返して新しいクッキーを配置する
        return set
    }
//levelグリッド上の特定の位置にあるクッキーオブジェクトを取得するメソッド
    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        //グリッドから出ないよう設定
        //columnは０以上９未満
        assert(column >= 0 && column < NumColumns)
        //rowは０以上９未満
        assert(row >= 0 && row < NumRows)
        //cookieで返す
        return cookies[column, row]
    }
    //特定のcolumnとrowの位置にタイルがあるか検出する
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        //グリッドから出ないよう設定
        //columnは０以上９未満
        assert(column >= 0 && column < NumColumns)
        //rowは０以上９未満
        assert(row >= 0 && row < NumRows)
        //tilesの位置で返す
        return tiles[column, row]
    }
        //swapされた場合適当か判断
       func isPossibleSwap(swap: Swap) -> Bool {
        //swapの値で返す
        return possibleSwaps.containsElement(swap)
    }
    //２つのクッキーの場所を交換する
    func performSwap(swap: Swap) {
        //上書きされてしまうので一時的に複製する
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row
        //columnA,rowAのプロパティをアップデート
        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA
        //columnB,rowBのプロパティをアップデート
        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
    //動きが適切なものを計算
    func detectPossibleSwaps() {
        //Setを定義
        var set = Set<Swap>/*◎*/()
        //rowを定数に代入し、0以上9未満から値を１つずつ取り出して、繰り返しの処理を行う
        for row in 0..<NumRows {
            ////columnを定数に代入し、0以上9未満から値を１つずつ取り出して、繰り返しの処理を行う
            for column in 0..<NumColumns {
                //cookies[column, row] nilでないか確認
                if let cookie = cookies[column, row] {
                    //columnがNumColumns-1より小さい場合
                    //隣のクッキーとスワイプできる
                    //最後のcolumnに関しては確認する必要がない
                    if column < NumColumns - 1 {
                        //tileがない場所にはcookieがない
                        //cookies[column + 1, row]がnilでないか確認
                        if let other = cookies[column + 1, row] {
                            //swapする
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie
                            //いずれかのクッキーがペアになる
                            //column + 1, row: row又は
                            if hasChainAtColumn(column + 1, row: row) ||
                                //column, row: row
                                hasChainAtColumn(column, row: row) {
                                    //setに要素を追加する
                                    set.addElement(Swap(cookieA: cookie, cookieB: other))
                            }
                            
                            //swapを戻す?
                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }
                    
                    //上下のクッキーとswapさせる
                    //最後のrowに関しては確認する必要がない
                    if row < NumRows - 1 {
                        //クッキーがnilでない場合
                        if let other = cookies[column, row + 1] {
                            //swapする
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie
                            
                            //いずれかのクッキーがペアになった場合
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                    set.addElement(Swap(cookieA: cookie, cookieB: other))
                            }
                            //swapを戻す
                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }
                }
            }
        }
        //スワップを可能にする
        possibleSwaps = set
    }
    //複数組のペアを持った場合のイベントの設定
    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        //cookieTypeを定義
        let cookieType = cookies[column, row]!.cookieType
        //horzLengthの定義
        var horzLength = 1/*◎*/
        //iをcolumn -1で定義。
        //iが0以上のときのcookietypeがi-1とhorzLength+1のcookietypeと等しくなる
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType; --i, ++horzLength { }
        //iをcolumn +1で定義。
        //iが行数(9)より小さいときのcookietypeがi+1とhorzLength-1のcookietypeと等しくなる
        for var i = column + 1; i < NumColumns && cookies[i, row]?.cookieType == cookieType; ++i, ++horzLength { }
        //horzLengthが3以上のとき完了
        if horzLength >= 3 { return true }
        //vertLengthを定義
        var vertLength = 1
        //iをrow-1で定義
        //iが0以上のときのcookietypeがi-1とvertLength+1のcookietypeと等しくなる
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType; --i, ++vertLength { }
        //iをrow+1で定義
        //iが0以上のときのcookietypeがi+1とvertLength+1のcookietypeと等しくなる
        for var i = row + 1; i < NumRows && cookies[column, i]?.cookieType == cookieType; ++i, ++vertLength { }
        //3以上のvertLengthで返す
        return vertLength >= 3
    }
   //3つ以上のペアがないか検出し、lavelから取り除く
    ペアを取り除くメソッドの設定
    func removeMatches() -> Set<Chain> {
        //横列のペアを検出
        let horizontalChains = detectHorizontalMatches()
        //縦列のペアを検出
        let verticalChains = detectVerticalMatches()
   
        //行と列のcookieを取り除く
        removeCookies(horizontalChains)
        removeCookies(verticalChains)
        //行と列からscoreを算出
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        
        //返り値
        return horizontalChains.unionSet(verticalChains)
    }
    
    //水平方向のペアを検出するメソッド
    private func detectHorizontalMatches() -> Set<Chain> {
        //水平方向にペアになっているクッキーオブジェクトを含んでいるので、取り除く？？
        var set = Set<Chain>()
        //0以上列数(9)未満の中から
        for row in 0..<NumRows {
         　　//最後の２つは確認する必要がない
            for var column = 0; column < NumColumns - 2 ; {
                //クッキー（タイル）があった場合
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    //同じタイプを持つ？？
                    if cookies[column + 1, row]?.cookieType == matchType &&
                        cookies[column + 2, row]?.cookieType == matchType {
                            //chainからsetにすべて新しくクッキーを追加する
                            let chain = Chain(chainType: .Horizontal)
                            do {
                                chain.addCookie(cookies[column, row]!)
                        //ペアがなかったりタイルが空の場合、飛ばす？？
                        ++column
                            }
                                while column < NumColumns && cookies[column, row]?.cookieType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                             ++column
            }
        }
        return set
    }
        //horizontalと同じように（arrayだけ違う）
    　　//垂直方向のペアを検出
        private func detectVerticalMatches() -> Set<Chain> {
        var set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType
                    
                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {
                            
                            let chain = Chain(chainType: .Vertical)
                            do {
                                chain.addCookie(cookies[column, row]!)
                                ++row
                            }
                                while row < NumRows && cookies[column, row]?.cookieType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                ++row
            }
        }
        return set
    }
    
    private func removeCookies(chains: Set<Chain>) {
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
    }
    
    private func calculateScores(chains: Set<Chain>) {
       　//3組のペアは６０、４組は１２０、５組は１８０、と倍になっていくように設定
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            ++comboMultiplier
        }
    }
    //新しいターン毎に呼び出す
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
   　//cookieで返す
    func fillHoles() -> [[Cookie]] {
        //
        var columns = [[Cookie]]()
       
        for column in 0..<NumColumns {
            var array = [Cookie]()
            
            for row in 0..<NumRows {
                if tiles[column, row] != nil && cookies[column, row] == nil {
                    
                    for lookup in (row + 1)..<NumRows {
                        if let cookie = cookies[column, lookup] {
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            //arrayに要素(cookie)を追加
                            array.append(cookie)
                           
                            break
                        }
                    }
                }
            }
            //srrayが空ではない場合
            if !array.isEmpty {
                //columsに要素(array)を追加
                columns.append(array)
            }
        }
        //columsを返す
        return columns
    }

    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown
              for column in 0..<NumColumns {
            var array = [Cookie]()
         
            for var row = NumRows - 1; row >= 0 && cookies[column, row] == nil; --row {
                //holeを見つけた場合
                if tiles[column, row] != nil {
                    //前回と違うタイプのクッキータイプをランダムに生成する
                    var newCookieType: CookieType
                    do {
                        newCookieType = CookieType.random()
                    } while newCookieType == cookieType
                    cookieType = newCookieType
                    //新しいクッキーを作り、column用にarrayに追加
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    //arrayに要素(cookie)を追加
                    array.append(cookie)
                }
            }
            //空文字の場合
            if !array.isEmpty {
                //columsに要素(array)を追加
                columns.append(array)
            }
        }
        return columns
    }
}