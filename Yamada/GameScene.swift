

//画像だけやまだくんたちをいれましたがコードをcookieのまま利用したので、
//コメントアウトでもcookieで記述させていただいてます。



//SpriteKitフレームワークをインポート
import SpriteKit


 //gamesceneを作るためのクラスを用意
 //SKSceneを継承するGameScene
class GameScene/*クラス名*/: SKScene/*スーパークラス名*/ {
//変数、定数の定義
    //初期値はオプショナル型のIntに設定してlavelの名前で定義
    var level: Level!
    //ペアが見つかった時にswapメソッドを使用するためのswipeHandlerの定義
    var swipeHandler: ((Swap) -> ()/*値を返さない関数*/)?
    //タイルの横縦の初期値の長さをそれぞれ32,36に設定して作成
    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    //SKNodeに設定してgameLayerの名前で定数を定義
    let gameLayer = SKNode/*SpriteKit用のノード*/()
    //SKNodeに設定してcookiesLayerの名前で定数を定義
    let cookiesLayer = SKNode()
    //SKNodeに設定してtilesLayerの名前で定数を定義
    let tilesLayer = SKNode()
    //SKCropNodeに設定してcropLayerの名前で定数を定義
    let cropLayer = SKCropNode/*レンダリング結果の一部分をくりぬく*/()
    //SKNodeに設定してmaskLayerの名前で定数を定義
    let maskLayer = SKNode()

    //Int型の値を保持したオプショナル型としてswipeFromColumnの名前で定義
    var swipeFromColumn: Int?
    //Int型の値を保持したオプショナル型としてswipeFromRowの名前で定義
    var swipeFromRow: Int?
    //初期値をSKSpriteNodeに設定して変数をselectionSpriteの名前で定義
    var selectionSprite = SKSpriteNode/*画像を描画するノード*/()
//SEを設定
    /*１つずつのサウンドの終了を待たないで
    すべてのサウンドに対して条件を満たし次第重ねて再生させていくために、
    waitForCompletionでfalseを指定*/
    //スワップ時の音
    let swapSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false)
    //スワップ不可能な際の音
    let invalidSwapSound = SKAction.playSoundFileNamed("drop.wav", waitForCompletion: false)
    //ペアができた際の音
    let matchSound = SKAction.playSoundFileNamed("nyon.wav", waitForCompletion: false)
    //クッキーが降りてくる際の音
    let fallingCookieSound = SKAction.playSoundFileNamed("drip1.wav", waitForCompletion: false)
    //新しくクッキーが追加される際の音
    let addCookieSound = SKAction.playSoundFileNamed("oh.wav", waitForCompletion: false)

//ゲームをセットアップする
    //必須イニシャライザを定義
    required init?(coder/*(external name)*/ aDecoder/*参照型変数(internal name?)*/: NSCoder/*クラス*/) {
        //たぶんNSCodingプロトコルのメソッドを書く代わりに記述
        fatalError("init(coder) is not used in this app")
    }
