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
    static let PowerUp    : UInt32 = 0b1000
    static let Explosion  : UInt32 = 0b10000
}

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    
    let tower = Tower()
    
    var enemies = [Enemy]()
    var canSpawn: Bool = true
    
    var wave = 0;
    var waveText: SKLabelNode = SKLabelNode(fontNamed: "CONQUEST")
    var waveTimer = 4
    
    var currentPowerUpNode: [PowerUpSprite]
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    
    var lastTouchLocation = CGPoint.zero
    let playableRect: CGRect

    var debugRapidFire = PowerUp(type: .RapidFire)
    var debugNormal = PowerUp(type: .Normal)
    var debugTripleShot = PowerUp(type: .TripleShot)
    var debugAreaEffect = PowerUp(type: .AreaEffect)
    
    var debugFireTypes : [PowerUp]
    var currentFireType: Int = 0
    
    var lives: Int = 5{
        didSet{
            if (livesText?.text != nil){
                livesText?.text = "Lives: \(lives)"
            }
        
            if (lives == 0) {
                let gameOverScene = GameOverScene(size: size)
                let transitionType = SKTransition.flipHorizontalWithDuration(0.25)
                view?.presentScene(gameOverScene, transition: transitionType)

            }
        }
    }
    
    var livesText: SKLabelNode?
    
    var touched = false
    
    
    override init(size: CGSize){
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)

        debugFireTypes = []
        debugFireTypes.append(debugNormal)
        debugFireTypes.append(debugRapidFire)
        debugFireTypes.append(debugTripleShot)
        debugFireTypes.append(debugAreaEffect)
        
        currentPowerUpNode = []
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5) // default
        background.zPosition = -2
        background.size.width = size.width
        background.size.height = size.height
        addChild(background)
        
        
        livesText = SKLabelNode(fontNamed: "CONQUEST")
        livesText?.text = "Lives: \(lives)"
        livesText?.position = CGPoint(x: livesText!.frame.width / 2, y: livesText!.frame.height / 2)
        livesText?.zPosition = 100
        addChild(livesText!)
        
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        let towerBase = SKSpriteNode(imageNamed: "TowerBase")
        towerBase.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        towerBase.xScale = 0.5
        towerBase.yScale = 0.5
        towerBase.zPosition = -1
        addChild(towerBase)
        
        tower.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        tower.xScale = 0.35
        tower.yScale = 0.35
        addChild(tower)
        
        
        let pinch = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.view!.addGestureRecognizer(pinch)
        
        
        waveText.text = ""
        waveText.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) + 50)
        waveText.zPosition = 100
        addChild(waveText)
        
        spawnEnemies()
        
        let powerUpTimer = NSTimer(timeInterval: 10.0, target: self, selector: "spawnPowerUp", userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(powerUpTimer, forMode: NSRunLoopCommonModes)
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer) {
        touched = false
        if sender.state == .Ended {
            if sender.scale > 1 {
                print("Pinched Out")
            } else if sender.scale < 1 {
                print("Pinched In")
                currentFireType = (currentFireType + 1) % debugFireTypes.count
                tower.applyPowerUp(debugFireTypes[currentFireType])
                print(debugFireTypes[currentFireType].type)
            }
        }
    }
    
    func spawnPowerUp() {
        let powerUpNode = PowerUpSprite()
        addChild(powerUpNode)
        let clearAction = SKAction.runBlock() {
            self.currentPowerUpNode = []
        }
        powerUpNode.runAction(SKAction.sequence([SKAction.waitForDuration(7.5), clearAction, SKAction.removeFromParent()]))
        currentPowerUpNode.append(powerUpNode)
        
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
            if e.position.x > size.width || e.position.x < 0 || e.position.y > size.height || e.position.y < 0 {
                let point = onscreenVectorVersion(size, position: e.position)
                let alertNode = SKSpriteNode(imageNamed: "alert")
                alertNode.position = point
                alertNode.xScale = 0.5
                alertNode.yScale = 0.5
                addChild(alertNode)
                alertNode.runAction(SKAction.sequence([SKAction.waitForDuration(dt), SKAction.removeFromParent()]))
            }
        }
        
        if enemies.count == 0{
            if(canSpawn){
                canSpawn = false
                wave += 1
                //print("A new wave has started")
                let nextWaveTimer = NSTimer(timeInterval: 3.0, target: self, selector: "spawnEnemies", userInfo: nil, repeats: false)
                //Timer starts
                NSRunLoop.mainRunLoop().addTimer(nextWaveTimer, forMode: NSRunLoopCommonModes)
                //3 2 1 to screen
                startWaveTimer()
            }
        }
        
        if(currentPowerUpNode.count > 0) {
            currentPowerUpNode[0].update(dt)
            //for p in currentPowerUpNode{
                //p.update(dt)
            //}
        }
    }
    
    func projectileHitEnemy(enemy: Enemy, projectile: Bullet) {
        if(tower.bulletsExplode){
            let explosion = Bullet()
            explosion.alpha = 0.0
            //explosion.physicsBody?.categoryBitMask = PhysicsCategory.Explosion
            explosion.position = projectile.position
            explosion.yScale = 0.7
            explosion.xScale = 0.7
            
            let explosionParticle = SKEmitterNode(fileNamed: "Explosion AoE.sks")!
            explosionParticle.position = explosion.position
            explosionParticle.yScale = explosion.yScale
            explosionParticle.xScale = explosion.xScale
            
            addChild(explosion)
            addChild(explosionParticle)

            
            //Set timers to remove the explosion and the particle in 3 seconds
            let exploDuration = NSTimer(timeInterval: 3.0, target: self, selector: "removeExplosion:", userInfo: explosion, repeats: false)
            //Timer starts
            NSRunLoop.mainRunLoop().addTimer(exploDuration, forMode: NSRunLoopCommonModes)
            let exploDuration2 = NSTimer(timeInterval: 3.0, target: self, selector: "removeExplosion:", userInfo: explosionParticle, repeats: false)
            //Timer starts
            NSRunLoop.mainRunLoop().addTimer(exploDuration2, forMode: NSRunLoopCommonModes)
        }
        projectile.removeFromParent()
        enemies.removeAtIndex(enemies.indexOf(enemy)!)
        enemy.removeFromParent()
    }
    
    func removeExplosion(timer: NSTimer){
        print("test")
        print(timer.userInfo)
        timer.userInfo!.removeFromParent()
        //explosionParticle.removeFromParent()
    }
    
    
    func projectileHitPowerUp( projectile: Bullet, powerUpNode: PowerUpSprite) {
        
        let powerUp = PowerUp(type: powerUpNode.type)
        tower.applyPowerUp(powerUp)
        
        projectile.removeFromParent()
        powerUpNode.removeFromParent()
        
        currentPowerUpNode = []
    }
    
    func towerHitEnemy(enemy: Enemy, tower: Tower) {
        lives -= 1
        enemies.removeAtIndex(enemies.indexOf(enemy)!)
        enemy.removeFromParent()
        //TODO: tower.takeDamage()
    }
    
    func explosionClippedEnemy(enemy: Enemy) {
        enemies.removeAtIndex(enemies.indexOf(enemy)!)
        enemy.removeFromParent()
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
            projectileHitEnemy(firstBody.node as! Enemy, projectile: secondBody.node as! Bullet)
            
        } else if(firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Tower != 0) {
            towerHitEnemy(firstBody.node as! Enemy, tower: secondBody.node as! Tower)
            
        } else if (firstBody.categoryBitMask & PhysicsCategory.Projectile != 0) && (secondBody.categoryBitMask & PhysicsCategory.PowerUp != 0) {
            projectileHitPowerUp(firstBody.node as! Bullet, powerUpNode: secondBody.node as! PowerUpSprite)
        } else if (firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Explosion != 0) {
            explosionClippedEnemy(firstBody.node as! Enemy)
        }
    }

    
    // MARK: - UIGestureRecognizerDelegate Methods -
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
         shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    func spawnEnemies(){
        canSpawn = true
        let fib = calcFibonacciNumber(wave)
        let enemiesToSpawn = fib > 50 ? 50: fib
        for _ in 0...enemiesToSpawn {
            self.enemies.append(Enemy())
        }
        for e in enemies{
            addChild(e)
        }
    }
    
    func startWaveTimer(){
        let nextWaveTimerText = NSTimer(timeInterval: 1.0, target: self, selector: "timerFlash", userInfo: nil, repeats: false)
        //Timer starts
        NSRunLoop.mainRunLoop().addTimer(nextWaveTimerText, forMode: NSRunLoopCommonModes)
    }
    
    func timerFlash(){
        waveText.text = "Next wave in: \(waveTimer - 1)"
        waveTimer -= 1
        if(waveTimer > 0){
            self.startWaveTimer()
        }
        if(waveTimer <= 0){
            waveText.text = ""
            waveTimer = 4
        }
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