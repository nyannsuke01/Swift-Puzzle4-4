//
//  ViewController.swift
//  puzzleApp
//
//  Created by user on 2020/03/01.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let START = 0 //スタート
    let SCREEN = UIScreen.main.bounds.size //画面サイズ

    //変数
    var gameView: UIView!       //ゲームビュー
    var titleLabel: UILabel!    //タイトルラベル
    var piece = [UIImageView]() //ピース画像
    var data = [Int]()          //ピース配置情報
    var shuffle: Int = 0        //シャッフル
    var startButton: UIButton!  //スタートボタン


    override func viewDidLoad() {
        super.viewDidLoad()

        //ゲーム画面のXY座標とスケールの指定
        let x: CGFloat = (SCREEN.width-360)/2
        let y: CGFloat = (SCREEN.height-640)/2
        let scale = SCREEN.width/360
        gameView = UIView()
        gameView.frame = CGRect(x: x, y: y, width: 360, height: 640)
        gameView.transform = CGAffineTransform(scaleX: scale, y: scale)
        view.addSubview(gameView)

        //背景の生成
        let background = makeImageView(frame: CGRect(x: 0, y: 0, width: 360, height: 640),
                               image: UIImage(named: "1.jpg")!)
        gameView.addSubview(background)

        //絵の背景の生成
        let pictureBackground = makeImageView(frame: CGRect(x: 29, y: 179, width: 302, height: 302),
                                      image: UIImage(named: "3.png")!)
        gameView.addSubview(pictureBackground)

        //タイトルの生成
        titleLabel = makeLabel(frame: CGRect(x: 0, y: 90, width: 360, height: 70),
                                text: "Dog Puzzle", font: UIFont.systemFont(ofSize: 48))
        gameView.addSubview(titleLabel)

//        //絵のビットマップの取得
//        let picture = UIImage(named: "3.jpg")!
//        let piece = UIImage(named: "3.jpg")!
//        for i in 0..<16 {
//        piece.draw(makePieceImageView(frame: CGRect(
//                x: CGFloat(30+(i%4)*75),
//                y: CGFloat(180+Int(i/4)*75),
//                width: 75, height: 75),
//                                             index: i, picture: picture, piece: piece))
//            data.append(i)
//            gameView.addSubview(piece[i])
//        }

        //スタートボタンの生成
        startButton = makeButton(frame: CGRect(x: 124, y: 500, width: 114, height: 114),
                                  image: UIImage(named: "start.png")!, tag: START)
        gameView.addSubview(startButton)
    }

    //ラベルの生成
    func makeLabel(frame: CGRect, text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.frame = frame
        label.text = text
        label.font = font
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        return label
    }

    //イメージビューの生成
    func makeImageView(frame: CGRect, image: UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.image = image
        return imageView
    }

    //ピースイメージビューの生成
    func makePieceImageView(frame: CGRect, index: Int,
                            picture: UIImage, piece: UIImage) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        picture.draw(
            in: CGRect(x: CGFloat(-75*(index%4)),
                       y: CGFloat(-75*Int(index/4)),
                       width: 300, height: 300))
        piece.draw(in: CGRect(x: 0, y: 0, width: 75, height: 75))
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return makeImageView(frame: frame, image: image)
    }

    //イメージボタンの生成
    func makeButton(frame: CGRect, image: UIImage, tag: Int) -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = frame
        button.setImage(image, for: UIControl.State.normal)
        button.tag = tag
        button.addTarget(self, action: #selector(onClick(sender:)),
                         for: UIControl.Event.touchUpInside)
        return button
    }

    //====================
    //タッチイベント
    //====================
    //ボタンクリック時に呼ばれる

    @objc func onClick(sender: UIButton) {
        if sender.tag == START {
            //シャッフルの実行
            shuffle = 20
            while shuffle > 0 {
                if movePiece(tx: rand(num: 4), ty: rand(num: 4)) {shuffle -= 1}
            }
            for i in 0..<16 {
                let dx: CGFloat = 30+75*CGFloat(i%4)
                let dy: CGFloat = 180+75*CGFloat(i/4)
                piece[data[i]].frame =
                    CGRect(x: dx, y: dy, width: 75, height: 75)
            }

            //ゲーム開始
            titleLabel.text = "Dog Puzzle"
            piece[15].alpha = 0
            startButton.alpha = 0
        }
    }

    //タッチ開始時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if startButton.alpha != 0 {
            return
        }
        //タッチ位置からピースの列番号と行番号を求める
        let pos = touches.first?.location(in: gameView)
        if 30 < pos!.x && pos!.x < 330 && 180 < pos!.y && pos!.y < 480 {
            let tx = Int((pos!.x-30)/75)
            let ty = Int((pos!.y-180)/75)
            movePiece(tx: tx, ty: ty)
        }
    }

    //ピースの移動
    func movePiece(tx: Int, ty: Int) -> Bool {
        //空きマスの行番号と列番号を求める(4)
        var fx = 0
        var fy = 0
        for i in 0..<16 {
            if data[i] == 15 {
                fx = i%4
                fy = Int(i/4)
                break
            }
        }
        if (fx == tx && fy == ty) || (fx != tx && fy != ty) {
            return false
        }

        //ピースを上にスライド
        if fx == tx && fy < ty {
            for i in fy..<ty {
                data[fx+i*4] = data[fx+i*4+4]
            }
            data[tx+ty*4] = 15
        }
            //ピースを下にスライド
        else if fx == tx && fy > ty {
            for i in stride(from:fy, to: ty, by: -1) {
            //エラー発生
                data[fx+i*4] = data[fx+i*4-4]
            }
            data[tx+ty*4] = 15
        }
            //ピースを左にスライド
        else if fy == ty && fx < tx {
            for i in fx..<tx {
                data[i+fy*4] = data[i+fy*4+1]
            }
            data[tx+ty*4] = 15
        }
            //ピースを右にスライド
        else if fy == ty && fx > tx {
            for i in stride(from:fy, to: tx, by: -1) {
            //エラー発生
                data[i+fy*4] = data[i+fy*4-1]
            }
            data[tx+ty*4] = 15
        }

        //シャッフル時はピースの移動アニメとクリアチェックは行わない
        if shuffle > 0 {
            return true
        }

        //ピースの移動アニメとクリアチェック
        var clearCheck = 0
        for i in 0..<16 {
            let dx: CGFloat = 30+75*CGFloat(i%4)
            let dy: CGFloat = 180+75*CGFloat(i/4)

            //ピースの移動のアニメ
            if data[i] != 15 {
                UIView.beginAnimations("anime0", context: nil)
                UIView.setAnimationDuration(0.3)
                piece[data[i]].frame = CGRect(x: dx, y: dy, width: 75, height: 75)
                UIView.commitAnimations()
            } else {
                piece[data[i]].frame = CGRect(x: dx, y: dy, width: 75, height: 75)
            }

            //クリアチェック
            if data[i] == i {clearCheck += 1}
        }

        //ゲームクリア判定
        if clearCheck == 16 {
            titleLabel.text = "Clear!"
            startButton.alpha = 100

            //ピースの出現アニメ
            UIView.beginAnimations("anime1", context: nil)
            UIView.setAnimationDuration(0.6)
            piece[15].alpha = 100
            UIView.commitAnimations()
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func rand(num: UInt32) -> Int {
        return Int(arc4random()%num)
    }

}
