//
//  AthkarSectionsViewModel.swift
//  DailyAthkar
//
//  Created by badi3 on 23/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

typealias AthkarLoadingFunction = (_ completion:(([AthkarSection]) -> ())) -> ()

class HomeAthkarSectionsScreenViewModel {
    
    var loadAthkar: AthkarLoadingFunction
    var athkarSections: Box<[AthkarSection]> = Box([])
    var realUpdated: (() -> Void)?
    
    init(athkarLoadingFunction: @escaping AthkarLoadingFunction) {
        self.loadAthkar = athkarLoadingFunction
    }
}


extension HomeAthkarSectionsScreenViewModel : AthkarSectionsScreenViewModel{
    func fetchData() {
        self.loadAthkar { [weak self] athkarList in
            self?.athkarSections.value = athkarList
            self?.realUpdated?()
        }
    }
    
    var updated: (() -> Void)? {
        get {
            return realUpdated
        }
        set {
            realUpdated = newValue
        }
    }
    
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
