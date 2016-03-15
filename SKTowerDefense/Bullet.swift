//
//  Bullet.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 3/10/16.
//  Copyright © 2016 Sean Maraia. All rights reserved.
//


import SpriteKit

class Bullet: SKSpriteNode{
    
    init(){
        let texture = SKTexture(imageNamed: "Bullet")
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        physicsBody = SKPhysicsBody(rectangleOfSize: texture.size())
        physicsBody?.dynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.usesPreciseCollisionDetection = true
        
        xScale = 0.25
        yScale = 0.25

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func rotateBullet(direction: CGPoint, rotateRadiansPerSec: CGFloat, dt: CFTimeInterval) -> Bool {
        let shortAngle = shortestAngleBetween(self.zRotation, angle2: direction.angle)
        
        var rotAmt = rotateRadiansPerSec * CGFloat(dt)
        
        rotAmt = min(rotAmt, abs(shortAngle))
        
        self.zRotation += rotAmt * shortAngle.sign()
        
        return Int(shortAngle) == 0
        
    }
    
}
