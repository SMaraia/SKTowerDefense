//
//  Tower.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 3/1/16.
//  Copyright © 2016 Sean Maraia. All rights reserved.
//

import SpriteKit

class Tower: SKSpriteNode{
    
    private var canFire = true
    private var shouldFire = false
    
    var willFire : Bool {
        return canFire && shouldFire
    }

    var rotDir: CGPoint = CGPoint.zero
    
    
    let bulletPath = NSBundle.mainBundle().pathForResource("Fireball", ofType: "sks")
    var bullet : SKEmitterNode
    
    
    var cooldownTime: Double = 0.5
    var bulletsToSpawn: Int = 1
    var bulletsExplode: Bool = false
    
    init(){
        bullet = NSKeyedUnarchiver.unarchiveObjectWithFile(bulletPath!) as! SKEmitterNode
        let texture = SKTexture(imageNamed: "Spaceship")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        
        physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: size)
        physicsBody?.dynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.Tower
        physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        physicsBody?.collisionBitMask = PhysicsCategory.None
    }

    
    
    func fire()
    {
        
        
        if(bulletsToSpawn == 1){
            let tempBullet = bullet.copy() as! SKEmitterNode
            tempBullet.position = position + CGPoint(x: cos(zRotation) * (frame.width / 2), y: sin(zRotation) * (frame.height / 2))
            tempBullet.zRotation = zRotation
            tempBullet.physicsBody = SKPhysicsBody(circleOfRadius: tempBullet.particlePositionRange.dx)
            tempBullet.physicsBody?.dynamic = true
            tempBullet.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            tempBullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            tempBullet.physicsBody?.collisionBitMask = PhysicsCategory.None
            tempBullet.physicsBody?.usesPreciseCollisionDetection = true
            
            parent!.addChild(tempBullet)
            
            
            
            tempBullet.runAction(SKAction.sequence([SKAction.moveTo(position + CGPoint(x: cos(zRotation), y: sin(zRotation)) * parent!.frame.width / 2, duration: 0.5), SKAction.removeFromParent()]))
            
        }
        else {
        for i in 0..<bulletsToSpawn{
            let angleModifier : CGFloat = CGFloat(GLKMathDegreesToRadians(15.0)) * CGFloat(i-1)
            let tempBullet = bullet.copy() as! SKEmitterNode
            tempBullet.position = position + CGPoint(x: cos(zRotation) * (frame.width / 2), y: sin(zRotation) * (frame.height / 2))
            tempBullet.zRotation = zRotation
            tempBullet.physicsBody = SKPhysicsBody(circleOfRadius: tempBullet.particlePositionRange.dx)
            tempBullet.physicsBody?.dynamic = true
            tempBullet.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            tempBullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            tempBullet.physicsBody?.collisionBitMask = PhysicsCategory.None
            tempBullet.physicsBody?.usesPreciseCollisionDetection = true
            
            parent!.addChild(tempBullet)
            
            
            
            tempBullet.runAction(SKAction.sequence([SKAction.moveTo(position + CGPoint(x: cos(zRotation + angleModifier), y: sin(zRotation + angleModifier)) * parent!.frame.width / 2, duration: 0.5), SKAction.removeFromParent()]))
            
        }
        }
        canFire = false
        let reloadTimer = NSTimer(timeInterval: cooldownTime, target: self, selector: "reload", userInfo: nil, repeats: false)
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
    
    func applyPowerUp(power: PowerUp){
        cooldownTime = power.cooldown
        bulletsToSpawn = power.bulletsToSpawn
        bulletsExplode = power.explosive
    }
    
    func rotateTower(direction: CGPoint, rotateRadiansPerSec: CGFloat, dt: CFTimeInterval) -> Bool {
        let shortAngle = shortestAngleBetween(self.zRotation, angle2: direction.angle)
        
        var rotAmt = rotateRadiansPerSec * CGFloat(dt)
        
        rotAmt = min(rotAmt, abs(shortAngle))
        
        self.zRotation += rotAmt * shortAngle.sign()
        
        return Int(shortAngle) == 0
        
    }
    
}
