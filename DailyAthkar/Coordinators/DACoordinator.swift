//
//  DACoordinator.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

protocol DACoordinator : AnyObject{
    var childCoordinators :[DACoordinator] {get set}
    var parentCoodinator :DACoordinator? {get set}
    var navigationController :UINavigationController {get set}
    func start()
    func childCoodinatorDidFinish(_ child: DACoordinator)
}

extension DACoordinator{
    func childCoodinatorDidFinish(_ child: DACoordinator) {
        if let index = childCoordinators.firstIndex(where: { aCoodinator in
            return aCoodinator === child
        }){
            self.childCoordinators.remove(at: index)
        }
    }
}
