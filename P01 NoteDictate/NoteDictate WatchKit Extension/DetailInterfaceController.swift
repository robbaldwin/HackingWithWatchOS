//
//  DetailInterfaceController.swift
//  NoteDictate WatchKit Extension
//
//  Created by Rob Baldwin on 06/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {

    @IBOutlet var textLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let contextDict = context as? [String: String] {
            textLabel.setText(contextDict["note"] ?? "")
            let index = contextDict["index"] ?? "1"
            
            let totalNotes = contextDict["totalNotes"] ?? "1"
            
            setTitle("Note \(index)/\(totalNotes)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
