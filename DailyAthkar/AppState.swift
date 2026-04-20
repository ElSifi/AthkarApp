//
//  AppState.swift
//  DailyAthkar
//
//  Central app state for SwiftUI
//

import SwiftUI

class AppState: ObservableObject {
    @AppStorage("currentLanguageKey") var languageCode: String = "ar" {
        didSet {
            UserDefaults.standard.set(
                [languageCode == "ar" ? "ar-sa" : "en-us"],
                forKey: "AppleLanguages"
            )
        }
    }

    @AppStorage(StringKeys.SettingsItemTashkeel.rawValue)
    var tashkeel: String = "true"

    @AppStorage(StringKeys.SettingsItemTranslationOrTransLitration.rawValue)
    var textMode: String = "translation"

    @AppStorage(StringKeys.SettingsItemAllAthkarOrOnlyShortOnes.rawValue)
    var athkarMode: String = "all"

    @AppStorage(StringKeys.SettingsItemArabicFont.rawValue)
    var arabicFontName: String = ""

    @AppStorage(StringKeys.SettingsItemArabicFontSize.rawValue)
    var arabicFontSize: Double = 0

    @AppStorage(StringKeys.SettingsItemLEnglishFont.rawValue)
    var englishFontName: String = ""

    @AppStorage(StringKeys.SettingsItemLEnglishFontSize.rawValue)
    var englishFontSize: Double = 0

    @AppStorage("didTapAddFeatureBefore")
    var didTapAddFeatureBefore: Bool = false

    var isArabic: Bool { languageCode == "ar" }
    var isRTL: Bool { languageCode == "ar" }

    var showTashkeel: Bool {
        get { tashkeel == "true" }
        set { tashkeel = newValue ? "true" : "false" }
    }

    var onlyShortAthkar: Bool {
        get { athkarMode == "short" }
        set { athkarMode = newValue ? "short" : "all" }
    }

    var showTransliteration: Bool {
        get { textMode == "transliteration" }
        set { textMode = newValue ? "transliteration" : "translation" }
    }

    // MARK: - Font Management

    var savedFont: UIFont {
        if isArabic {
            if !arabicFontName.isEmpty, arabicFontSize > 0,
               let font = UIFont(name: arabicFontName, size: arabicFontSize) {
                return font
            }
            return UIFont(name: "noorehira", size: 23) ?? .systemFont(ofSize: 23)
        } else {
            if !englishFontName.isEmpty, englishFontSize > 0,
               let font = UIFont(name: englishFontName, size: englishFontSize) {
                return font
            }
            return UIFont(name: "DroidSerif", size: 20) ?? .systemFont(ofSize: 20)
        }
    }

    func saveFont(_ font: UIFont) {
        if isArabic {
            arabicFontName = font.fontName
            arabicFontSize = Double(font.pointSize)
        } else {
            englishFontName = font.fontName
            englishFontSize = Double(font.pointSize)
        }
    }

    var menuFont: Font {
        if isArabic {
            return Font.custom("noorehira", size: 30)
        } else {
            return Font.custom("Ubuntu-Light", size: 30)
        }
    }

    var contentFont: Font {
        let uiFont = savedFont
        return Font.custom(uiFont.fontName, size: uiFont.pointSize)
    }

    // MARK: - Localization

    func localized(_ key: String) -> String {
        let path = Bundle.main.path(forResource: languageCode, ofType: "lproj")
        let bundle = path.flatMap { Bundle(path: $0) } ?? .main
        return bundle.localizedString(forKey: key.lowercased(), value: nil, table: nil)
    }

    func changeLanguage(to code: String) {
        languageCode = code
    }
}

// MARK: - Environment Key
private struct AppStateKey: EnvironmentKey {
    static let defaultValue = AppState()
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}
