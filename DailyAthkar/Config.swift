//
//  Config.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 5/1/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit

let allImages = [#imageLiteral(resourceName: "bg1"), #imageLiteral(resourceName: "bg2")]
let theBGImage = allImages.randomItem()!

var currentLanguageMode : LanguageMode {
    return LanguageMode.init(rawValue: LanguageManager.currentLanguageCode()!.lowercased())!
}

extension UIColor{
    static let primary = UIColor.brown
}

enum LanguageMode : String{
    case english = "en"
    case arabic = "ar"
}

struct DA_STYLE {
    
    struct arabicFonts {
        static let noorHiraFont = UIFont.init(name: "noorehira", size: 23)!
        static let AlQalamQuranMajeed1 = UIFont.init(name: "AlQalamQuranMajeed1", size: 24)!
        static let AmiriRegular = UIFont.init(name: "Amiri-Regular", size: 24)!
        static let DroidArabicKufi = UIFont.init(name: "DroidArabicKufi", size: 20)!
        static let DroidArabicNaskh = UIFont.init(name: "DroidArabicNaskh", size: 21)!
        static let Lateef = UIFont.init(name: "Lateef", size: 26)!
        static let MohammadBoldArt2 = UIFont.init(name: "Mohammad-Bold-Art-2", size: 22)!
        static let PDMS_Saleem_QuranFont = UIFont.init(name: "_PDMS_Saleem_QuranFont", size: 30)!
        static let Scheherazade = UIFont.init(name: "Scheherazade", size: 32)!
        
        
    }
    struct englishFonts {
        static let DroidSerifItalic = UIFont.init(name: "DroidSerif-Italic", size: 20)!
        static let DroidSerif = UIFont.init(name: "DroidSerif", size: 20)!
        static let DroidSans = UIFont.init(name: "DroidSans", size: 20)!
        static let OpenSansLightItalic = UIFont.init(name: "OpenSansLight-Italic", size: 20)!
        static let OpenSansLight = UIFont.init(name: "OpenSans-Light", size: 20)!
        static let OpenSans = UIFont.init(name: "OpenSans", size: 20)!
        static let OpenSansItalic = UIFont.init(name: "OpenSans-Italic", size: 20)!
        static let RobotoThin = UIFont.init(name: "Roboto-Thin", size: 20)!
        static let UbuntuLight = UIFont.init(name: "Ubuntu-Light", size: 20)!
        static let UbuntuLightItalic = UIFont.init(name: "Ubuntu-LightItalic", size: 20)!
   
    }
    
    

    static let darkThemeColor = UIColor.init(hexString: "#5a2c14")
    
    
    static var menuFont : UIFont {
        switch currentLanguageMode {
        case .arabic:
            return DA_STYLE.arabicFonts.noorHiraFont.withSize(30)
        case .english:
            return DA_STYLE.englishFonts.UbuntuLight.withSize(30)
        }
    }
    
    static var savedFont : UIFont{
        let defaults = UserDefaults.standard
        var savedFontKey : String?
        var savedFontSizeKey : String?
        var defaultFont : UIFont?
        
        switch currentLanguageMode {
        case .arabic:
            savedFontKey = StringKeys.SettingsItemArabicFont.rawValue
            savedFontSizeKey = StringKeys.SettingsItemArabicFontSize.rawValue
            defaultFont = self.arabicFonts.noorHiraFont
        case .english:
            savedFontKey = StringKeys.SettingsItemLEnglishFont.rawValue
            savedFontSizeKey = StringKeys.SettingsItemLEnglishFontSize.rawValue
            defaultFont = self.englishFonts.DroidSerif
        }
        
        
        let savedFontName  = defaults.string(forKey: savedFontKey!)
        let savedFontSize  = defaults.double(forKey:  savedFontSizeKey!)
        
        if let savedName = savedFontName, let font = UIFont.init(name: savedName, size: CGFloat.init(savedFontSize)), savedFontSize > 0{
            return font
        }else{
            return defaultFont!
        }
    }
    
    static func saveFont(font :UIFont){
        
        var savedFontKey : String?
        var savedFontSizeKey : String?
        
        switch LanguageManager.currentLanguageCode()! {
        case "ar":
            savedFontKey = StringKeys.SettingsItemArabicFont.rawValue
            savedFontSizeKey = StringKeys.SettingsItemArabicFontSize.rawValue
        case "en":
            savedFontKey = StringKeys.SettingsItemLEnglishFont.rawValue
            savedFontSizeKey = StringKeys.SettingsItemLEnglishFontSize.rawValue
        default:
            break
        }
        
        let defaults = UserDefaults.standard
        defaults.set(font.fontName, forKey: savedFontKey!)
        defaults.set(font.pointSize, forKey: savedFontSizeKey!)
        defaults.synchronize()
    }
}


