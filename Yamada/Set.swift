

//順序のないコレクションを構築して、リストをHashableで作成
struct Set<T/*型パラメーター*/: Hashable/*辞書のキー*/>: SequenceType, Printable {
    //dictionaryの名前で辞書型に定義
    private var dictionary = Dictionary<T, Bool/*キー*/>()
    
    //プロパティを書き換えるために更新
    //新しくT型の要素を加える
    mutating func addElement(newElement: T) {
        //dictionaryにnewElementを追加
        dictionary[newElement] = true
    }
    //元からあったT型の要素を取りのぞく
    mutating func removeElement(element: T) {
        //dictionaryからelementを取り除く
        dictionary[element] = nil
    }
    //要素がディレクトリにあるか確認
    func containsElement(element: T) -> Bool {
        //dictionaryのelementはnilではない
        return dictionary[element] != nil
    }
    //すべての要素をT型を格納した配列を返す
    func allElements() -> [T] {
        //キーを集めて配列の値で返す
        return Array(dictionary.keys)
    }
    //countをint型で定義
    var count: Int {
        //dictionaryのデータ個数を取得
        return dictionary.count
    }
    //要素を合一させて型パラメーターで返す
    func unionSet(otherSet: Set<T>) -> Set<T> {
        //combineを型パラメーターにを定義
        var combined = Set<T>()
        //objを定数に代入しdictionary.keyから値を１つずつ取り出して繰り返しの処理を行う
        for obj in dictionary.keys {
            //combineはobjを含むdictionary
            combined.dictionary[obj] = true
        }
        //objを定数に代入し、otherSetから値を１つずつ取り出して繰り返しの処理を行う
        for obj in otherSet.dictionary.keys {
            ////objを含むdictionary
            combined.dictionary[obj] = true
        }
        //combineする
        return combined
    }
    //型パラメーターの値を連続的に取り出すためにメソッドを設定
    func generate() -> IndexingGenerator<Array<T>> {
        //すべての要素を繰り返し取り出す
        return allElements().generate()
    }
    //descriptionメソッドの設定
    var description: String {
        //dictionaryを文字列で出力
        return dictionary.description
    }
}
