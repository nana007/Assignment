

//UIKitフレームワークをインポート
import UIKit
//SpriteKitフレームワークをインポート
import SpriteKit
//サウンドの再生のためにAVFoundationフレームワークをインポート
import AVFoundation

////ゲームを作るためのクラスを用意する
class GameViewController: UIViewController {
    //オプショナル型の定数をsceneの名前で定義
    var scene: GameScene!
    //オプショナル型の定数をlevelの名前で定義
    var level: Level!
    //初期値を記述し変数をcmovesLeftの名前で定義
    var movesLeft = 0
    //初期値を記述し変数をscoreの名前で定義
    var score = 0
    
    //targetLabelを作成
    @IBOutlet weak var targetLabel: UILabel!
    //moveLabelを作成
    @IBOutlet weak var movesLabel: UILabel!
    //scoreLabelを作成
    @IBOutlet weak var scoreLabel: UILabel!
    //gameOverPanelを作成
    @IBOutlet weak var gameOverPanel: UIImageView!
    //shuffleButtonを作成
    @IBOutlet weak var shuffleButton: UIButton!
    
    //タップを認識させるためにtapGestureRecognizerを使ってインスタンスを生成
    var tapGestureRecognizer: UITapGestureRecognizer!
    //一時停止の制御等の複雑な動作をするために
    //AVAudioPlayerでbackgroundMusicを作成
    lazy var backgroundMusic: AVAudioPlayer = {
        //BGMを再生するためにファイルの管理をするNSBundleからURLを取得する
        let url = NSBundle.mainBundle().URLForResource("Ambler", withExtension: "mp3")
        //AVAudioPlayerでBGMを流す
        let player = AVAudioPlayer(contentsOfURL: url, error: nil)
        //無限にループさせる
        player.numberOfLoops = -1
        //返り値をplayerに指定
        return player
        }()
    //ステータスバーを非表示にするためにメソッドをオーバーライドする
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    //画面が回転した場合スクロール方向も自動的に変更させるための
    //メソッドをオーバーライドする
    override func shouldAutorotate() -> Bool {
        return true
    }
    //回転する方向を指定
    override func supportedInterfaceOrientations() -> Int {
        //どの方向に回転するかの値を返す
        return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
    }
    
//Viewが読み込まれる際に一度だけ呼ばれるメソッド
    //View読み込み時にviewを表示させる
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //GameViewControllerのviewをSKView型として取り出す
        let skView = view as SKView
        //multipleTouchを無効にする
        skView.multipleTouchEnabled = false
        
        //sceneを作成し、配置する
        scene = GameScene(size: skView.bounds.size)
        //作成したsceneを画面サイズに合わせる
        scene.scaleMode = .AspectFill
   　　 //levelのインスタンスを生成する
        level = Level(filename: "Level_1")
        //sceneにlevelを追加する
        scene.level = level
        //sceneにタイルを追加する
        scene.addTiles()
        //sceneにswipeHandlerを追加
        scene.swipeHandler = handleSwipe
        //game over panelをsceneから非表示にする
        gameOverPanel.hidden = true
        //shuffleButton.hiddenをsceneから非表示にする
        shuffleButton.hidden = true
        
        //skView上にSceneを表示する
        skView.presentScene(scene)
        //BGMを読み込んで再生する
        backgroundMusic.play()
        //ゲームを始める
        beginGame()
    }
    //ゲームを開始のイベントを設定
    func beginGame() {
        //movesLeftを定義
        movesLeft = level.maximumMoves
        //変数の初期化
        score = 0
        //ラベルをアップデートする
        updateLabels()
        //lebelでクッキーのペア数に応じて倍増したスコアをリセットする
        level.resetComboMultiplier()
        //sceneのアニメーションを始める
        scene.animateBeginGame() {
        //shuffleButtonを表示
        self.hidden = false
        }
        //シャッフルに返す
        shuffle()
    }
    //シャッフルを設定
    func shuffle() {
        //secen上ののCookieSpritesだけをすべて削除する
        scene.removeAllCookieSprites()
        //levelのシャッフルメソッド時に新しくcookieを配置する
        let newCookies = level.shuffle()
        //scene上で新しくspriteを追加する
        scene.addSpritesForCookies(newCookies)
    }
     //プレイヤーがswapをしたら行うイベントを設定
     func handleSwipe(swap: Swap) {
    //新しくクッキーを降ろしている間タップを無効にする
        view.userInteractionEnabled = false
        //swap可能の場合
        if level.isPossibleSwap(swap) {
            //lebel上でswap
            level.performSwap(swap)
            //scene上にペアを完成させた場合のアニメーション
            scene.animateSwap(swap, completion: handleMatches)
        } else {
            //scene上にswap無効のアニメーション
            scene.animateInvalidSwap(swap) {
                //userInteractionを無効にする
                self.view.userInteractionEnabled = true
            }
        }
    }
