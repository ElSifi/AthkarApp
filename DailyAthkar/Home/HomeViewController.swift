//
//  ViewController.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 4/27/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit
import SwipeCellKit
import FirebaseUI
import FirebaseFirestore
import BadgeHub

protocol HomeViewControllerCoordinator{
    func showAthkarSection(section: JSON)
    func showAthkarSectionWithMode(onlyBrief: Bool, section: JSON)
    func showMeezan()
    func showSettings()
}

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, Storyboarded {
    
    var coordinator : HomeViewControllerCoordinator?
    
    @IBOutlet weak var theTable: UITableView!
    @IBOutlet weak var bgImage: UIImageView!{
        didSet{
            bgImage.image = theBGImage
        }
    }
    @IBOutlet weak var headerLogo: UIImageView!{
        didSet{
            if(LanguageManager.isCurrentLanguageRTL()){
                headerLogo.image = #imageLiteral(resourceName: "logo")
            }else{
                headerLogo.image = #imageLiteral(resourceName: "logoEnglish")
            }
        }
    }
    @IBOutlet weak var redSettingsIcon: UIView!{
        didSet{
            redSettingsIcon.isHidden = true
        }
    }
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var statusBarBG: UIView!
    @IBOutlet weak var tableContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        doUI()
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let common = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
            let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
            action.fulfill(with: .reset)
            
            let section = theDatabase[indexPath.row]

            self?.coordinator?.showAthkarSectionWithMode(onlyBrief: true, section: section)
            
            cell.hideSwipe(animated: true, completion: { (completed) in

            })
        }
        
        common.image = #imageLiteral(resourceName: "ex").maskWith(color: UIColor.init(hexString: "#211f1d"))
        common.backgroundColor = UIColor.clear//UIColor.init(hexString: "#211f1d").withAlphaComponent(0.1)
        
        let all = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
            let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
            action.fulfill(with: ExpansionFulfillmentStyle.delete)

            let section = theDatabase[indexPath.row]
            self?.coordinator?.showAthkarSectionWithMode(onlyBrief: false, section: section)

            
            cell.hideSwipe(animated: true, completion: { (completed) in
                
            })
        }
        
        all.backgroundColor = .clear//UIColor.init(hexString: "#211f1d").withAlphaComponent(0.1)
        all.image = #imageLiteral(resourceName: "full").maskWith(color: UIColor.init(hexString: "#211f1d"))

        
        return [common, all]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        let alternatingColors = [UIColor.black.withAlphaComponent(0.1), UIColor.clear]
        
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        options.backgroundColor = .clear//alternatingColors[ indexPath.row % alternatingColors.count ]//UIColor.red.withAlphaComponent(0.5)
        return options
    }
    
   
    var didTheInitialAnimation = false
    override func viewDidAppear(_ animated: Bool) {
        
     let didTapAddFeatureBefore = UserDefaults.standard.bool(forKey: "didTapAddFeatureBefore")

        if(!didTapAddFeatureBefore){
            self.redSettingsIcon.isHidden = false
        }
        
        
        if(!languageWasAlreadySet){
            self.openSettings(UIButton.init())
            languageWasAlreadySet = true
        }else{
            if(!didTheInitialAnimation){
                UIView.animate(withDuration: 0.3, delay: 0.7, options: .curveEaseIn, animations: {
                    self.tableContainer.alpha = 1
                }) { (completed) in
                    self.didTheInitialAnimation = true
                    if(languageWasAlreadySet){
                    
                        if(!(StringKeys.UserDidSwipeMainSections.savedValue as? Bool ??  false)){
                            if let cell = self.theTable.visibleCells.first{
                                if let swipeCell = cell as? HomeSectionTableViewCell{
                                    swipeCell.showSwipe(orientation: .right, animated: true) { (completed) in
                                        print("swipe showed")
                                        StringKeys.UserDidSwipeMainSections.saveValue(value: true)
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
    }

    func doUI(){
        tableContainer.layer.cornerRadius = 6
        tableContainer.clipsToBounds = true
        tableContainer.alpha = 0
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = tableContainer.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableContainer.insertSubview(blurEffectView, at: 0)
        
//        let statusBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
//        let statusBlurEffectView = UIVisualEffectView(effect: statusBlurEffect)
//        statusBlurEffectView.frame = self.statusBarBG.bounds
//        statusBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        statusBarBG.insertSubview(statusBlurEffectView, at: 0)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theDatabase.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.bounds.height / CGFloat.init(theDatabase.count))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HomeSectionTableViewCell{
            cell.iconContainer.layer.cornerRadius = (tableView.bounds.height / CGFloat(theDatabase.count)) * 0.4
        }

    }
    
    var sectionImages:[UIImage] = [#imageLiteral(resourceName: "WakingUp"), #imageLiteral(resourceName: "Morning"), #imageLiteral(resourceName: "AfterPrayer"), #imageLiteral(resourceName: "Evening"), #imageLiteral(resourceName: "Sleeping")]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "section") as! HomeSectionTableViewCell
        cell.data = theDatabase[indexPath.row]
        cell.delegate = self
        if let image = self.sectionImages[safe: indexPath.row]{
            cell.iconImage.image = image
        }else{
            cell.iconImage.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if let currentUser = Auth.auth().currentUser {
            Meezan.recordTheAppLaunch(userUID: currentUser.uid)
        }
        let section : JSON = theDatabase[indexPath.row]
        coordinator?.showAthkarSection(section: section)
    }
    
    @IBAction func meezanAction(_ sender: UIButton) {
        coordinator?.showMeezan()
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        coordinator?.showSettings()
    }
}


