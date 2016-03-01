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

class AboutGameScene: SKScene {
    var instructionsText = "Made By Sean Maraia and Dennis Tung"
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        let newGame = SKSpriteNode(imageNamed: "newgamebtn")
        newGame.name = "backBtn"
        newGame.position = CGPointMake( frame.width / 2, frame.height / 4)
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
            if touchedNode.name == "backBtn"{
                let gameOverScene = StartGameScene(size: size)
                let transitionType = SKTransition.flipHorizontalWithDuration(0.25)
                view?.presentScene(gameOverScene, transition: transitionType)
            }
            
        }
    }
    
    
}
