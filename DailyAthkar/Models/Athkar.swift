//
//  Athkar.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation
struct AthkarSection: Codable {
    let id, nameAr, nameEn, stringID: String
    let content: [Thikr]

    enum CodingKeys: String, CodingKey {
        case id
        case nameAr = "name_ar"
        case nameEn = "name_en"
        case stringID, content
    }
}

// MARK: - Content
struct Thikr: Codable {
    let textEn, textEnTrans, moreInfo, number: String
    let scriptMode, textAr: String
    let repeatTimes: Int
    let specificTimeArabic: String
    let specificTimeEnglish, type, textArUnsigned, thikrTitle: String
    let zEnt, zOpt, zPk: String

    var currentCount : Int = 0
    
    enum CodingKeys: String, CodingKey {
        case textEn = "text_en"
        case textEnTrans = "text_en_trans"
        case moreInfo, number, repeatTimes, scriptMode
        case textAr = "text_ar"
        case specificTimeArabic, specificTimeEnglish, type
        case textArUnsigned = "text_ar_unsigned"
        case thikrTitle
        case zEnt = "Z_ENT"
        case zOpt = "Z_OPT"
        case zPk = "Z_PK"
    }
}



extension AthkarSection{
    func localizedName()->String {
        if(LanguageManager.isCurrentLanguageRTL()){
            return self.nameAr
        }else{
            return self.nameEn
        }
    }
}



extension Thikr{
    func localizedText()->String {
        if(LanguageManager.isCurrentLanguageRTL()){
            return self.textAr
        }else{
            return self.textEn
        }
    }
}
