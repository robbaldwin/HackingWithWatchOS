//
//  ComplicationController.swift
//  Magic8Ball WatchKit Extension
//
//  Created by Rob Baldwin on 08/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let positiveAnswers: Set<String> = [
        "It is certain",
        "It is decidedly so",
        "Without a doubt",
        "Yes definitely",
        "As I see it, yes",
        "Most likely",
        "Outlook good",
        "Yes",
        "Signs point to yes"
    ]
    
    let uncertainAnswers: Set<String> = [
        "Reply hazy, try again",
        "Ask again later",
        "Better not tell you now",
        "Cannot predict now",
        "Concentrate and ask again"
    ]
    
    let negativeAnswers: Set<String> = [
        "Don't count on it",
        "My reply is no",
        "My sources say no",
        "Outlook not so good",
        "Very doubtful"
    ]
    
    var allAnswers = [String]()
    
    // MARK: - Timeline Configuration
    
    // Report back whether the complication supports backwards time travel, forwards time travel, or neither.
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
        //handler([]) // None
    }
    
    // Return the earliest date you have time travel information for
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let startDate = Date().addingTimeInterval(-86400) // 24 hours
        handler(startDate)
    }
    
    // Return the latest date you have time travel information for
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let endDate = Date().addingTimeInterval(86400)
        handler(endDate)
    }
    
    // Can return either .showOnLockScreen if the complication doesn’t show sensitive data, or .hideOnLockScreen if it should be hidden when the device is locked
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    // Return the current information to show on the watch face.
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        allAnswers = Array(positiveAnswers) + Array(uncertainAnswers) + Array(negativeAnswers)
        
        getTimelineEntries(for: complication, before: Date(), limit: 1) {
            handler($0?.first)
        }
    }
    
    // Give me all your time travel data before a specific date
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date

        var entries = [CLKComplicationTimelineEntry]()
        
        for i in (0 ..< limit).reversed() {
            let predictionDate = date.addingTimeInterval(Double(-60 * 5 * i))
            let predictionTemplate = template(for: complication.family, date: predictionDate)
            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
            entries.append(entry)
        }
        
        handler(entries)
    }
    
    // Give me all your time travel data after a specific date.
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date

        var entries = [CLKComplicationTimelineEntry]()
        
        for i in 0 ..< limit {
            let predictionDate = date.addingTimeInterval(Double(60 * 5 * i))
            let predictionTemplate = template(for: complication.family, date: predictionDate)
            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
            entries.append(entry)
        }
        
        handler(entries)
        
    }
    
    // MARK: - Placeholder Templates
    
    // Return some useful dummy data giving users an idea of what to expect if they install your app.
    // If you intend to change your sample template you should restart the Apple Watch simulator to make sure it’s refreshed.
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached

        switch complication.family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Magic 8-Ball", shortText: "8-Ball")
            template.body1TextProvider = CLKSimpleTextProvider(text: "Your Predication", shortText: "Predication")
            handler(template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "🎱")
            handler(template)
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "Magic 8-Ball")
            handler(template)
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: "🎱")
            handler(template)
        default:
            handler(nil)
        }
    }
    
    func template(for family: CLKComplicationFamily, date: Date) -> CLKComplicationTemplate {
        let predictionNumber = Int(date.timeIntervalSince1970) % allAnswers.count
        let prediction = allAnswers[predictionNumber]
        
        switch family {
        case .modularLarge:
            let template = CLKComplicationTemplateModularLargeStandardBody()
            template.headerTextProvider = CLKSimpleTextProvider(text: "Magic 8-Ball")
            template.body1TextProvider = CLKSimpleTextProvider(text: prediction)
            return template
        
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKSimpleTextProvider(text: "🎱 \(prediction)")
            return template
            
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeSimpleText()
            
            if positiveAnswers.contains(prediction) {
                template.textProvider = CLKSimpleTextProvider(text: "😀")
            } else if uncertainAnswers.contains(prediction) {
                template.textProvider = CLKSimpleTextProvider(text: "🤔")
            } else {
                template.textProvider = CLKSimpleTextProvider(text: "😧")
            }
            
            return template
            
        default:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            
            if positiveAnswers.contains(prediction) {
                template.textProvider = CLKSimpleTextProvider(text: "😀")
            } else if uncertainAnswers.contains(prediction) {
                template.textProvider = CLKSimpleTextProvider(text: "🤔")
            } else {
                template.textProvider = CLKSimpleTextProvider(text: "😧")
            }
            
            return template
        }
    }
}
