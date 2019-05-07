//
//  InterfaceController.swift
//  StoringData WatchKit Extension
//
//  Created by Rob Baldwin on 07/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        testUserDefaults()
        testUserDefaults()
        testKeychain()
        testKeychain()
        testFile()
        testFile()
    }
    
    
    // User Defaults
    func testUserDefaults() {
        if let contents = UserDefaults.standard.string(forKey: "sharedDefault") {
            // saved data was found
            print("Reading from User Defaults")
            print(contents)
        } else {
            // no data was found
            print("Writing to User Defaults")
            UserDefaults.standard.set("This is the saved default.", forKey: "sharedDefault")
        }
    }
    
    // Keychain (using KeychainWrapper)
    func testKeychain() {
        if let contents = KeychainWrapper.standard.string(forKey: "sharedKeychain") {
            // saved data was found
            print("Reading from Keychain")
            print(contents)
        } else {
            // no data was found
            print("Writing to Keychain")
            KeychainWrapper.standard.set("This is the saved keychain.", forKey: "sharedKeychain")
        }
    }
    
    // Documents Directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func testFile() {
        let saveURL = getDocumentsDirectory().appendingPathComponent("sharedFile")
        
        if let contents = try? String(contentsOf: saveURL) {
            print("Reading from File")
            print(contents)
        } else {
            print("Writing to File")
            try? "This is the saved file".write(to: saveURL, atomically: true, encoding: .utf8)
        }
    }
}
