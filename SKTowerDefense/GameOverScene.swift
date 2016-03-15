//
//  GameOverScene.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 3/15/16.
//  Copyright © 2016 Sean Maraia. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameOverScene: SKScene {
    var score = 0
    var instructionsText = "Game Over!"
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        let newGame = SKSpriteNode(imageNamed: "newgamebtn")
        newGame.name = "newGame"
        newGame.position = CGPointMake(frame.width / 2, frame.height / 4)
        newGame.setScale(0.75)
        addChild(newGame)
        
        let instructions = SKLabelNode(fontNamed: "CONQUEST")
        instructions.text = instructionsText
        instructions.position = CGPointMake(frame.width/2, frame.height / 2)
        addChild(instructions)
        self.view?.window?.rootViewController
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            let touchLoc = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(touchLoc)
            if touchedNode.name == "newGame"{
                let gameOverScene = GameScene(size: size)
                let transitionType = SKTransition.flipHorizontalWithDuration(0.25)
                view?.presentScene(gameOverScene, transition: transitionType)
            }
            
        }
    }
    
    
}
