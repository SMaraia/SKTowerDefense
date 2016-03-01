//
//  StartGameScene.swift
//  SKTowerDefense
//
//  Created by Sean Maraia on 2/29/16.
//  Copyright (c) 2016 Sean Maraia. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class StartGameScene: SKScene {
    var score = 0
    var instructionsText = "Instructions: Tap to turn and fire"
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        let newGame = SKSpriteNode(imageNamed: "newgamebtn")
        newGame.name = "newGame"
        newGame.position = CGPointMake(2 * frame.width / 3 + 50, frame.height / 4)
        newGame.setScale(0.75)
        addChild(newGame)
        let about = SKSpriteNode(imageNamed: "aboutBtn")
        about.name = "about"
        about.position = CGPointMake(frame.width / 3 - 50, frame.height / 4)
        about.setScale(0.75)
        addChild(about)
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
            } else if touchedNode.name == "about"{
                let gameOverScene = AboutGameScene(size: size)
                let transitionType = SKTransition.flipHorizontalWithDuration(0.25)
                view?.presentScene(gameOverScene, transition: transitionType)
            }
            
        }
    }
    
    
}
