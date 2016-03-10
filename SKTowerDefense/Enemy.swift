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
    
    var moveSpeed:CGFloat = 5.0
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    let animation: SKAction
    
    init(){
        let texture = SKTexture(imageNamed: "Slime1")
        
        //Animations
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "Slime\(i)"))
        }
        animation = SKAction.animateWithTextures(textures,
            timePerFrame: 0.3)
        
        super.init(texture: texture, color: SKColor.clearColor(), size: texture.size())
        
        self.name = "enemy"
        
        let quadrant = arc4random_uniform(4) + 1
        var tempX:CGFloat
        var tempY:CGFloat
        
        switch quadrant{
        case 1: //Left side
            tempX = -20
            tempY = CGFloat.random(
                -100,
                max: screenSize.height + 100)
        case 2: //Right side
            tempX = screenSize.width + 80
            tempY = CGFloat.random(
                -100,
                max: screenSize.height + 100)
        case 3: //Bottom
            tempX = CGFloat.random(
                -20,
                max: screenSize.width + 80)
            tempY = -100
        case 4:  //Top
            tempX = CGFloat.random(
                -20,
                max: screenSize.width + 80)
            tempY = screenSize.height + 100
        default:
            tempX = 0
            tempY = 0
        }
        
        self.position = CGPoint(
            x: tempX,
            y: tempY)
        self.xScale = 0.6
        self.yScale = 0.6
        
        if(tempY >= screenSize.height || tempY <= 0){
            moveSpeed = 2.5
        }
        
        physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: self.size)
        physicsBody?.dynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Tower | PhysicsCategory.Explosion
        physicsBody?.collisionBitMask = PhysicsCategory.None
        self.runAction(
            SKAction.repeatActionForever(animation),
            withKey: "animation")
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
