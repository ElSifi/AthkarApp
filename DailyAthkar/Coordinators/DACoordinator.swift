//
//  DACoordinator.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

protocol DACoordinator {
    var childCoordinators :[DACoordinator] {get set}
    var navigationController :UINavigationController {get set}
    
    func start()

}
