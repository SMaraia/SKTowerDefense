//
//  Tower.swift
//  SKTowerDefense
//
//  Created by Dennis Tung on 3/1/16.
//  Copyright © 2016 Dennis Tung. All rights reserved.
//

import SpriteKit

class Enemy: SKSpriteNode{
    
    var rotDir: CGPoint = CGPoint.zero
    
    let moveSpeed:CGFloat = 5.0
    
    
    init(){
        let texture = SKTexture(imageNamed: "Spaceship")
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        
        self.name = "enemy"
        self.position = CGPoint(
            x: 0,
            y: 0)
        
        physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: self.size)
        physicsBody?.dynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Tower
        physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(target: CGPoint, dt: CFTimeInterval){
        let actionDuration = 0.3
        let vector = target - self.position
        let direction = vector.normalized()
        let amountToMovePerSec = direction * self.moveSpeed
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
        runAction(moveAction)
    }

    
    func rotateTower(direction: CGPoint, rotateRadiansPerSec: CGFloat, dt: CFTimeInterval) -> Bool {
        let shortAngle = shortestAngleBetween(self.zRotation, angle2: direction.angle)
        
        var rotAmt = rotateRadiansPerSec * CGFloat(dt)
        
        rotAmt = min(rotAmt, abs(shortAngle))
        
        self.zRotation += rotAmt * shortAngle.sign()
        
        return Int(shortAngle) == 0
    }
}
