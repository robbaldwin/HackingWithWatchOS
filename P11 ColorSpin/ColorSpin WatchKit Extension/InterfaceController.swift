//
//  InterfaceController.swift
//  ColorSpin WatchKit Extension
//
//  Created by Rob Baldwin on 09/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation
import SpriteKit

class InterfaceController: WKInterfaceController {

    @IBOutlet var gameInterface: WKInterfaceSKScene!
    
    var gameScene: GameScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        startGame(self)
    }
    
    override func didAppear() {
        crownSequencer.focus()
        crownSequencer.delegate = gameScene
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func startGame(_ sender: Any) {
        if gameScene != nil {
            guard gameScene.isPlayerAlive == false else { return }
        }
        
        gameScene = GameScene(size: CGSize(width: 154, height: 174))
        gameScene.parentInterfaceController = self
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //gameScene.scaleMode = .aspectFill
        let transition = SKTransition.doorway(withDuration: 1)
        gameInterface.presentScene(gameScene, transition: transition)

    }
}
