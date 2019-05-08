//
//  InterfaceController.swift
//  Animation WatchKit Extension
//
//  Created by Rob Baldwin on 08/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var image: WKInterfaceImage!
    
    var animation = 1
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        image.setTintColor(UIColor.white)
    }
    
    @IBAction func animateTapped() {
        animate(withDuration: 1) { [weak self] in
            switch self?.animation {
            
            case 1:
                self?.image.setAlpha(0.5)
            
            case 2:
                self?.image.setVerticalAlignment(.top)
                self?.image.setHorizontalAlignment(.right)
                
            case 3:
                self?.image.setRelativeWidth(0.1, withAdjustment: 0)
                self?.image.setRelativeHeight(0.1, withAdjustment: 0)
            
            case 4:
                self?.image.setWidth(25)
                self?.image.setHeight(25)
            
            case 5:
                self?.image.setTintColor(.red)
                
            case 6:
                self?.image.setTintColor(nil)
                self?.image.setAlpha(1)
                self?.image.setVerticalAlignment(.center)
                self?.image.setHorizontalAlignment(.center)
                self?.image.sizeToFitWidth()
                self?.image.sizeToFitHeight()
                
            case 7:
                self?.image.setImageNamed("Animation")
                self?.image.startAnimatingWithImages(in: NSRange(location: 0, length: 23), duration: 3, repeatCount: 0)

            default:
                self?.image.setImageNamed("star")
                self?.animation = 1
                self?.animateTapped()
                return
            }
            
            self?.animation += 1
        }
    }
}
