//
//  GameScene.swift
//  Catch
//
//  Created by Nelson Gonzalez on 9/18/20.
//

import SpriteKit
import GameplayKit

enum PhysicsCategories {
    static let none: UInt32 = 0 // no physics
    static let appleCategory: UInt32 = 0x1       //1
    static let basketCategory: UInt32 = 0x1 << 1 //10
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "basket")
    let background = SKSpriteNode(imageNamed: "background")
    var timer: Timer?
    var scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        createBackground()
        
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        physicsWorld.gravity = .zero//CGVector(dx: 0.0, dy: -0.5)
       
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(spawnApples), userInfo: nil, repeats: true)
        
        addPlayer()
        
        physicsWorld.contactDelegate = self
        
        scoreLabel.zPosition = 2
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        score = 0
    }
   
    @objc func spawnApples() {
        let randomDistribution = GKRandomDistribution(lowestValue: -150, highestValue: 150)
        
        let apple = SKSpriteNode(imageNamed: "apple")
      //  apple.colorBlendFactor = 1.0
        apple.name = "Ball"
        
        apple.position = CGPoint(x: randomDistribution.nextInt(), y: 596)
        
        apple.zPosition = 1
       
        apple.physicsBody?.affectedByGravity = false
        apple.physicsBody = SKPhysicsBody(circleOfRadius: apple.size.width/2)
        apple.physicsBody?.categoryBitMask = PhysicsCategories.appleCategory
        
        apple.physicsBody?.contactTestBitMask = PhysicsCategories.basketCategory
        apple.physicsBody?.collisionBitMask = PhysicsCategories.none // Dont collide with color switch
        
        addChild(apple)
        //Mark: Move apples down
        let endPosition = frame.width + (apple.frame.width * 10)

        let moveAction = SKAction.moveBy(x: frame.minX, y: -endPosition, duration: 2.5)
        let topMoveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        apple.run(topMoveSequence)
    }
    
    func addPlayer() {
        player.name = "Basket"
        
        player.position = CGPoint(x: frame.midX, y: frame.minY + 10)
        player.zPosition = 1
        player.physicsBody?.isDynamic = false
        player.physicsBody?.affectedByGravity = false
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        player.physicsBody?.categoryBitMask = PhysicsCategories.basketCategory
        
        player.physicsBody?.contactTestBitMask = PhysicsCategories.appleCategory
        player.physicsBody?.collisionBitMask = PhysicsCategories.none // Dont collide with color switch
        
        addChild(player)
    }
    
    func createBackground() {
        background.size = CGSize(width: self.size.width, height: self.size.height + 100)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(background)
    }
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
            let touchLocation = touch.location(in: self)

        let moveAction = SKAction.moveTo(x: touchLocation.x, duration: 1)
    
            self.player.run(moveAction)
        }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

extension GameScene {
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("didBeginContact entered for \(String(describing: contact.bodyA.node!.name)) and \(String(describing: contact.bodyB.node!.name))")
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        switch contactMask {
        case PhysicsCategories.basketCategory | PhysicsCategories.appleCategory:
            print("Basket and Apples have collided")
            let appleNode = contact.bodyA.categoryBitMask == PhysicsCategories.appleCategory ? contact.bodyA.node : contact.bodyB.node

            appleNode!.removeFromParent()
            
            //increase score
        
        score += 1

        default:
            print("Some other contact occured")
        }
    }
}
