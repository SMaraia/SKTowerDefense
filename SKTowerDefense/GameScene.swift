//
//  GameScene.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 2/18/16.
//  Copyright (c) 2016 Sean Maraia. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None       : UInt32 = 0
    static let All        : UInt32 = UInt32.max
    static let Enemy      : UInt32 = 0b1
    static let Projectile : UInt32 = 0b10
    static let Tower      : UInt32 = 0b100
}

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    
    let tower = Tower()
    
    var enemies = [Enemy]()
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    
    var lastTouchLocation = CGPoint.zero
    
    let playableRect : CGRect
    
    
    var touched = false
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)

        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        tower.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        tower.xScale = 0.25
        tower.yScale = 0.25
        addChild(tower)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.view!.addGestureRecognizer(pinch)
        
        
        enemies.append(Enemy())
        for e in enemies{
            addChild(e)
        }
        
        debugDrawPlayableArea()
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer) {
        touched = false
        if sender.state == .Ended {
            if sender.scale > 1 {
                print("Pinched Out")
            } else if sender.scale < 1 {
                print("Pinched In")
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if(touches.first != nil && touches.count == 1) {
            if let touchLocation = touches.first?.locationInNode(self) {
                sceneTouched(touchLocation)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.first != nil && touches.count == 1) {
            if let touchLocation = touches.first?.locationInNode(self) {
                sceneTouched(touchLocation)
            }
            
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.first != nil) {
            touched = false
        }
    }
    
    func sceneTouched(touchLocation: CGPoint)
    {
        touched = true
        lastTouchLocation = touchLocation
        let towerToTouch = touchLocation - tower.position
        let normalizedTowerTouch = towerToTouch.normalized()
        tower.rotDir = normalizedTowerTouch
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else
        {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        tower.update(dt)
        
        if tower.willFire && touched{
            tower.fire()
        }
        
        for e in enemies{
            e.update(tower.position, dt: dt)
        }
        
        
    }
    
    func projectileHitEnemy(enemy: SKSpriteNode, projectile: SKEmitterNode) {
        projectile.removeFromParent()
        print(enemies.count)
        enemy.removeFromParent()
        print(enemies.count)
    }
    
    func towerHitEnemy(enemy: SKSpriteNode, tower: SKSpriteNode) {
        print(enemies.count)
        enemies.removeAtIndex(enemies.indexOf(enemy as! Enemy)!)
        enemy.removeFromParent()
        print(enemies.count)
        //TODO: tower.takeDamage()
    }
    
    // MARK: - SKPhysicsContactDelegate Methods -
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard firstBody.node != nil else {
            print("firstBody.node is nil")
            return
        }
        
        guard secondBody.node != nil else {
            print("secondBody.node is nil")
            return
        }
        
        if(firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0) {
            projectileHitEnemy(firstBody.node as! SKSpriteNode, projectile: secondBody.node as! SKEmitterNode)
            
        } else if(firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Tower != 0) {
            towerHitEnemy(firstBody.node as! SKSpriteNode, tower: secondBody.node as! SKSpriteNode)
        }
    }

    
    // MARK: - UIGestureRecognizerDelegate Methods -
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
         shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    //MARK: Debug Functions
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
}


