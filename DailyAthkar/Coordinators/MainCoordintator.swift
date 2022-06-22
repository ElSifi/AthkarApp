//
//  MainCoordintator.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation
import SwiftyJSON

class MainCoodinator : DACoordinator{
    var childCoordinators = [DACoordinator]()
    var navigationController: UINavigationController
    
    init(navigationController : UINavigationController){
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HomeViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}


extension MainCoodinator : HomeViewControllerCoordinator{
    func showAthkarSection(section: JSON) {
        let vc = SectionContentViewController.instantiate()
        vc.data = section
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func showAthkarSectionWithMode(onlyBrief: Bool, section: JSON) {
        let vc = SectionContentViewController.instantiate()
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
        let vc = SettingsViewController.instantiate()
        let navVC = UINavigationController.init(rootViewController: vc)
        navVC.navigationBar.backgroundColor = UIColor.brown
        self.navigationController.present(navVC, animated: true)
    }
}
