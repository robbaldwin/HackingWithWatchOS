//
//  InterfaceController.swift
//  SafeCrack WatchKit Extension
//
//  Created by Rob Baldwin on 08/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet var numbersLabel: WKInterfaceLabel!
    @IBOutlet var safeValue: WKInterfaceSlider!
    @IBOutlet var nextButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    
    var currentSafeValue: Float = 50
    var targetSafeValue = 0
    
    var allSafeNumbers = [Int]()
    var correctValues = [String]()
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

    }
    
    override func didAppear() {
        crownSequencer.focus()
        crownSequencer.delegate = self
        startNewGame()
    }
    
    func startNewGame() {
        timer.setDate(Date())
        timer.start()
        
        allSafeNumbers = Array(0...100)
        allSafeNumbers.shuffle()
        
        currentSafeValue = 50
        safeValue.setValue(50)
        
        correctValues.removeAll()
        numbersLabel.setText("Safe Crack")
        
        pickNumber()
        
    }
    
    func pickNumber() {
        targetSafeValue = allSafeNumbers.removeFirst()
        print(targetSafeValue)
        numberIsWrong()
    }
    
    func numberIsWrong() {
        safeValue.setColor(UIColor.red)
        numbersLabel.setTextColor(UIColor.white)
        nextButton.setEnabled(false)
    }
    
    @IBAction func nextTapped() {
        guard Int(currentSafeValue) == targetSafeValue else { return }
        
        correctValues.append(String(targetSafeValue))
        
        numbersLabel.setText(correctValues.joined(separator: ", "))
        
        if correctValues.count == 4 {
            timer.stop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let playAgain = WKAlertAction(title: "Play again", style: .default, handler: {
                    self.startNewGame()
                })
                self.presentAlert(withTitle: "You Win!", message: nil, preferredStyle: .alert, actions: [playAgain])
            }
        } else {
            pickNumber()
        }
    }
    
    // Challenge: There’s a bug in this game, and perhaps it’s one you already spotted: we have + and - buttons on the slider, but they don’t do anything! These could be useful in the game for when the user has narrowed down the approximate range of the correct answer, but needs a finer-grained way to select between them. Connect an outlet to the slider and fix this bug.
    
    @IBAction func sliderChanged(_ value: Float) {
        currentSafeValue = min(max(0, value), 100)
        nextButton.setTitle("Enter \(Int(currentSafeValue))")
        
        checkCurrentSafeValue()
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        currentSafeValue += (Float(rotationalDelta) * 20)
        currentSafeValue = min(max(0, currentSafeValue), 100)
        safeValue.setValue(currentSafeValue)
        nextButton.setTitle("Enter \(Int(currentSafeValue))")
        
        checkCurrentSafeValue()
    }
    
    
    func checkCurrentSafeValue() {
        if Int(currentSafeValue) == targetSafeValue {
            WKInterfaceDevice.current().play(.click)
            safeValue.setColor(UIColor.green)
            numbersLabel.setTextColor(UIColor.green)
            nextButton.setEnabled(true)
        } else {
            numberIsWrong()
        }
    }
}
