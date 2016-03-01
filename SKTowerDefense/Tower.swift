//
//  Tower.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 3/1/16.
//  Copyright © 2016 Sean Maraia. All rights reserved.
//

import SpriteKit

class Tower: SKSpriteNode{
    
    var canFire = true
    
    var shouldFire = false

    var rotDir: CGPoint = CGPoint.zero
    
    
    let bulletPath = NSBundle.mainBundle().pathForResource("Fireball", ofType: "sks")
    var bullet : SKEmitterNode
    
    
    init(){
        bullet = NSKeyedUnarchiver.unarchiveObjectWithFile(bulletPath!) as! SKEmitterNode
        let texture = SKTexture(imageNamed: "Spaceship")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
    }

    
    func fire()
    {
        let tempBullet = bullet.copy() as! SKEmitterNode
        
        tempBullet.position = position + CGPoint(x: cos(zRotation) * (frame.width / 2), y: sin(zRotation) * (frame.height / 2))
        tempBullet.zRotation = zRotation
        parent!.addChild(tempBullet)
        
        
        
        tempBullet.runAction(SKAction.sequence([SKAction.moveTo(position + CGPoint(x: cos(zRotation), y: sin(zRotation)) * parent!.frame.width / 2, duration: 0.5), SKAction.removeFromParent()]))
        canFire = false
        
        let reloadTimer = NSTimer(timeInterval: 0.2, target: self, selector: "reload", userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(reloadTimer, forMode: NSRunLoopCommonModes)
    }
    
    func reload()
    {
        canFire = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: CFTimeInterval){
        shouldFire = rotateTower(rotDir, rotateRadiansPerSec: 4.0 * π, dt: dt)
    }
    
    func rotateTower(direction: CGPoint, rotateRadiansPerSec: CGFloat, dt: CFTimeInterval) -> Bool {
        let shortAngle = shortestAngleBetween(self.zRotation, angle2: direction.angle)
        
        var rotAmt = rotateRadiansPerSec * CGFloat(dt)
        
        rotAmt = min(rotAmt, abs(shortAngle))
        
        self.zRotation += rotAmt * shortAngle.sign()
        
        return Int(shortAngle) == 0
        
    }
    
}
