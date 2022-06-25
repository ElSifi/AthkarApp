//
//  AthkarSectionsViewModel.swift
//  DailyAthkar
//
//  Created by badi3 on 23/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

typealias AthkarLoadingFunction = () -> ([AthkarSection])

class HomeAthkarSectionsViewViewModel {
    
    var loadAthkar: AthkarLoadingFunction
    var athkarSections: Box<[AthkarSection]> = Box([])
    
    init(athkarLoadingFunction: @escaping AthkarLoadingFunction) {
        self.loadAthkar = athkarLoadingFunction
        self.athkarSections.value = self.loadAthkar()
    }
}


extension HomeAthkarSectionsViewViewModel : AthkarSectionsViewViewModel{
   
    var numberOfAthkarSections: Int{
        return athkarSections.value.count
    }

    func athkarSectionForIndex(_ index: Int) -> AthkarSection {
        return athkarSections.value[index]
    }
}