//ペアを合わせることに成功した場合のイベント
    func handleMatches() {
        //クッキーのペアを検出するためにchainsの名前で定義
        let chains = level.removeMatches()
                //ペアの組数が０だった場合
                if chains.count == 0 {
            //ゲームを再開する
            beginNextTurn()
            //関数の処理を終了
            return
        }
        //scene上でペアを完成させた場合のアニメーション
        scene.animateMatchedCookies(chains) {
            //chainaを定数に代入し、chainsから値を１つずつ取り出して繰り返しの処理を行う
            for chain in chains {
                //新しくscoreを総得点に加算する
                self.score += chain.score
            }
            //ラベルをアップデートする
            self.updateLabels()
          　//空きがあるところにクッキーを降ろしていくのでcolumsで定義
            //level上の空きを埋める
            let columns = self.level.fillHoles()
            //scene上でクッキーを降ろすアニメーション
            self.scene.animateFallingCookies(columns) {
            //新しいクッキーを一番上に追加
            let columns = self.level.topUpCookies()
            self.scene.animateNewCookies(columns) {
                    //ペアが検出されなくなるまで続ける
                    self.handleMatches()
                }
            }
        }
    }
    //ターゲットスコアに到達して次の画面へ切り替わった際のイベント
    func beginNextTurn() {
        ////lebelでクッキーのペア数に応じて倍増したスコアをリセットする
        level.resetComboMultiplier()
        //level上でswap可能か検出する
        level.detectPossibleSwaps()
        //view上でInteractionを有効にする
        view.userInteractionEnabled = true
        //動作の負担を軽くする?
        decrementMoves()
    }
    //ラベルをアップデートする
    func updateLabels() {
        //String型に変換してtargetscoreをtargetLabelに表示
        targetLabel.text = NSString(format: "%ld"/*ロング型*/, level.targetScore)
        //String型に変換してmovesLeftをmovesLabelに表示
        movesLabel.text = NSString(format: "%ld", movesLeft)
        //String型に変換してscoreをscorelabelに表示
        scoreLabel.text = NSString(format: "%ld", score)
    }
    //動作の負担を軽くする
    func decrementMoves() {
        //movesleftのlabelをアップデートする
        --movesLeft
        updateLabels()
            //scoreがターゲットスコア以上だった場合
        if score >= level.targetScore {
            //gameOverPanelへ"GameOver"を読み込んで表示
            gameOverPanel.image = UIImage(named: "LevelComplete")
            showGameOver()
            //movesLeftが0だっら場合
        } else if movesLeft == 0 {
            //gameOverPanelへ"GameOver"を読み込んで表示
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }
    //ゲームオーバーの際のイベントの設定
    func showGameOver() {
        //gameOverPanelを表示
        gameOverPanel.hidden = false
        //scene上のInteractionを無効にする
        scene.userInteractionEnabled = false
        //shuffleButtonを非表示にする
        shuffleButton.hidden = true
        //scene上でgameoverのアニメーション
        scene.animateGameOver() {
            //インスタンスを生成しタップの認識を有効にし、認識されるとhideGameOverへ
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
            //view上のRecognizerを加える
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }
    //GameOverのシーンを隠すための設定
    func hideGameOver() {
        //view上でタップ認識を無効にする
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil
        //gameOverPanelを非表示にする
        gameOverPanel.hidden = true
        //scene上のuserInteractionを有効にする
        scene.userInteractionEnabled = true
        //ゲームを開始
        beginGame()
    }
    //shuffleButtonが押されたときのイベント
    @IBAction func shuffleButtonPressed(AnyObject) {
        //シャッフルする
        shuffle()
        //shufflebuttonを押すと動きがかかるので負担を軽くする?
        decrementMoves()
    }
}
