//
//  GameScene.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 2/18/16.
//  Copyright (c) 2016 Sean Maraia. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    let tower = Tower()
    
    var enemies = [Enemy]()
    
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    
    var lastTouchLocation = CGPoint.zero
    
    
    
    var touched = false
    override init(size: CGSize){
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        tower.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        tower.xScale = 0.25
        tower.yScale = 0.25
        addChild(tower)
        
        enemies.append(Enemy())
        for e in enemies{
            addChild(e)
        }
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
        
        if tower.shouldFire && touched && tower.canFire{
            tower.fire()
        }
        
        for e in enemies{
            e.update(tower.position, dt: dt)
        }
    }
    
    
    

}


