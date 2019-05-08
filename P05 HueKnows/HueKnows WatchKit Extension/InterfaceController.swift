//
//  InterfaceController.swift
//  HueKnows WatchKit Extension
//
//  Created by Rob Baldwin on 07/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications

class InterfaceController: WKInterfaceController {

    @IBOutlet var topLeftButton: WKInterfaceButton!
    @IBOutlet var topRightButton: WKInterfaceButton!
    @IBOutlet var btmLeftButton: WKInterfaceButton!
    @IBOutlet var btmRightButton: WKInterfaceButton!
    
    var buttons = [WKInterfaceButton]()
    var startTime = Date()
    
    var colors = [
        "Red": UIColor.red,
        "Green": UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
        "Blue": UIColor.blue,
        "Orange": UIColor.orange,
        "Purple": UIColor.purple,
        "Black": UIColor.black
    ]
    
    var currentLevel = 0 {
        didSet {
            setTitle("\(currentLevel)/10")
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        buttons += [topLeftButton, topRightButton, btmLeftButton, btmRightButton]
        startNewGame()
        setPlayReminder()
    }

    @IBAction func startNewGame() {
        startTime = Date()
        currentLevel = 0
        levelUp()
    }
    
    func levelUp() {
        if currentLevel == 10 {
            let playAgain = WKAlertAction(title: "Play Again", style: .default) {
                self.startNewGame()
            }
            let timePassed = Date().timeIntervalSince(startTime)
            presentAlert(withTitle: "You Win!", message: "You finished in \(Int(timePassed)) seconds", preferredStyle: .alert, actions: [playAgain])
            return
        }
        
        currentLevel += 1

        var colorKeys = Array(colors.keys)
        colorKeys.shuffle()
        buttons.shuffle()
        
        for (index, button) in buttons.enumerated() {
            button.setBackgroundColor(colors[colorKeys[index]])
            button.setEnabled(true)
            
            if index == 0 {
                button.setTitle(colorKeys[colorKeys.count - 1])
            } else {
                button.setTitle(colorKeys[index])
            }
        }
    }
    
    func buttonTapped(_ button: WKInterfaceButton) {
        if button == buttons[0] {
            levelUp()
        } else {
            button.setEnabled(false)
            
            if currentLevel > 0 {
                currentLevel -= 1
            }
        }
    }
    
    func createNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "We miss you!"
        content.body = "Come back and play the game some more!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "playReminder"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func setPlayReminder() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                center.removeAllPendingNotificationRequests()
                self.registerCategories()
                self.createNotification()
            }
        }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        let play = UNNotificationAction(identifier: "play", title: "Play Now", options: .foreground)
        let category = UNNotificationCategory(identifier: "playReminder", actions: [play], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
    
    @IBAction func topLeftButtonTapped() {
        buttonTapped(topLeftButton)
    }
    
    @IBAction func topRightButtonTapped() {
        buttonTapped(topRightButton)
    }
    
    @IBAction func btmLeftButtonTapped() {
        buttonTapped(btmLeftButton)
    }
    
    @IBAction func btmRightButtonTapped() {
        buttonTapped(btmRightButton)
    }
}
