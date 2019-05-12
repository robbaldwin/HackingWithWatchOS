//
//  ViewController.swift
//  Watch-Connectivity
//
//  Created by Rob Baldwin on 12/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    

    @IBOutlet var receivedData: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        let complication = UIBarButtonItem(title: "Complication", style: .plain, target: self, action: #selector(sendComplicationTapped))
        let message = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(sendMessageTapped))
        let appInfo = UIBarButtonItem(title: "Context", style: .plain, target: self, action: #selector(sendAppContextTapped))
        let file = UIBarButtonItem(title: "File", style: .plain, target: self, action: #selector(sendFileTapped))
        navigationItem.leftBarButtonItems = [complication, message, appInfo, file]
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @objc func sendMessageTapped() {
        let session = WCSession.default
        
        
        // transferUserInfo - Guarentees delivery
//        if session.activationState == .activated {
//            let data = ["text": "User info from the phone"]
//            session.transferUserInfo(data)
//        }
        
        if session.isReachable {
            let data = ["text": "A message from the phone"]
            session.sendMessage(data, replyHandler: { response in
                DispatchQueue.main.async {
                    self.receivedData.text = "Received response: \(response)"
                }
                
            }) { error in
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func sendAppContextTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated {
            let data = ["text": "Hello from the phone"]
            
            do {
                try session.updateApplicationContext(data)
            } catch {
                print("Updating App Context failed")
            }
        }
    }
    
    @objc func sendComplicationTapped() {
        let session = WCSession.default
        
        if session.activationState == .activated && session.isComplicationEnabled {
            let randomNumber = String(Int.random(in: 0...9))
            let message = ["number": randomNumber]
            
            session.transferCurrentComplicationUserInfo(message)
            
            print("Attempted to send complication data.  Remaining tranfers: \(session.remainingComplicationUserInfoTransfers)")
        }
    }
    
    @objc func sendFileTapped() {
        
        print("Send file")
        
        let session = WCSession.default
        
        if session.activationState == .activated {
            // create URL
            let sourceURL = getDocumentsDirectory().appendingPathComponent("saved_file")
            
            if FileManager.default.fileExists(atPath: sourceURL.path) {
                try? "Hello, from a phone file!".write(to: sourceURL, atomically: true, encoding: .utf8)
            }
            
            session.transferFile(sourceURL, metadata: nil)
        }
    }
    
    // MARK: - WCSession Delegate Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            
            switch activationState {
            case .activated:
                if session.isWatchAppInstalled {
                    self.receivedData.text = "Watch app is installed"
                }
            case .inactive:
                self.receivedData.text = "Watch activation - inactive"
            case .notActivated:
                self.receivedData.text = "Watch activation - not activated"
            @unknown default:
                fatalError()
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let text = userInfo["text"] as? String {
                self.receivedData.text = text
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }

}

