

//Foundationフレームワークをimport
import Foundation
//Dictionaryに新しくメソッドを追加する
extension Dictionary {
    //app bundleからDictionaryにJSONファイルを読み込むため
    //メソッドloadJSONFromBundle()を加える
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        //プロジェクトに管理されているjsonデータを読み込ませるために
        //パスを取得する
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            //エラーを定義
            var error: NSError?
            //dataを定義　NSDataにファイルを読み込む
            let data: NSData? = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
            //dataがnilでない場合
            if let data = data {
                //NSJSONSerialization APIを使って
                //dictionryにNSDataで読み込んだファイルを変換する
                let dictionary: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &error)
                //Dictionary型のdictionaryがnilでない場合
                if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                    //dictionryで返す
                    return dictionary
            //例外にエラーの表示?
                } else {//エラーの記述
                    println("Level file '\(filename)' is not valid JSON: \(error!)")
                    //optional型を戻り値の型に指定しているのでnilで返す
                    return nil
                }
            } else {//エラーの記述
                println("Could not load level file: \(filename), error: \(error!)")
                //optional型を戻り値の型に指定しているのでnilで返す
                return nil
            }
        } else {//エラーの記述
            println("Could not find level file: \(filename)")
            //optional型を戻り値の型に指定しているのでnilで返す
            return nil
        }
    }
}

