//
//  AthkarSectionDetailsViewModel.swift
//  DailyAthkar
//
//  Created by badi3 on 26/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation
class AthkarSectionDetailsViewModel{
    
    var onlyBrief: Bool{
        didSet{
            generateViewModels()
        }
    }
    private var originalSection: AthkarSection
    
    var athkarList : [ThikrCellViewModel] = []
    
    private func generateViewModels(){
        let athkar = originalSection.content.filter { aThink in
           if(onlyBrief){
               return aThink.scriptMode
           }
           return true
       }
       let viewModels = athkar.map { ThikrCellViewModel(thikr: $0) }
        self.athkarList = viewModels
    }
    
    init(section: AthkarSection, onlyBrief: Bool? = nil) {
        self.originalSection = section
        let savedOnlyBrief = ((StringKeys.SettingsItemAllAthkarOrOnlyShortOnes.savedValue as? String) ?? "") == "short"
        self.onlyBrief = onlyBrief ?? savedOnlyBrief
        generateViewModels()
    }
    
    var localizedName: String {
        if(LanguageManager.isCurrentLanguageRTL()){
            return originalSection.nameAr
        }else{
            return originalSection.nameEn
        }
    }
    
    var athkarCount : Int {
        return athkarList.count
    }
    
    var stringID : String {
        return originalSection.stringID
    }
    
}
