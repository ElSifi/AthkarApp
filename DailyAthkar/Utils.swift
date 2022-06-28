//
//  Utils.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 8/26/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import Foundation
import UserNotifications
import DLLocalNotifications

class Utils: NSObject {
    
    static func scheduleLocalNotifications(completion: @escaping (_ result: Bool) -> Void){
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
                return completion(false)
            }else{
                let scheduler = DLNotificationScheduler()
                scheduler.cancelAlllNotifications()
                
                // Specify date components
                var morningDateComponents = DateComponents()
                morningDateComponents.hour = 7
                morningDateComponents.minute = 30
                let userCalendar = Calendar.current // user calendar
                
                let morning = DLNotification(identifier: "morning", alertTitle: "morning alert".localized, alertBody: "morning alert body".localized, fromDateComponents: morningDateComponents, repeatInterval: RepeatingInterval.daily)
                
                
                
                var eveningDateComponents = DateComponents()
                eveningDateComponents.hour = 17
                eveningDateComponents.minute = 30
                
                
                let evening = DLNotification(
                    identifier: "evening",
                    alertTitle: "evening alert".localized,
                    alertBody: "evening alert body".localized,
                    fromDateComponents: eveningDateComponents,
                    repeatInterval: RepeatingInterval.daily
                )
                
                scheduler.scheduleNotification(notification: morning)
                scheduler.scheduleNotification(notification: evening)
                return completion(true)
            }
        }
    }
    
    static func getThikrTextKey()->String{
        var textKey = "text_\(LanguageManager.currentLanguageCode()!)";

        let shouldDoTahskeel = ((StringKeys.SettingsItemTashkeel.savedValue as? String) ?? "true") == "true"
        let shouldShowTranslitration = ((StringKeys.SettingsItemTranslationOrTransLitration.savedValue as? String) ?? "") == "transliteration"
        let languageCode = LanguageManager.currentLanguageCode()!
        
        switch (languageCode) {
        case "ar":
            if(shouldDoTahskeel && DA_STYLE.savedFont.fontName != "Mohammad-Bold-Art-2"){
                textKey = "text_ar";
            }else{
                textKey = "text_ar_unsigned";
            }
        case "en":
            if(shouldShowTranslitration){
                textKey = "text_en_trans";
            }else{
                textKey = "text_en";
            }
        default:
            print("\(languageCode) not covered")
        }
        
        return textKey
        
    }
    
    static func getPathForSoundFileForThikr(thikr : ThikrCellViewModel, sectionID: String) -> String?{
        var path : String?
        let sheikhNamePrefix = "Mishary"
        let commonZikrTitle = thikr.thikrTitle
        if (commonZikrTitle != "")
        {
            path = Bundle.main.path(forResource: "\(sheikhNamePrefix)_\(commonZikrTitle)", ofType: "mp3")!
        } else {
            let zikrNum = thikr.number
            let resourceName = "\(sheikhNamePrefix)_\(sectionID)_\(zikrNum)".replacingOccurrences(of: " ", with: "")
            if let thePath = Bundle.main.path(forResource: resourceName, ofType: "mp3"){
                path = thePath
            }
            
        }
        return path
    }
}
