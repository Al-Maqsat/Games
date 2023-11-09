//
//  GameScene.swift
//  Project 11
//
//  Created by Maksat Baiserke on 03.09.2022.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var GameOver: SKLabelNode!

    let balls = ["ballBlue", "ballCyan", "ballGreen", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var ballLimit = 5 {
        didSet{
            ballLimitLabel.text = "Balls: \(ballLimit)"
        }
    }
    
    var editLabel: SKLabelNode!
    var ballLimitLabel: SKLabelNode!

    
    var editingMode: Bool = false{
        didSet{
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        ballLimitLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballLimitLabel.text = "Balls: 5"
        ballLimitLabel.horizontalAlignmentMode = .right
        ballLimitLabel.position = CGPoint(x: 980, y: 650)
        addChild(ballLimitLabel)
        
        GameOver = SKLabelNode(fontNamed: "Chalkduster")
        GameOver.text = "GAME OVER"
        GameOver.fontSize = CGFloat(50)
        GameOver.horizontalAlignmentMode = .center
        GameOver.position = CGPoint(x: 500, y: 400)
        addChild(GameOver)
        GameOver.isHidden = true

        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makebouncer(at: CGPoint(x: 0, y: 0))
        makebouncer(at: CGPoint(x: 256, y: 0))
        makebouncer(at: CGPoint(x: 512, y: 0))
        makebouncer(at: CGPoint(x: 768, y: 0))
        makebouncer(at: CGPoint(x: 1024, y: 0))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location) // returns an array of all objects of the SKnode which properties like isHidden set to false and when alpha is greater than zero
        
        if objects.contains(editLabel){
            editingMode.toggle()
        } else {
            if editingMode{
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
                
            } else {
                if ballLimit <= 0 {
                    return
                }
                let x = Int.random(in: 0...6)
                let ball = SKSpriteNode(imageNamed: balls[x])
                
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                
                let randomHeight = Int.random(in: 500...750)
                ball.position = CGPoint(x: location.x, y: CGFloat(randomHeight))
                ball.name = "ball"
                ballLimit -= 1
                addChild(ball)
            }
            
        }
    }
    
    
    
    func makebouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode){
        if object.name == "good" {
            destroyGood(ball: ball)
            score += 1
            ballLimit += 1
        } else if object.name == "bad" {
            destroyBad(ball: ball)
            score -= 1
            if ballLimit == 0 && !children.contains(where: { $0.name?.contains("ball") ?? false }){ // https://stackoverflow.com/questions/51736881/check-if-scene-contains-any-nodes-with-name
                GameOver.isHidden = false
            }
        }
    }
    
    func destroyBad(ball: SKNode){
        if let fireparticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireparticles.position = ball.position
            addChild(fireparticles)
        }
        ball.removeFromParent()
    }
    
    func destroyGood(ball: SKNode){
        if let fireparticles = SKEmitterNode(fileNamed: "Spark"){
            fireparticles.position = ball.position
            addChild(fireparticles)
        }
        ball.removeFromParent()
    }
    
    func destroyBox(box: SKNode){
        box.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "box"{
            destroyBox(box: nodeA)
        } else if nodeB.name == "box"{
            destroyBox(box: nodeB)
        }
        
        if nodeA.name == "ball"{
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball"{
            collision(between: nodeB, object: nodeA) // if both hits simultaneously, it will delete the ball, then it will think that there were 2 collisions and try to unwrap a deleted ball(ghost ball) one more time, and our app will crash
        }
    }
    
    func startOver(action: UIAlertAction){
        ballLimit = 5
    }
}