/*スーパークラスの一部の定義を指定して上書き（初期化）
    SpriteKitなのでCore Graphicsの構造体CGSizeでサイズの管理
    assetから背景画像を読み込んで置き換える*/
    override init(size: CGSize) {
        //スーパークラスのサイズのイニシャライザを呼ぶ
        super.init(size: size)
        /*配置位置の基準点となるアンカーポイントを指定する
        背景なのでオブジェクトの中心が画面の中心にいくように座標空間上の位置を指定*/
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //SKSPriteNodeで画像"Background"を読み込んで、背景に指定
        let background = SKSpriteNode(imageNamed: "Background")
        //指定した条件で背景を表示させるためにbackgroundを子ノードとして追加
        addChild(background)
        //ゲーム部分の親となるgameLayerを非表示にする
        gameLayer.hidden = true
        //指定した条件でgameLayerを反映させるためにgamelayerを子ノードとして追加
        addChild(gameLayer)
        
        //positionプロパティを用いてlayerPositionの位置を決める
        let layerPosition = CGPoint(
            /* 
            ・乗算後それぞれ２で割って左下に指定
            ・xとyの座標がCGFloat型であるのに対して
            NumColumnsとNumRowsがintであるため変換*/
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        
        
        //positionプロパティを用いてノードの中心を画面の左下に設定
        //tilesLayerの位置を作成したlayerPositionに指定する
        tilesLayer.position = layerPosition
        //gameLayerにtilesLayerを子ノードとして追加
        gameLayer.addChild(tilesLayer)
        //gameLayerにcropLayerを子ノードとして追加
        gameLayer.addChild(cropLayer)
        
        //maskLayerの位置をlayerPositionに指定する
        maskLayer.position = layerPosition
        //cropLayerにマスクをかけた状態のmaskLayer
        cropLayer.maskNode = maskLayer
        //cookiesLayerの位置をlayerPositionに指定する
        cookiesLayer.position = layerPosition
        //cropLayerにcookieLayerを子ノードとして追加
        cropLayer.addChild(cookiesLayer)
        //列でのswipeを無効にする
        swipeFromColumn = nil
        //行でのswipeを無効にする
        swipeFromRow = nil
        
        //フォントを読み込む
        SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }
    //新しくすべてのcookieを追加する
    func addSpritesForCookies(cookies: Set<Cookie>) {
        //cookieを定数に代入し、cookiesから値を１つずつ取り出して、繰り返しの処理を行う
        for cookie/*定数名*/ in cookies/*式*/ {
            //typeとnameでそれぞれimageを読み込んで、新しくスプライトを作成する
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            //スプライトの位置をcookieの行と列に指定する
            sprite.position = pointForColumn(cookie.column, row:cookie.row)
            //cookiesLayerにspriteを子ノードとして追加する
            cookiesLayer.addChild(sprite)
            //シーンに貼り付ける
            cookie.sprite = sprite
            //スプライトのalpha値（透過度）を０にする
            sprite.alpha = 0
            //横幅をページの半分の大きさに指定
            sprite.xScale = 0.5
            //縦幅をページの半分の大きさに指定
            sprite.yScale = 0.5
            
            //対象ノードに渡して実行
            sprite.runAction(
                //順番に実行するSKActionを生成
                SKAction.sequence([
                    //0.2秒から0.3秒のランダムな時間待つ
                    SKAction.waitForDuration(0.25, withRange: 0.5),
                    //並列実行するSKActionを生成
                    SKAction.group([
                        //0.25秒かけてフェードインする
                        SKAction.fadeInWithDuration(0.25),
                      //(同じ大きさのままfadeinさせるために?）
                　　　//0.25秒かけてサイズを１倍にする
                        SKAction.scaleTo(1.0, duration: 0.25)
                        ])
                    ]))
        }
    }
    
    //ゲーム画面上からすべてのCookieSpritesを消す
    func removeAllCookieSprites() {
        //cookiesLayerのすべての追加した子ノードを削除する
        cookiesLayer.removeAllChildren()
    }
     //Tilesを加える
    func addTiles() {
        //0以上列数(9)より小さい区間から値を１つずつ取り出して繰り返しの処理
        for row in 0..<NumRows {
            //0以上行数(9)より小さい区間から値を１つずつ取り出して繰り返しの処理
            for column in 0..<NumColumns {
                    //level.tileAtColumnがnilでない場合
                    if let tile = level.tileAtColumn(column, row: row) {
                    //SKSpriteNodeでMaskTileを読み込んで新しくスプライトを作る
                    let tileNode = SKSpriteNode(imageNamed: "MaskTile")
                    //tileNodeの位置を列と行に指定する
                    tileNode.position = pointForColumn(column, row: row)
                    //maskLayerにtileNodeを子ノードとして追加する
                    maskLayer.addChild(tileNode)
                }
            }
        }
             //2Darrayのタイルのパターンを記述
             //rowに対して0以上9以下の区間から値を１つずつ取り出して繰り返しの処理
             for row in 0...NumRows {
            //columnに対して0以上列数（9）以下の区間から値を１つずつ取り出して繰り返しの処理
            for column in 0...NumColumns {
                //columnが0より大きくrowは行数(9)より小さく且つ
                let topLeft     = (column > 0) && (row < NumRows)
                    //レベルがタイルの列より１段下にいるとき、topLeftはnilではない
                    && level.tileAtColumn(column - 1, row: row) != nil
                //columnとrowは0より大きく且つ
                let bottomLeft  = (column > 0) && (row > 0)
                    //レベルがタイルの列より１段下且つ１つ左にいるとき、bottomLeftはnilではない
                    && level.tileAtColumn(column - 1, row: row - 1) != nil
                //columnとrowはそれぞれ行数(9),列数(9)より小さく且つ
                let topRight    = (column < NumColumns) && (row < NumRows)
                    //レベルがタイルの列行ともに同じ位置にいるとき、topRightはnilではない
                    && level.tileAtColumn(column, row: row) != nil
                ////columnは9より小さくrowは0より大きく且つ
                let bottomRight = (column < NumColumns) && (row > 0)
                    //レベルがタイルの列と同じ且つ１つ左にいるとき、bottomRightはnilではない
                    && level.tileAtColumn(column, row: row - 1) != nil
                //4つのタイルのパターンをIntに変換し、ビット演算子を用いて0-15の値を取得する
                let value = Int(topLeft) | Int(topRight) << 1 | Int(bottomLeft) << 2 | Int(bottomRight) << 3
                //値が0でも6でも9でもない場合
                if value != 0 && value != 6 && value != 9 {
                    //String型に書き換えてnameにvalueを表示
                    let name = String(format: "Tile_%ld", value)
                    //SKSpriteNodeでイメージに指定する名前を読み込んでtileNodeに表示
                    let tileNode = SKSpriteNode(imageNamed: name)
                    //pointを行と列に定義
                    var point = pointForColumn(column, row: row)
                    //x座標から１引いたものがtileWidthの半分
                    point.x -= TileWidth/2
                    //y座標から１引いたものがHeighttileの半分
                    point.y -= TileHeight/2
                    tileNode.position = point
                    //tilesLayerにtileNodeを子ノードとして追加する
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }

    //ゲーム画面上の列と行の数値をCGPointで返す
    func pointForColumn/*関数名*/(column/*仮引数1*/: Int, row/*仮引数2*/: Int) -> CGPoint/*戻り値の型*/ {/*処理内容*/
        //CGPointの値で返す
        return CGPoint(
            //columnをCGFloatに変換して
            //TIleWidthを乗算しTileWidthをたして2で割ったものがx座標
            x: CGFloat(column)*TileWidth + TileWidth/2,
            //rowをCGFloatに変換して
            //TIleHeightを乗算しHeightをたして2で割ったものがy座標
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }
    
    //ノードを非表示にする
    //ゲーム画面上の座標をレイヤーでの座標に変換する
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
    
    //タッチされた場所がゲーム画面の横幅内に収まっているかを確認する
        //x座標0がゲーム画面上の左側なので
        //point.xがそれより右の座標であればゲーム上にあるということになる
        //右側は列の数×TileWidthで算出し、それよりも小さい場合ゲーム上にある
        if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
        //且つ
        //y座標0がゲーム画面上の下側なので
        //point.yがそれより上の座標であればゲーム上にあるということになる
        //列の数×TileHeightを算出し、それよりも小さい場合ゲーム上にある
            point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
                //trueの場合
                //xとyを横幅と縦幅でx,y座標をそれぞれ割って、タプルで戻す
                return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        } else {
            //falseの場合、無効
            return (false, 0, 0)
        }
    }
    
    //swipeを検知する
        //画面に指がタッチしたときに呼ばれるメソッドの記述
        //NSSetとして渡す
    override/*親のメソッドを上書き*/
    //タッチの動作があったときのメソッドを設定
    func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        //UITouchとして座標データを取得
        let touch = touches.anyObject() as UITouch
        //cookiesLayer上でタッチされた位置の座標を取得
        let location = touch.locationInNode(cookiesLayer)
        //NSSetとして渡された引数を、指定したノード上での座標に変換する
        let (success, column, row) = convertPoint(location)
        if success {
            //level.cookieAtColumnがnilでない場合
            if let cookie = level.cookieAtColumn(column, row: row) {
                //スワイプが開始された列を取得
                swipeFromColumn = column
                //スワイプが開始された行を取得
                swipeFromRow = row
                //スワイプした方向を取得
                showSelectionIndicatorForCookie(cookie)
            }
        }
    }
        //画面上でタッチして指を動かしたときに呼ばれるメソッドの記述
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        //swipeFromColumnがnilの場合
        if swipeFromColumn == nil { return }
        //UITouchとして（指一本分の）座標データを取得
        let touch = touches.anyObject() as UITouch
        //スクリーン上で引数として渡された座標を指定したノード上での座標に変換する
        let location = touch.locationInNode(cookiesLayer)
        ////引数として渡された座標を指定したノード上での座標に変換する
        let (success, column, row) = convertPoint(location)
        //successの場合
        if success {
            //垂直水平の方向の初期値を０に設定する
            var horzDelta = 0, vertDelta = 0
            //columnがswipeFromColumn!より小さい場合
            if column < swipeFromColumn! {
                //水平方向左
                horzDelta = -1
                ////columnがswipeFromColumn!より大きい場合
            } else if column > swipeFromColumn! {
                //水平方向右
                horzDelta = 1
                ////rowがswipeFromRow!より小さい場合
            } else if row < swipeFromRow! {
                //垂直方向下
                vertDelta = -1
                //rowがswipeFromRow!より大きい場合
            } else if row > swipeFromRow! {
                //垂直方向上
                vertDelta = 1
            }
            //新たにスワイプをしようとする場合のみ交換
            //horzDeltaが0ではない、もしくはvertDeltaが0ではない場合
            if horzDelta != 0 || vertDelta != 0 {
                //横にswap
                trySwapHorizontal(horzDelta, vertical: vertDelta)
                //SelectionIndicatorを非表示にする
                hideSelectionIndicator()
                //これ以降に行われるスワイプの動作を無効にする
                swipeFromColumn = nil
            }
        }
    }

        //縦にswap
       func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        //swapした行とhorzDeltaを足すとtoColumn
        let toColumn = swipeFromColumn! + horzDelta
        //swapした列とhorzDeltaを足すとtoRow
        let toRow = swipeFromRow! + vertDelta
        //ユーザーがグリッド外へスワップした場合、その動作を無視
        //toColumが０未満もしくは行数(９)以上
        if toColumn < 0 || toColumn >= NumColumns { return }
        //toRowが０未満もしくは列数(９)以上
        if toRow < 0 || toRow >= NumRows { return }
        
        //level.cookieAtColumnがnilではない
        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
        //level.cookieAtColumnがnilではない
        if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {
        //swipeHandlerがnilではない
        if let handler = swipeHandler {
        // Viewcontrollerにswapの要求を伝える
        let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
        handler(swap)
                }
            }
        }
    }
        //画面から指が離れたときに呼ばれるメソッドの記述
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        //ユーザーがswapしなかった場合のイベント
        //nilでないことを確認
        if selectionSprite.parent != nil && swipeFromColumn != nil {
            //SelectionIndicatorを無効にする
            hideSelectionIndicator()
        }
        //列と行の番号をリセット
        swipeFromColumn = nil
        swipeFromRow = nil
    }
    
        //タッチイベントがキャンセルになったときに呼ばれるメソッドの記述
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        touchesEnded(touches, withEvent: event)
    }
    //swapが完了するまでのイベント設定する
    func animateSwap(swap: Swap, completion: () -> ()) {
        //spriteAを定義
        let spriteA = swap.cookieA.sprite!
        //spriteBを定義
        let spriteB = swap.cookieB.sprite!
        //spriteAのz軸（奥行き）を指定
        spriteA.zPosition = 100
        //spriteBのz軸（奥行き）を指定
        spriteB.zPosition = 90
        //Durationを0.3秒に定義
        let Duration: NSTimeInterval = 0.3
        //spriteBの場所へmoveAを移動させるSKActionを生成
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        //moveAの動きをだんだん遅く
        moveA.timingMode = .EaseOut
        //SKActionを実行してmoveAの動作を完了させる(or完了時に実行?)
        spriteA.runAction(moveA, completion: completion)
        //spriteAの場所へmoveBを移動させるSKActionを生成
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        //moveBのSKActionを実行
        spriteB.runAction(moveB)
        //swapSoundのSLActionを実行
        runAction(swapSound)
    }
    //swapが無効な際のイベントの設定
    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        //spriteAの定義
        let spriteA = swap.cookieA.sprite!
        //spriteBの定義
        let spriteB = swap.cookieB.sprite!
        
        //spriteAのz軸（奥行き）を指定
        spriteA.zPosition = 100
        //spritBのz軸（奥行き）を指定
        spriteB.zPosition = 90
        
        //0.2秒かける
        let Duration: NSTimeInterval = 0.2
        //spriteBの位置へmoveAを移動させるSKActonを生成
        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        //spriteAの位置へmoveBを移動させるSKActonを生成
        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        //順番に実行するSKActionを生成
        //spriteAをSKActionで実行し完了
        spriteA.runAction(SKAction.sequence/*for in の型を表すプロトコル*/([moveA, moveB]), completion: completion)
        //順番に実行するSKActionを生成
        //spriteBをSKActionで実行し、
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        //invalidSwapSoundのSKActionを実行する
        runAction(invalidSwapSound)
    }
    
    //ペアができた際のイベントの設定
    func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
        ////chainを定数に代入しchainsから値を１つずつ取り出して繰り返しの処理を行う
        for chain in chains {
            //ペアが複数組できた際のアニメーション
            animateScoreForChain(chain)
            //cookieを定数に代入しchain.cookiesから値を１つずつ取り出して繰り返しの処理を行う
            for cookie in chain.cookies {
                
                //cookie.spriteがnilではない場合
                if let sprite = cookie.sprite {
                    //spriteのactionForKeyはnil
                    if sprite.actionForKey("removing") == nil {
                        //0.3秒かけて0.1倍にする
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        //EaseOutさせる
                        scaleAction.timingMode = .EaseOut
                        //順番に実行するSKActionを生成
                        //古いノードを削除するため
                        //removeFromParentでレイヤーシーンから削除
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
                            withKey:"removing")
                    }
                }
            }
        }
        
        //アニメーションの完了後、ゲームを続行する
        runAction(matchSound)
              //0.3秒待って完了するrunActionをSKActionで実行
              runAction(SKAction.waitForDuration(0.3), completion: completion)
    }
    //複数組のペアができた場合のイベントの設定
    func animateScoreForChain(chain: Chain) {
        //firstSpriteをchainのfirstCookiieに指定
        let firstSprite = chain.firstCookie().sprite!
        //lastSpriteをchainのfirstCookiieに指定
        let lastSprite = chain.lastCookie().sprite!
        //中心となる座標を指定
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x)/2,
            y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
        
