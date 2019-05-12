//
//  InterfaceController.swift
//  iMove WatchKit Extension
//
//  Created by Rob Baldwin on 08/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//


import Foundation
import HealthKit
import WatchKit

class InterfaceController: WKInterfaceController {

    @IBOutlet var activityTypePicker: WKInterfacePicker!
    
    let activities: [(String, HKWorkoutActivityType)] = [
        ("Cycling", .cycling),
        ("Running", .running),
        ("Swimming", .swimming),
        ("Wheelchair", .wheelchairRunPace)
    ]
    
    var selectedActivity = HKWorkoutActivityType.cycling
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var items = [WKPickerItem]()
        
        for activity in activities {
            let item = WKPickerItem()
            item.title = activity.0
            items.append(item)
        }
        
        activityTypePicker.setItems(items)
    }

    @IBAction func activityTypePickerChanged(_ value: Int) {
        selectedActivity = activities[value].1
        
    }
    
    @IBAction func startWorkoutButtonTapped() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        WKInterfaceController.reloadRootPageControllers(withNames: ["WorkoutInterfaceController"], contexts: [selectedActivity], orientation: .horizontal, pageIndex: 0)
    }
}
