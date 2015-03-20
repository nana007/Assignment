


//Array2D構造体を定義
struct Array2D<T/*型パラメータ*/> {
    //列を宣言
    let columns: Int
    //行を宣言
    let rows: Int
    /*二次元配列の行優先順で格納した一次元配列
    例外処理の記述をするためにオプショナルタイプを使用*/
    private var array: Array<T?>
    //インスタンスを生成するために列と行の長さを初期化する
    init(columns: Int, rows: Int) {
        //列の指定
        self.columns = columns
        //行の指定
        self.rows = rows
        //Arrayのcountに要素数を指定し、repeatedValueは空にする。
        array = Array<T?>(count: rows*columns, repeatedValue: nil)
    }
    
//要素の値を取り出す
    //二次元入れるの中から要素を取得するためにsubscriptを実装
    subscript(column: Int, row: Int) -> T? {
        //プロパティの値を返す
        get {
           
            //配列のインデックスを算出して要素を返す
            return array[row*columns + column]
        }
        //プロパティの値を更新する
        set {
            //newValueの値を算出してarray上のインデックスに格納
            array[row*columns + column] = newValue
        }
    }
}
