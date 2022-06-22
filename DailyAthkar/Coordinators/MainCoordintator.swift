//
//  MainCoordintator.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

class MainCoodinator : DACoordinator{
    var childCoordinators = [DACoordinator]()
    var navigationController: UINavigationController
    
    init(navigationController : UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HomeViewController.instantiate()
        navigationController.pushViewController(vc, animated: false)
    }
    
    
}