//スコア表示をするラベルの作成
        //SKLabelNodeでフォントを読み込んでscoreLabelに適用
        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        //フォントのサイズを指定
        scoreLabel.fontSize = 16
        //スコアのラベルに（long型?）
        //string型に変換してscoreの値を設定する
        scoreLabel.text = NSString(format: "%ld", chain.score)
        //labelを中心に指定
        scoreLabel.position = centerPosition
        ////scoreLabelのz軸（奥行き）を指定
        scoreLabel.zPosition = 300
        //cookiesLayerにscoreLabelを子ノードとして追加
        cookiesLayer.addChild(scoreLabel)
        
        //ゆっくり上がってくるように指定
        //0.7秒かけてx座標へ0、y座標へ3移動するSKActionを生成
        let moveAction = SKAction.moveBy(CGVector/*摩擦力*/(dx: 0, dy: 3), duration: 0.7)
        //EaseOut
        moveAction.timingMode = .EaseOut
         //順番に実行するSKActionを生成
        //scorelabelのSKActionを実行し
        //SKActionを親ノードから取り除く
        scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
    //クッキーが崩れて降りてくるアニメーションの設定
    func animateFallingCookies(columns: [[Cookie]], completion: () -> ()) {
        //最大で0秒かける
        var longestDuration: NSTimeInterval = 0
        //columnsから値を１つずつ取り出して、繰り返しの処理を行う
        for array in columns {
            //arrayの配列の要素の数だけ繰り返す
            for (idx, cookie) in enumerate(array) {
                //newpositionをcolumnとrowのnumberに定義
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
               //アニメーションを遅らせる
                let delay = 0.05 + 0.15*NSTimeInterval(idx)
                //spriteをcookieに追加
                let sprite = cookie.sprite!
             　//クッキーはタイルごとに0.1秒ずつ落ちてくるので落ちきるまでの総時間を算出する
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
                longestDuration = max(longestDuration, duration + delay)
                //作成したnewPositionの位置へmoveAを移動させるSKActonを生成
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                //Easeoutする
                moveAction.timingMode = .EaseOut
                 //順番に実行するSKActionを生成
                sprite.runAction(
                    SKAction.sequence([
                        //待機するSKActionを実行した後
                        SKAction.waitForDuration(delay),
                        //moveActionとサウンド再生
                        SKAction.group([moveAction, fallingCookieSound])]))
            }
        }
      //ゲームをすべてのクッキーが落ちきるまで待ってから完了する（それまではゲームを続行しない）
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    //新しくクッキーが降りてくるイベントの設定
    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
       //最もアニメーションが完了するまでにかかる時間を算出する
        var longestDuration: NSTimeInterval = 0
        //columsの中のarrayの各要素に対して処理を記述
        for array in columns {
            /*新しいスプライトを列の最初のタイルから始めるために
            列の一番上にいるクッキーが誰か検知する*/
            let startRow = array[0].row + 1
            //arrayの配列の要素の数だけ繰り返す
            for (idx, cookie) in enumerate(array) {
                //クッキーに新しいスプライトを作る
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                //spriteの位置を指定
                sprite.position = pointForColumn(cookie.column, row: startRow)
                //子ノードに追加
                cookiesLayer.addChild(sprite)
                //spriteを追加
                cookie.sprite = sprite
                //順番に落りていくように見せるため、上にいるクッキーほど遅れて落ちるようにする
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
               　//時間を設定する
                let duration = NSTimeInterval(startRow - cookie.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                //急落下に見えないように落として段々消えていくように設定する
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                //newPositionの位置へmoveActionを移動させるSKActonを生成
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                //スプライトのalpha値（透過度）を０にする
                sprite.alpha = 0
                 //順番に実行するSKActionを生成
                //スプライトのSKActionを実行
                sprite.runAction(
                    SKAction.sequence([
                        //待機した後
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            //0.05秒かけてフェードインするSKActionを生成し且つ
                            SKAction.fadeInWithDuration(0.05),
                            moveAction,
                            //サウンドの読み込み
                            addCookieSound])
                        ]))
            }
        }     //ゲームを続行する前にすべてのクッキーが落ちきるまで待つ
              runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }
    
    //ゲームオーバー時のイベントの設定
    func animateGameOver(completion: () -> ()) {
        //0.3秒かけてx座標へ０、y座標へサイズの高さ分だけ位置を移動するSKActionを生成
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseIn
        //SKActionを実行
        gameLayer.runAction(action, completion: completion)
    }
    //ゲーム開始時のイベントの設定
    func animateBeginGame/*関数名*/(completion/*仮引数*/: () -> ()) {
        //gameLayerを表示する
        gameLayer.hidden = false
        //gameLayerの位置を指定する
        gameLayer.position = CGPoint(x: 0, y: size.height)
        //0.3秒かけてx座標へ０、y座標へサイズの高さ分だけ位置を移動するSKActionを生成
        let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
        action.timingMode = .EaseOut
        //SKActionを実行
        gameLayer.runAction(action, completion: completion)
    }
    //SelectionIndicator表示の設定
    func showSelectionIndicatorForCookie(cookie: Cookie) {
        //selection indicatorが表示されたままの場合取り除く
        //nilでないことを確認
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }　//cookie.spriteがnilでない場合
            if let sprite = cookie.sprite {
            //cookieからTypeとNameで画像を探しテクスチャとして読み込む
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            //テクスチャと同じ大きさになるようにサイズを指定
            selectionSprite.size = texture.size()
            //SKActionを実行
            selectionSprite.runAction(SKAction.setTexture(texture))
            //シーンに貼り付ける
            sprite.addChild(selectionSprite)
            //alpha値を1.0にする
            selectionSprite.alpha = 1.0
        }
    }
    //SelectionIndicator非表示の設定
    func hideSelectionIndicator() {
         //順番に実行するSKActionを生成
        selectionSprite.runAction(SKAction.sequence([
            //0.3秒かけてfadeOut後
            SKAction.fadeOutWithDuration(0.3),
            //親ノードから取り除く
            SKAction.removeFromParent()]))
    }
}