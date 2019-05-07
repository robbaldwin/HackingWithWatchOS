//
//  CurrenciesInterfaceController.swift
//  WatchFX WatchKit Extension
//
//  Created by Rob Baldwin on 07/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class CurrenciesInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    
    let selectedColor = UIColor(red: 0, green: 0.55, blue: 0.25, alpha: 1)
    let deselectedColor = UIColor(red: 0.3, green: 0, blue: 0, alpha: 1)
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        table.setNumberOfRows(InterfaceController.currencies.count, withRowType: "Row")
        
        let selectedCountries = UserDefaults.standard.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        for (index, currency) in InterfaceController.currencies.enumerated() {
            guard let row = table.rowController(at: index) as? CurrencyRow else { continue }
            row.textLabel.setText(currency)
            if selectedCountries.contains(currency) {
                row.group.setBackgroundColor(selectedColor)
            } else {
                row.group.setBackgroundColor(deselectedColor)
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        guard let row = table.rowController(at: rowIndex) as? CurrencyRow else { return }
        var selectedCurrencies = UserDefaults.standard.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        let selectedCurrency = InterfaceController.currencies[rowIndex]
        if let index = selectedCurrencies.firstIndex(of: selectedCurrency) {
            selectedCurrencies.remove(at: index)
            row.group.setBackgroundColor(deselectedColor)
        } else {
            selectedCurrencies.append(selectedCurrency)
            row.group.setBackgroundColor(selectedColor)
        }
        
        UserDefaults.standard.set(selectedCurrencies, forKey: InterfaceController.selectedCurrenciesKey)
    }

}
