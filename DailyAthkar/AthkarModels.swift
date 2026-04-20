//
//  AthkarModels.swift
//  DailyAthkar
//
//  Ported models for SwiftUI
//

import Foundation

struct AthkarSection: Codable, Identifiable {
    let id, nameAr, nameEn, stringID: String
    let content: [Thikr]

    enum CodingKeys: String, CodingKey {
        case id
        case nameAr = "name_ar"
        case nameEn = "name_en"
        case stringID, content
    }

    func localizedName(isArabic: Bool) -> String {
        isArabic ? nameAr : nameEn
    }
}

struct Thikr: Codable, Identifiable {
    var id: String { zPk }

    let textEn, textEnTrans, moreInfo, number: String
    let scriptMode: Bool
    let textAr: String
    let repeatTimes: Int
    let specificTimeArabic: String
    let specificTimeEnglish, type, textArUnsigned, thikrTitle: String
    let zEnt, zOpt, zPk: String

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

    func localizedText(isArabic: Bool, showTashkeel: Bool, showTransliteration: Bool, fontName: String) -> String {
        if isArabic {
            if showTashkeel && fontName != "Mohammad-Bold-Art-2" {
                return textAr
            } else {
                return textArUnsigned
            }
        } else {
            return showTransliteration ? textEnTrans : textEn
        }
    }

    func soundFilePath(sectionID: String) -> String? {
        let prefix = "Mishary"
        if !thikrTitle.isEmpty {
            return Bundle.main.path(forResource: "\(prefix)_\(thikrTitle)", ofType: "mp3")
        } else {
            let resource = "\(prefix)_\(sectionID)_\(number)".replacingOccurrences(of: " ", with: "")
            return Bundle.main.path(forResource: resource, ofType: "mp3")
        }
    }
}
