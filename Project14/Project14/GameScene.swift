//
//  GameScene.swift
//  Project14
//
//  Created by Maksat Baiserke on 11.09.2022.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    var gameScore: SKLabelNode!
    var slots = [WhackSlot]()
    var badPeng: AVAudioPlayer?
    var goodPeng: AVAudioPlayer?
    var touchPos: CGPoint?
    var audioPlayer = AVAudioPlayer()
    
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
        didSet{
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {

        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + i * 170, y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + i * 170, y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + i * 170, y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + i * 170, y: 140)) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            [weak self] in
            self?.createEnemy()
        }                           // why we just do not write create an enemy ?
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        touchPos = location
        let tappedNodes = nodes(at: location)
        for node in tappedNodes{
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            
            if !whackSlot.isVisible{continue}
            if whackSlot.isHit {continue}
            whackSlot.hit()
            
            print("here")

//            let path1 = Bundle.main.path(forResource: "whack", ofType: "caf")!
//            let path2 = Bundle.main.path(forResource: "whackBad", ofType: "caf")!
//
//            let url1 = URL(fileURLWithPath: path1)
//            let url2 = URL(fileURLWithPath: path2)
//
//
//
            if node.name == "charFriend"{
                score -= 5
                
//                do {
//                    goodPeng = try AVAudioPlayer(contentsOf: url1)
//                    goodPeng?.play()
//                } catch {
//                    print(error)
//                }
                
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            } else if node.name == "charEnemy" {
                
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                score += 1
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
//                do {
//                    badPeng = try AVAudioPlayer(contentsOf: url2)
//                    badPeng?.play()
//                } catch {
//                    print(error)
//                }
                
            }
        }
    }
    
    func createSlot(at position: CGPoint){
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy(){
        numRounds += 1
        
        if numRounds >= 5 {
            run(SKAction.playSoundFileNamed("videogame-death-sound-43894.mp3", waitForCompletion: false))
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 2
            addChild(gameOver)
            gameScore.position = CGPoint(x: 390, y: 290)
            gameScore.zPosition = 2
            
            return
        }
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 {slots[1].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 8 {slots[2].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 10 {slots[3].show(hideTime: popupTime)}
        if Int.random(in: 0...12) > 11 {slots[4].show(hideTime: popupTime)}

        let minDelay = popupTime / 2
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            [weak self] in
            self?.createEnemy()
        }
    }
    
}

