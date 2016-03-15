//
//  PowerUp.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 3/1/16.
//  Copyright © 2016 Sean Maraia. All rights reserved.
//

import SpriteKit

enum FireType {
    case RapidFire
    case TripleShot
    case AreaEffect
    case Normal
}
//Passsed from PowerUpSprites to Towers that shoot them
struct PowerUp {
    var type: FireType
    var bulletsToSpawn: Int
    var cooldown: Double
    var explosive: Bool
    
    init(type: FireType){
        self.type = type
        switch type {
        case .AreaEffect:
            bulletsToSpawn = 1
            cooldown = 0.6
            explosive = true
        case .RapidFire:
            bulletsToSpawn = 1
            cooldown = 0.1
            explosive = false
        case .TripleShot:
            bulletsToSpawn = 3
            cooldown = 0.3
            explosive = false
        case .Normal:
            bulletsToSpawn = 1
            cooldown = 0.3
            explosive = false
        }
    }
}

//Objects for the Player to shoot to gain a PowerUp
class PowerUpSprite: SKSpriteNode{
    
    let moveSpeed: CGFloat = 5.0
    var type: FireType
    var direction: CGPoint
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    
    init(){
        let texture = SKTexture(imageNamed: "Powerup")
        
        switch arc4random_uniform(3) {
        case 0:
            type = .RapidFire
        case 1:
            type = .TripleShot
        case 2:
            type = .AreaEffect
        default:
            type = .RapidFire
        }
        direction = CGPoint(x: 1, y: 0)
        super.init(texture: texture, color: SKColor.redColor(), size: texture.size())
        self.name = "powerup"
        
        let quadrant = arc4random_uniform(4) + 1
        var tempX:CGFloat
        var tempY:CGFloat
        
        switch quadrant{
        case 1: //Left side
            tempX = -size.width * 2
            tempY = CGFloat.random(
                -size.height * 2,
                max: screenSize.height + size.height * 2)
        case 2: //Right side
            tempX = screenSize.width + (size.width * 2)
            tempY = CGFloat.random(
                -size.height * 2,
                max: screenSize.height + size.height * 2)
        case 3: //Bottom
            tempX = CGFloat.random(
                -size.width * 2,
                max: screenSize.width + size.width * 2)
            tempY = -size.height * 2
        case 4:  //Top
            tempX = CGFloat.random(
                -size.width * 2,
                max: screenSize.width + size.height * 2)
            tempY = screenSize.height + size.height * 2
        default:
            tempX = 0
            tempY = 0
        }
        
        
        
        self.position = CGPoint(
            x: tempX,
            y: tempY)
        self.xScale = 0.25
        self.yScale = 0.25
        
        
        physicsBody = SKPhysicsBody(texture: texture, alphaThreshold: 0.5, size: self.size)
        physicsBody?.dynamic = true
        physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Tower
        physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: CFTimeInterval){
        let actionDuration = 0.3
        let amountToMovePerSec = direction * self.moveSpeed
        let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
        let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
        runAction(moveAction)
    }
    
    
}
