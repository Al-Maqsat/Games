//
//  GameScene.swift
//  Project17
//
//  Created by Maksat Baiserke on 17.09.2022.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene,SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    
    var isTracking = false
    var counter = 0
    
    var timer = 1.0 {
        didSet{
            gameTimer?.invalidate()
            startNewTimer()
        }
    }
    
    
    
    var score = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
        
    var possibleEnemies = ["ball","tv","hammer"]
    var gameTimer: Timer?
    var isGameOver = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        starfield = SKEmitterNode(fileNamed: "starfield")
        starfield.advanceSimulationTime(10)
        starfield.zPosition = -1
        starfield.position = CGPoint(x: 1024, y: 384)
        addChild(starfield)
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 1
        gameOverLabel.isHidden = true
        gameOverLabel.text  = "Game Over"
        gameOverLabel.fontSize = CGFloat(60)
        addChild(gameOverLabel)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        player.name = "playerExists"
        
        if let fireparticles = SKEmitterNode(fileNamed: "fireFromEngine"){
            player.addChild(fireparticles)
        }
        
        startNewTimer()
    }
    
    func startNewTimer(){
        
        gameTimer = Timer.scheduledTimer(timeInterval: timer, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy(){
        guard !isGameOver else {return}
        guard let enemy = possibleEnemies.randomElement() else {return}
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...700))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.contactTestBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.linearDamping = 0
        counter += 1
        
        if counter == 5 {
            counter = 0
            
            if timer <= 0.1 {
                timer -= 0.01
            } else if timer == 0{
                isGameOver = true
                print("You have won")
                gameOverLabel.isHidden = false
            } else {
                timer -= 0.1
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {    
        for node in children {
            if node.position.x < -300{
                node.removeFromParent()
            }
            
            if !isGameOver{
                score += 1
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
       
        var location = touch.location(in: self)
        let nodes = Set(self.nodes(at: location))
            if nodes.contains(player){
                    isTracking = true
            }

        guard isTracking else {return}
            
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }

        
        player.position = location
        guard isTracking else {return}

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTracking = false
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKNode(fileNamed: "explosion")!
            if children.contains(where: { $0.name?.contains("playerExists") ?? false }){
                explosion.position = player.position
                addChild(explosion)
                player.removeFromParent()
                isGameOver = true
                gameOverLabel.isHidden = false
                run(SKAction.playSoundFileNamed("Explosion+7.mp3", waitForCompletion: false))
            } else {
                print("Doesn't contain")
                return
            }
// MARK: - Why "Doesn't contain" appears even after the game was ended?
    }
}
