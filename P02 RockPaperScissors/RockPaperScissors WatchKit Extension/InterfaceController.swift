//
//  InterfaceController.swift
//  RockPaperScissors WatchKit Extension
//
//  Created by Rob Baldwin on 07/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var resultLabel: WKInterfaceLabel!
    @IBOutlet var questionImage: WKInterfaceImage!
    @IBOutlet var answersGroup: WKInterfaceGroup!
    @IBOutlet var button1: WKInterfaceButton!
    @IBOutlet var button2: WKInterfaceButton!
    @IBOutlet var button3: WKInterfaceButton!
    @IBOutlet var levelCounterLabel: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!
    
    var allMoves = ["rock", "paper", "scissors"]
    var allButtons = ["rock", "paper", "scissors"]
    var currentMove: String!
    var shouldWin = true
    var level = 1

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        timer.start()
        newLevel()
    }
    
    func newLevel() {
        
        if level == 21 {
            resultLabel.setHidden(false)
            questionImage.setHidden(true)
            answersGroup.setHidden(true)
            timer.stop()
            return
        }
        
        levelCounterLabel.setText("\(level)/20")
        
        if Bool.random() {
            setTitle("Win!")
            shouldWin = true
        } else {
            setTitle("Lose!")
            shouldWin = false
        }
        
        allMoves.shuffle()
        
        // Challenge 1: Sometimes the question picture shows the same move twice in a row, which can be confusing to the user. Can you write code that ensures the same move never happens twice in a row?
        
        if allMoves[0] == currentMove {
            currentMove = allMoves[1]
        } else {
            currentMove = allMoves[0]
        }

        questionImage.setImage(UIImage(named: currentMove))
        
        shuffleButtons()
    }
    
    // Challenge 2: Can you adjust newLevel() so that the rock, paper, and scissors buttons switch around each time?
    
    func shuffleButtons() {
        allButtons.shuffle()
        button1.setBackgroundImage(UIImage(named: allButtons[0]))
        button2.setBackgroundImage(UIImage(named: allButtons[1]))
        button3.setBackgroundImage(UIImage(named: allButtons[2]))
    }
    
    func check(for answer: String) {
        if currentMove == answer {
            level += 1
            newLevel()
        } else {
            level -= 1
            if level < 1 {
                level = 1
            }
            newLevel()
        }
    }
    
    func processAnswer(_ answer: String) {
        switch answer {
        case "rock":
            if shouldWin {
                check(for: "scissors")
            } else {
                check(for: "paper")
            }
        case "paper":
            if shouldWin {
                check(for: "rock")
            } else {
                check(for: "scissors")
            }
        case "scissors":
            if shouldWin {
                check(for: "paper")
            } else {
                check(for: "rock")
            }
        default:
            break
        }
    }
    
    @IBAction func button1Tapped() {
        processAnswer(allButtons[0])
    }
    
    @IBAction func button2Tapped() {
        processAnswer(allButtons[1])
    }
    
    @IBAction func button3Tapped() {
        processAnswer(allButtons[2])
    }
}
