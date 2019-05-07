//
//  InterfaceController.swift
//  WatchFX WatchKit Extension
//
//  Created by Rob Baldwin on 07/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var amountLabel: WKInterfaceLabel!
    @IBOutlet var amountSlider: WKInterfaceSlider!
    @IBOutlet var currencyPicker: WKInterfacePicker!
    
    static let currencies = ["USD", "AUD", "CAD", "CHF", "CNY", "EUR", "GBP", "HKD", "JPY", "SGD"]
    static let defaultCurrencies = ["USD", "EUR"]
    static let selectedCurrenciesKey = "SelectedCurrencies"
    
    var currentCurrency = "USD"
    var currentAmount = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        currentCurrency = UserDefaults.standard.value(forKey: "currentCurrency") as? String ?? "USD"
        currentAmount = UserDefaults.standard.value(forKey: "currentAmount") as? Int ?? 500
        amountLabel.setText(String(currentAmount))
        amountSlider.setValue(Float(currentAmount))
        
        var items = [WKPickerItem]()
        var selectedPickerIndex = 0
        
        for (index, currency) in InterfaceController.currencies.enumerated() {
            let item = WKPickerItem()
            item.title = currency
            items.append(item)
            
            if currency == currentCurrency {
                selectedPickerIndex = index
            }
        }
        
        currencyPicker.setItems(items)
        currencyPicker.setSelectedItemIndex(selectedPickerIndex)
    }
    
    @IBAction func convertTapped() {
        let context = [
            "amount": String(currentAmount),
            "base": currentCurrency
        ]
        
        WKInterfaceController.reloadRootPageControllers(withNames: ["Results"], contexts: [context], orientation: .horizontal, pageIndex: 0)
    }
    
    @IBAction func amountChanged(_ value: Float) {
        currentAmount = Int(value)
        amountLabel.setText(String(currentAmount))
        UserDefaults.standard.set(currentAmount, forKey: "currentAmount")
    }
    
    @IBAction func baseCurrencyChanged(_ value: Int) {
        currentCurrency = InterfaceController.currencies[value]
        UserDefaults.standard.set(currentCurrency, forKey: "currentCurrency")
    }
}
