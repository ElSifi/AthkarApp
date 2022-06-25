//
//  MainCoordintator.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

class MainCoodinator : DACoordinator{
   
    
    var parentCoodinator: DACoordinator? = nil
    
    var childCoordinators = [DACoordinator]()
    var navigationController: UINavigationController
    
    init(navigationController : UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = AthkarSectionsViewController.instantiate()
        vc.coordinator = self
        vc.viewModel = HomeAthkarSectionsViewViewModel(athkarLoadingFunction: AthakrService.getAthkarSectionFromJSONFile)
        navigationController.setViewControllers([vc], animated: false)
    }
}


extension MainCoodinator : AthkarSectionsCoordinator{
    func showAthkarSection(section: AthkarSection) {
        
        if let currentUser = Auth.auth().currentUser {
            Meezan.recordTheAppLaunch(userUID: currentUser.uid)
        }
        
        let vc = SectionContentViewController.instantiate()
        vc.data = section
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showAthkarSectionWithMode(onlyBrief: Bool, section: AthkarSection) {
        let vc : SectionContentViewController = .instantiate()
        vc.data = section
        vc.commonOnly = onlyBrief
        self.navigationController.pushViewController(vc, animated: true)
    }

    
    func showMeezan() {
        
        let vc = MeezanMainViewController.init(nibName: "MeezanMainViewController", bundle: nil)
        vc.edgesForExtendedLayout = .init(rawValue: 0)
        let navController = UINavigationController.init(rootViewController: vc)
        
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.isTranslucent = true
        navController.modalPresentationStyle = .overCurrentContext
        
        self.navigationController.present(navController, animated: true, completion: nil)
        
        
    }
    
    func showSettings() {
        let settingsCoodinator = SettingsCoodinator(navigationController: navigationController)
        settingsCoodinator.parentCoodinator = self
        childCoordinators.append(settingsCoodinator)
        settingsCoodinator.start()
    }
}
