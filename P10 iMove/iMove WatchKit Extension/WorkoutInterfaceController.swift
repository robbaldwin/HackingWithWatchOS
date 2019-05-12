//
//  WorkoutInterfaceController.swift
//  iMove WatchKit Extension
//
//  Created by Rob Baldwin on 08/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

enum DisplayMode {
    case distance, energy, heartRate
}

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {

    @IBOutlet var quantityLabel: WKInterfaceLabel!
    @IBOutlet var unitLabel: WKInterfaceLabel!
    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var resumeButton: WKInterfaceButton!
    @IBOutlet var endButton: WKInterfaceButton!

    var healthStore: HKHealthStore?
    var distanceType = HKQuantityTypeIdentifier.distanceCycling
    var workoutStartDate = Date()
    var workoutEndDate = Date()
    var activeDataQueries = [HKQuery]()
    var workoutSession: HKWorkoutSession?
    
    var displayMode = DisplayMode.distance
    var totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 0)
    var totalDistance = HKQuantity(unit: .meter(), doubleValue: 0)
    var lastHeartRate = 0.0
    let countPerMinuteUnit = HKUnit(from: "count/min")
    var workoutIsActive = true
    var hasPresentedHeartRateWarning = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let activity = context as? HKWorkoutActivityType else { return }
        
        switch activity {
        case .cycling:
            distanceType = .distanceCycling
        case .running:
            distanceType = .distanceWalkingRunning
        case .swimming:
            distanceType = .distanceSwimming
        default:
            distanceType = .distanceWheelchair
        }
        
        let sampleTypes: Set<HKSampleType> = [
            .workoutType(),
            HKSampleType.quantityType(forIdentifier: .heartRate)!,
            HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKSampleType.quantityType(forIdentifier: .distanceCycling)!,
            HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKSampleType.quantityType(forIdentifier: .distanceSwimming)!,
            HKSampleType.quantityType(forIdentifier: .distanceWheelchair)!
        ]
        
        healthStore = HKHealthStore()
        
        healthStore?.requestAuthorization(toShare: sampleTypes, read: sampleTypes, completion: { success, error in
            if success {
                self.startWorkout(type: activity)
            } else {
                print(error?.localizedDescription ?? "")
            }
        })
    }

    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // Only data points after our workout start date
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictStartDate)
        
        // Only data points that come from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // Combine predicates
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
        
        // Code to receive results
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            self.process(samples, type: quantityTypeIdentifier)
        }
        
        // Query out of our type predicate and result handling code
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: queryPredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        // Tell HK to re-run the code every time new data in available
        query.updateHandler = updateHandler
        
        // Start the query running
        healthStore?.execute(query)
        
        // Store the query so we can stop it later
        activeDataQueries.append(query)
    }
    
    func startQueries() {
        startQuery(quantityTypeIdentifier: distanceType)
        startQuery(quantityTypeIdentifier: .activeEnergyBurned)
        startQuery(quantityTypeIdentifier: .heartRate)
        WKInterfaceDevice.current().play(.start)
    }
    
    func startWorkout(type: HKWorkoutActivityType) {
        
        guard let healthStore = healthStore else { return }
        
        // Create a workout configuration
        let config = HKWorkoutConfiguration()
        config.activityType = type
        config.locationType = .outdoor
        
        // Create a workout session
        if let session = try? HKWorkoutSession(healthStore: healthStore, configuration: config) {
            workoutSession = session
            
            // reset start date
            workoutStartDate = Date()
            
            // start the workout
            session.startActivity(with: workoutStartDate)

            // register to receive status updates
            session.delegate = self
        }
    }
    
    func updateLabels() {
        switch displayMode {
            
        case .distance:
            let meters = totalDistance.doubleValue(for: .meter())
            let kilometers = meters / 1000
            let formattedKilometers = String(format: "%.2f", kilometers)
            
            quantityLabel.setText(formattedKilometers)
            unitLabel.setText("KILOMETERS")
            
        case .energy:
            let kilocalories = totalEnergyBurned.doubleValue(for: .kilocalorie())
            let formatterKilocalories = String(format: "%.0f", kilocalories)
            quantityLabel.setText(formatterKilocalories)
            unitLabel.setText("CALORIES")
            
        case .heartRate:
            let heartRate = String(Int(lastHeartRate))
            quantityLabel.setText(heartRate)
            unitLabel.setText("BEATS / MINUTE")
            
        }
    }
    
    func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        
        // ignore updates whilst paused
        guard workoutIsActive else { return }
        
        // loop over samples
        for sample in samples {
            if type == .activeEnergyBurned {
                let newEnergy = sample.quantity.doubleValue(for: .kilocalorie())
                let currentEnergy = totalEnergyBurned.doubleValue(for: .kilocalorie())
                totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: currentEnergy + newEnergy)
                print("Total Energy: \(totalEnergyBurned)")
            } else if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: countPerMinuteUnit)
                checkHeartRate()
                print("Last heart rate: \(lastHeartRate)")
            } else if type == distanceType {
                let newDistance = sample.quantity.doubleValue(for: .meter())
                let currentDistance = totalDistance.doubleValue(for: .meter())
                totalDistance = HKQuantity(unit: .meter(), doubleValue: currentDistance + newDistance)
                print("Total distance: \(totalDistance)")
            }
        }
        
        updateLabels()
    }
    
    func checkHeartRate() {
        if lastHeartRate > 165 {
            guard !hasPresentedHeartRateWarning else { return }
            
            hasPresentedHeartRateWarning = true
            WKInterfaceDevice.current().play(.notification)
            let ok = WKAlertAction(title: "OK", style: .default) { [weak self] in
                self?.dismiss()
            }
            presentAlert(withTitle: "HEART RATE HIGH", message: "Slow down a little", preferredStyle: .alert, actions: [ok])
        }
    }
    
    @IBAction func changeDisplayMode() {
        switch displayMode {
        case .distance:
            displayMode = .energy
        case .energy:
            displayMode = .heartRate
        case .heartRate:
            displayMode = .distance
        }
        
        updateLabels()
    }
    
    func cleanUpQueries() {
        for query in activeDataQueries {
            healthStore?.stop(query)
        }
        
        activeDataQueries.removeAll()
    }
    
    func save(_ workoutSession: HKWorkoutSession) {
        
        let save = WKAlertAction(title: "Save", style: .default) {
            let config = workoutSession.workoutConfiguration
            let workout = HKWorkout(
                activityType: config.activityType,
                start: self.workoutStartDate,
                end: self.workoutEndDate,
                workoutEvents: nil,
                totalEnergyBurned: self.totalEnergyBurned,
                totalDistance: self.totalDistance,
                metadata: [HKMetadataKeyIndoorWorkout: false])
            self.healthStore?.save(workout, withCompletion: { success, error in
                if success {
                    DispatchQueue.main.async {
                        WKInterfaceController.reloadRootPageControllers(withNames: ["InterfaceController"], contexts: nil, orientation: .horizontal, pageIndex: 0)
                    }
                } else {
                    print("Failed to save data")
                }
            })
        }
        let discard = WKAlertAction(title: "Discard", style: .destructive) {
            WKInterfaceController.reloadRootPageControllers(withNames: ["InterfaceController"], contexts: nil, orientation: .horizontal, pageIndex: 0)
        }
        presentAlert(withTitle: "Save Data", message: "to Health App", preferredStyle: .alert, actions: [save, discard])
    }
    
    @IBAction func stopWorkoutTapped() {
        guard let workoutSession = workoutSession else { return }
        
        stopButton.setHidden(true)
        resumeButton.setHidden(false)
        endButton.setHidden(false)
        
        workoutSession.pause()
    }
    
    @IBAction func resumeWorkoutTapped() {
        guard let workoutSession = workoutSession else { return }
        
        stopButton.setHidden(false)
        resumeButton.setHidden(true)
        endButton.setHidden(true)
        
        workoutSession.resume()
    }
    
    @IBAction func endWorkoutTapped() {
        guard let workoutSession = workoutSession else { return }
        
        workoutEndDate = Date()
        workoutSession.end()
    }
    
    // MARK: - HKWorkoutSessionDelegate Methods
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            if fromState == .notStarted {
                if distanceType == .distanceSwimming {
                    WKExtension.shared().enableWaterLock()
                }
                startQueries()
            } else {
                workoutIsActive = true
            }
        
        case .paused:
            workoutIsActive = false
            
        case .ended:
            workoutIsActive = false
            cleanUpQueries()
            
            DispatchQueue.main.async { [weak self] in
                self?.save(workoutSession)
            }
    
        default:
            break
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        //
    }
}
