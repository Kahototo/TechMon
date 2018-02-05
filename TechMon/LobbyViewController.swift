//
//  LobbyViewController.swift
//  TechMon
//
//  Created by 小西夏穂 on 2017/09/18.
//  Copyright © 2017年 小西夏穂. All rights reserved.
//


import UIKit
//　音声ファイルを使う準備
import AVFoundation

class LobbyViewController: UIViewController, AVAudioPlayerDelegate {
    
    var stamina: Float = 0
    var staminaTimer: Timer!
    var util: TechDraUtility!
    var player: Player!
    
    @IBOutlet var nameLabel: UILabel!           //名前表示のラベル
    @IBOutlet var staminaBar: UIProgressView!   //スタミナ表示用ラベル
    @IBOutlet var levelLabel: UILabel!          //レベル表示用ラベル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //　プレイヤーの設定
        player = Player(name: "勇者", imageName: "yusya.png")
        staminaBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        
        nameLabel.text = player.name
        levelLabel.text = "Lv. 15"
        stamina = 100
        
        util = TechDraUtility()
        
        cureStamina()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        util.playBGM(fileName: "lobby")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        util.stopBGM()
    }
    
    @IBAction func toBattle() {
        
        //スタミナが50以上あればスタミナ50消費して戦闘画面へ
        if stamina >= 50{
            
            stamina -= 50
            staminaBar.progress = stamina / 100
            self.performSegue(withIdentifier: "toBattle", sender: nil)
        } else {
            
            // スタミナが足りない時はアラートを出す
            let alert = UIAlertController(title: "バトルに行けません。", message: "スタミナをためて下さい。", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func cureStamina() {
        
        //　3秒毎に1スタミナ回復させる
        staminaTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(LobbyViewController.updateStaminaValue), userInfo: nil, repeats: true)
    }
    
    func updateStaminaValue() {
        
        if stamina <= 100 {
            stamina += 1
            staminaBar.progress = stamina / 100
        }
    }
}




