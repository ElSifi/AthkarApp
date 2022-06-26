//
//  AthkarSectionCellViewModel.swift
//  DailyAthkar
//
//  Created by badi3 on 26/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation
struct AthkarSectionCellViewModel{
    
    var section: AthkarSection
    
    var localizedName: String {
        if(LanguageManager.isCurrentLanguageRTL()){
            return section.nameAr
        }else{
            return section.nameEn
        }
    }
    
    var sectionImage:UIImage? {
        return UIImage(named: section.stringID)
    }
    
}
