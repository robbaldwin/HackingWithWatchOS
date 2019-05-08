//
//  InterfaceController.swift
//  UserInput WatchKit Extension
//
//  Created by Rob Baldwin on 08/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var textLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let url = getDocumentsDirectory().appendingPathComponent("recording.wav")
        do {
            try FileManager.default.removeItem(at: url)
            print("Existing recording deleted")
        } catch {
            print("No Existing recording found")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    @IBAction func dictateTapped() {
        presentTextInputController(withSuggestions: ["Test"], allowedInputMode: .plain) { result in
            guard let result = result?.first as? String else { return }
            self.textLabel.setText(result)
        }
    }
    
    @IBAction func multiInputTapped() {
        presentTextInputController(
            withSuggestions: [
            "Hacking with Swift",
            "Hacking with macOS",
            "Server-Side Swift"
            ],
            
            // NOTE: Animated Emoji is deprecated in WatchOS 5.0, so these will not work.
            allowedInputMode: .allowAnimatedEmoji) { result in
                if let result = result?.first as? String {
                    self.textLabel.setText(result)
                }
                self.dismiss()
        }
    }
    
    @IBAction func recordingTapped() {
        
        let saveURL = getDocumentsDirectory().appendingPathComponent("recording.wav")
        
        if FileManager.default.fileExists(atPath: saveURL.path) {
            let options = [WKMediaPlayerControllerOptionsAutoplayKey: "true"]
            presentMediaPlayerController(with: saveURL, options: options) { didPlayToEnd, endTime, error in
                // do nothing here
            }
        } else {
            let options: [String: Any] = [
                WKAudioRecorderControllerOptionsMaximumDurationKey: 60,
                WKAudioRecorderControllerOptionsActionTitleKey: "Done"
            ]
            
            presentAudioRecorderController(withOutputURL: saveURL, preset: .narrowBandSpeech, options: options) { success, error in
                if success {
                    print("Saved audio recording")
                } else {
                    print(error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }
}
