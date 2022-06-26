//
//  ThikrCellViewModel.swift
//  DailyAthkar
//
//  Created by badi3 on 26/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

class ThikrCellViewModel{
    
    private var thikr: Thikr
    
    init(thikr: Thikr){
        self.thikr = thikr
    }
    
    var zPk: String{
        return thikr.zPk
    }
    
    var thikrTitle: String{
        return thikr.thikrTitle
    }
    
    var number: String{
        return thikr.number
    }
    
    var textArUnsigned: String{
        return thikr.textArUnsigned
    }
    
    var repeatTimes: Int{
        return thikr.repeatTimes
    }
    
    var currentCount = 0
    
    
    func localizedText()->String {

        let shouldDoTahskeel = ((StringKeys.SettingsItemTashkeel.savedValue as? String) ?? "true") == "true"
        let shouldShowTranslitration = ((StringKeys.SettingsItemTranslationOrTransLitration.savedValue as? String) ?? "") == "transliteration"
        let languageCode = LanguageManager.currentLanguageCode()!
        
        switch (languageCode) {
        case "ar":
            if(shouldDoTahskeel && DA_STYLE.savedFont.fontName != "Mohammad-Bold-Art-2"){
                return thikr.textAr
            }else{
                return thikr.textArUnsigned
            }
        case "en":
            if(shouldShowTranslitration){
                return thikr.textEnTrans
            }else{
                return thikr.textEn
            }
        default:
            print("\(languageCode) not covered")
        }
        return "-"
    }
    
}
