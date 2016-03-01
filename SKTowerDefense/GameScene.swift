//
//  GameScene.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 2/18/16.
//  Copyright (c) 2016 Sean Maraia. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    let tower = SKSpriteNode(imageNamed:"Spaceship")
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    var rotDir: CGPoint = CGPoint.zero
    var lastTouchLocation = CGPoint.zero
    
    let bulletPath = NSBundle.mainBundle().pathForResource("Fireball", ofType: "sks")
    
    var bullet : SKEmitterNode
    
    var canFire = true
    
    var shouldFire = false
    var touched = false
    override init(size: CGSize){
        bullet = NSKeyedUnarchiver.unarchiveObjectWithFile(bulletPath!) as! SKEmitterNode
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        tower.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        tower.xScale = 0.5
        tower.yScale = 0.5
        addChild(tower)
        

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        if(touches.first != nil) {
            if let touchLocation = touches.first?.locationInNode(self) {
                sceneTouched(touchLocation)
            }
            
            

            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(touches.first != nil) {
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
        rotDir = normalizedTowerTouch

        
        
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
        
        shouldFire = rotateTower(rotDir, rotateRadiansPerSec: 4.0 * π)
        
        if shouldFire && touched && canFire{
            let tempBullet = bullet.copy() as! SKEmitterNode
            
            tempBullet.position = tower.position + CGPoint(x: cos(tower.zRotation) * (tower.frame.width / 2), y: sin(tower.zRotation) * (tower.frame.height / 2))
            tempBullet.zRotation = tower.zRotation
            addChild(tempBullet)
            
            
            
            tempBullet.runAction(SKAction.sequence([SKAction.moveTo(tower.position + CGPoint(x: cos(tower.zRotation), y: sin(tower.zRotation)) * self.frame.height / 2, duration: 0.5), SKAction.removeFromParent()]))
            canFire = false
            
            let reloadTimer = NSTimer(timeInterval: 0.2, target: self, selector: "reload", userInfo: nil, repeats: false)
            NSRunLoop.mainRunLoop().addTimer(reloadTimer, forMode: NSRunLoopCommonModes)
        }
    }
    
    func reload(){
        canFire = true
    }
    
    func rotateTower(direction: CGPoint, rotateRadiansPerSec: CGFloat) -> Bool {
        let shortAngle = shortestAngleBetween(tower.zRotation, angle2: direction.angle)
        
        var rotAmt = rotateRadiansPerSec * CGFloat(dt)
        
        rotAmt = min(rotAmt, abs(shortAngle))
        
        tower.zRotation += rotAmt * shortAngle.sign()
        
        return Int(shortAngle) == 0
        
    }

}


