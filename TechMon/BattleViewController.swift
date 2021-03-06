//
//  BattleViewController.swift
//  TechMon
//
//  Created by 小西夏穂 on 2017/09/13.
//  Copyright © 2017年 小西夏穂. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {
    
    var moveValueUpTimer: Timer! // 敵が行動するためのタイマー
    var enemy: Enemy = Enemy(name: "ドラゴン", imageName: "monster.png")// Enemyクラスをインスタンス化
    var player: Player = Player(name: "勇者", imageName: "yusya.png")// Playerクラスをインスタンス化
    var util: TechDraUtility = TechDraUtility()
    
    var isPlayerMoveValueMax: Bool = true
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var attackButton: UIButton!
    @IBOutlet var fireButton: UIButton!
    @IBOutlet var tameruButton: UIButton!
    
    @IBOutlet var enemyImageView: UIImageView!
    @IBOutlet var playerImageView: UIImageView!
    
    @IBOutlet var enemyHPBar: UIProgressView!
    @IBOutlet var playerHPBar: UIProgressView!
    @IBOutlet var enemyMoveBar: UIProgressView!
    @IBOutlet var playerMoveBar: UIProgressView!
    @IBOutlet var playerTPBar: UIProgressView!
    
    @IBOutlet var enemyNameLabel: UILabel!
    @IBOutlet var playerNameLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //　初期設定を呼び出す
        initStatus()
        moveValueUpTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BattleViewController.moveValueUp), userInfo: nil, repeats: true)
        moveValueUpTimer.fire()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //初期設定
    func initStatus() {
        
        enemyNameLabel.text = enemy.name
        playerNameLabel.text = player.name
        
        enemyImageView.image = enemy.image
        playerImageView.image = player.image
        
        enemyHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        playerHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        playerHPBar.transform = CGAffineTransform(scaleX: 1.0, y: 4.0)
        
        enemyHPBar.progress = enemy.currentHP / enemy.maxHP
        playerHPBar.progress = player.currentHP / player.maxHP
        playerTPBar.progress = player.currentTP / player.maxTP
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 画面が切り替わったら戦闘用音楽を流す
        util.playBGM(fileName: "BGM_battle001")
    }
    
    // moveUpTimerによって0.1秒毎に呼ばれるメソッド
    func moveValueUp() {
        
        player.currentMovePoint += 1
        playerMoveBar.progress = player.currentMovePoint / player.maxMovePoint
        
        
        if player.currentMovePoint >= player.maxMovePoint {
            isPlayerMoveValueMax = true    //プレイヤーの行動ゲージが溜まったら攻撃ボタンを押せる
            player.currentMovePoint = player.maxMovePoint
        } else {
            isPlayerMoveValueMax = false
        }
        
        enemy.currentMovePoint += 1
        enemyMoveBar.progress = enemy.currentMovePoint / enemy.maxMovePoint
        
        if enemy.currentMovePoint >= enemy.maxMovePoint {
            
            //敵の行動ゲージがMAXの時にenemyAttackメソッドを呼ぶ
            self.enemyAttack()
            enemy.currentMovePoint = 0
        }
    }
    
    func enemyAttack() {
        
        TechDraUtility.damageAnimation(imageView: playerImageView)
        util.playSE(fileName: "SE_attack")
        
        player.currentHP -= enemy.attackPoint
        playerHPBar.setProgress(player.currentHP, animated: true)
        
        if player.currentHP <= 0.0 {
            
            //戦闘が終わったらfinishBattleメソッドを呼び出す
            finishBattle(vanishImageView: playerImageView, winPlayer: false)
        }
    }
    
    @IBAction func attackAction() {
        
        if isPlayerMoveValueMax {
            TechDraUtility.damageAnimation(imageView: enemyImageView)
            util.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            enemyHPBar.setProgress(enemy.currentHP / enemy.maxHP, animated: true)
            
            player.currentHP += 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            playerTPBar.progress = player.currentTP / player.maxTP
            
            player.currentMovePoint = 0
            
            if enemy.currentHP <= 0.0 {
                
                //戦闘が終わったらfinishBattleメソッドを呼び出す
                finishBattle(vanishImageView: enemyImageView, winPlayer: true)
            }
        }
    }
    
    @IBAction func fireAction() {
        
        if isPlayerMoveValueMax && player.currentTP >= 40 {
            
            TechDraUtility.damageAnimation(imageView: enemyImageView)
            util.playSE(fileName: "SE_fire")
            // fireでは相手のHPに100ダメージを与える
            enemy.currentHP -= 100
            enemyHPBar.setProgress(enemy.currentHP / enemy.maxHP, animated: true)
            // playerのHPはfire後に40消耗する
            player.currentTP -= 40
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            playerTPBar.progress = player.currentTP / player.maxHP
            
            player.currentMovePoint = 0
            
            if enemy.currentHP <= 0.0 {
                finishBattle(vanishImageView: enemyImageView, winPlayer: true)
            }
        }
    }
    
    @IBAction func tamaruAction() {
        
        if isPlayerMoveValueMax{
            
            util.playSE(fileName: "SE_fire")
            //貯めるアクションでは40TPアップ
            player.currentTP += 40
            
            playerTPBar.progress = player.currentTP / player.maxTP
            player.currentMovePoint = 0
        }
    }
    
    func finishBattle(vanishImageView: UIImageView, winPlayer: Bool) {
        
        TechDraUtility.vanishAnimation(imageView: vanishImageView)
        util.stopBGM()   // BGMをストップ
        moveValueUpTimer.invalidate()
        isPlayerMoveValueMax = false
        
        let finishedMessage: String
        if winPlayer {
            util.playSE(fileName: "SE_fanfare")
            finishedMessage = "プレイヤーの勝利！！"
        } else {
            util.playSE(fileName: "SE_gameover")
            finishedMessage = "プレイヤーの敗北..."
        }
        let alert = UIAlertController(title: "バトル終了！", message: finishedMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
