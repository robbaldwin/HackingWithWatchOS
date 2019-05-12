//
//  InterfaceController.swift
//  Watch-Connectivity WatchKit Extension
//
//  Created by Rob Baldwin on 12/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var receivedData: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func sendDataTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated {
            let data = ["text": "Hello from the watch"]
            session.transferUserInfo(data)
        }
    }
    
    // MARK: - WCSession Delegate Method
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    // Receive User Info (this is also where complication data is delivered! - due to the 50 daily limit)
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let text = userInfo["text"] as? String {
                self.receivedData.setText(text)
            } else if let number = userInfo["number"] as? String {
                UserDefaults.standard.set(number, forKey: "complication_number")
                let server = CLKComplicationServer.sharedInstance()
                guard let complications = server.activeComplications else { return }
                for complication in complications {
                    server.reloadTimeline(for: complication)
                }
            }
        }
    }
    
    // Receive Message
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                self.receivedData.setText(text)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        DispatchQueue.main.async {
            if let text = message["text"] as? String {
                //user our message data locally
                self.receivedData.setText(text)
                
                //send back our reply
                replyHandler(["response": "Response from the watch"])
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Application state received")
        print(applicationContext)
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("File received!")
        
        // create a URL representing where to save the file
        let fm = FileManager.default
        let destURL = getDocumentsDirectory().appendingPathComponent("saved_file")
        
        do {
            if fm.fileExists(atPath: destURL.path) {
                // the file already exists – delete it!
                try fm.removeItem(at: destURL)
            }
            
            // copy the file from its temporary location
            try fm.copyItem(at: file.fileURL, to: destURL)
            
            // load the file and print it out
            let contents = try String(contentsOf: destURL)
            print(contents)
        } catch {
            // something went wrong!
            print("File copy failed.")
        }
    }
}
