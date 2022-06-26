//
//  AthkarSectionsViewModel.swift
//  DailyAthkar
//
//  Created by badi3 on 23/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

typealias AthkarLoadingFunction = () -> ([AthkarSection])

class HomeAthkarSectionsScreenViewModel {
    
    var loadAthkar: AthkarLoadingFunction
    var athkarSections: Box<[AthkarSection]> = Box([])
    
    init(athkarLoadingFunction: @escaping AthkarLoadingFunction) {
        self.loadAthkar = athkarLoadingFunction
        self.athkarSections.value = self.loadAthkar()
    }
}


extension HomeAthkarSectionsScreenViewModel : AthkarSectionsScreenViewModel{
    func athkarSectionCellViewModelForIndex(_ index: Int) -> AthkarSectionCellViewModel {
        return AthkarSectionCellViewModel(section: athkarSections.value[index])
    }
    
    func athkarSectionDetailsViewModelForIndex(_ index: Int) -> AthkarSectionDetailsViewModel {
        return AthkarSectionDetailsViewModel(section: athkarSections.value[index])

    }
    
   
    var numberOfAthkarSections: Int{
        return athkarSections.value.count
    }

}
