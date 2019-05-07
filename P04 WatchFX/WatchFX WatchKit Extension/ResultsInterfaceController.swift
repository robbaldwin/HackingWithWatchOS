//
//  ResultsInterfaceController.swift
//  WatchFX WatchKit Extension
//
//  Created by Rob Baldwin on 07/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import WatchKit
import Foundation


class ResultsInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    @IBOutlet var statusLabel: WKInterfaceLabel!
    @IBOutlet var doneButton: WKInterfaceButton!
    
    var fetchedCurrencies = [(symbol: String, rate: Double)]()
    var amountToConvert = 0.0
    let appID = "18bac06cd83a405797d73d7b66820925"
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let settings = context as? [String: String] else { return }
        guard
            let amount = settings["amount"],
            let baseCurrency = settings["base"]
            else { return}

        amountToConvert = Double(amount) ?? 50
        setTitle("\(amount) \(baseCurrency)")
        
        DispatchQueue.global(qos: .userInteractive).async {
            self.fetchData(for: baseCurrency)
        }
        
    }
    
    func fetchData(for baseCurrency: String) {
        guard let url = URL(string: "https://openexchangerates.org/api/latest.json?app_id=\(appID)&base=\(baseCurrency)") else { return }
        
        let urlRequest = URLRequest(url: url)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                self.parse(data)
            } else {
                DispatchQueue.main.async {
                    self.statusLabel.setText("Fetch failed")
                    self.doneButton.setHidden(false)
                }
            }
        }.resume()
    }
    
    func parse(_ contents: Data) {
        let decoder = JSONDecoder()
        
        guard let result = try? decoder.decode(CurrencyResult.self, from: contents) else {
            DispatchQueue.main.async {
                self.statusLabel.setText("Fetch failed")
                self.doneButton.setHidden(false)
            }
            return
        }
        
        let selectedCurrencies = UserDefaults.standard.array(forKey: InterfaceController.selectedCurrenciesKey) as? [String] ?? InterfaceController.defaultCurrencies
        
        for symbol in result.rates {
            guard selectedCurrencies.contains(symbol.key) else { continue }
            let rateName = symbol.key
            let rateValue = symbol.value
            fetchedCurrencies.append((symbol: rateName, rate: rateValue))
        }
        
        updateTable()
        statusLabel.setHidden(true)
        table.setHidden(false)
        doneButton.setHidden(false)
    }
    
    func updateTable() {
        table.setNumberOfRows(fetchedCurrencies.count, withRowType: "Row")
        
        for (index, currency) in fetchedCurrencies.enumerated() {
            guard let row = table.rowController(at: index) as? CurrencyRow else { return }
            let value = currency.rate * amountToConvert
            let formattedValue = String(format: "%.2f", value)
            row.textLabel.setText("\(formattedValue) \(currency.symbol)")
        }
    }
    
    @IBAction func doneButtonTapped() {
        WKInterfaceController.reloadRootPageControllers(withNames: ["Home", "Currencies"], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
    
    override func willActivate() {
        WKExtension.shared().isAutorotating = true
    }
    
    override func didDeactivate() {
        WKExtension.shared().isAutorotating = false
    }
}
