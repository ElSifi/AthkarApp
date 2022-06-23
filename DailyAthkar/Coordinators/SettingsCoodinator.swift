//
//  SettingsCoodinator.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

final class SettingsCoodinator : DACoordinator{
    var parentCoodinator: DACoordinator?
    
    var childCoordinators: [DACoordinator] = []
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let vc : SettingsViewController = .instantiate()
        vc.coordinator = self
        let navVC = UINavigationController.init(rootViewController: vc)
        navVC.navigationBar.backgroundColor = UIColor.brown
        self.navigationController.present(navVC, animated: true)
    }
    
    func settingsSaved(){
        self.parentCoodinator?.childCoodinatorDidFinish(self)
    }
    
    deinit{
        print("DE INTTING SettingsCoodinator")
    }
}
