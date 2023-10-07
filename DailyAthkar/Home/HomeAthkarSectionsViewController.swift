//
//  ViewController.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 4/27/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit
import SwipeCellKit
import FirebaseAuthUI
import FirebaseFirestore
import BadgeHub

protocol AthkarSectionsScreenCoordinator{
    func showAthkarSectionDetails(sectionViewModel: AthkarSectionDetailsViewModel)
    func showAthkarSectionDetailsWithMode(onlyBrief: Bool, sectionViewModel: AthkarSectionDetailsViewModel)
    func showMeezan()
    func showSettings()
}

protocol AthkarSectionsScreenViewModel{
    var updated: (()->Void)? { get set }
    var numberOfAthkarSections: Int { get }
    func fetchData()->Void
    func athkarSectionCellViewModelForIndex(_ index: Int) -> AthkarSectionCellViewModel
    func athkarSectionDetailsViewModelForIndex(_ index: Int) -> AthkarSectionDetailsViewModel
}

class HomeAthkarSectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate, Storyboarded {
    
    var coordinator : AthkarSectionsScreenCoordinator?
    var viewModel : AthkarSectionsScreenViewModel!
    
    @IBOutlet weak var theTable: UITableView!
    @IBOutlet weak var bgImage: UIImageView!{
        didSet{
            bgImage.image = theBGImage
        }
    }
    
    
    @IBOutlet weak var redSettingsIcon: UIView!{
        didSet{
            redSettingsIcon.isHidden = true
        }
    }
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var statusBarBG: UIView!
    @IBOutlet weak var tableContainer: UIView!{
        didSet{
            tableContainer.layer.cornerRadius = 6
            tableContainer.clipsToBounds = true
            tableContainer.alpha = 0
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = tableContainer.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            tableContainer.insertSubview(blurEffectView, at: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.updated = { [weak self] in
            self?.theTable.reloadData()
        }
        viewModel.fetchData()
        doUI()
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        let common = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
            let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
            action.fulfill(with: .reset)
            guard let section = self?.viewModel.athkarSectionDetailsViewModelForIndex(indexPath.row) else { return }
            self?.coordinator?.showAthkarSectionDetailsWithMode(onlyBrief: true, sectionViewModel: section)
            cell.hideSwipe(animated: true, completion: nil)
        }
        
        common.image = #imageLiteral(resourceName: "ex").maskWith(color: UIColor.init(hexString: "#211f1d"))
        common.backgroundColor = UIColor.clear
        
        let all = SwipeAction(style: .default, title: nil) {[weak self] action, indexPath in
            let cell = tableView.cellForRow(at: indexPath) as! SwipeTableViewCell
            action.fulfill(with: ExpansionFulfillmentStyle.delete)
            guard let section = self?.viewModel.athkarSectionDetailsViewModelForIndex(indexPath.row) else { return }
            self?.coordinator?.showAthkarSectionDetailsWithMode(onlyBrief: false, sectionViewModel: section)
            cell.hideSwipe(animated: true, completion: nil)
        }
        
        all.backgroundColor = .clear
        all.image = #imageLiteral(resourceName: "full").maskWith(color: UIColor.init(hexString: "#211f1d"))
        
        
        return [common, all]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        options.backgroundColor = .clear
        return options
    }
    
    
    var didTheInitialAnimation = false
    override func viewDidAppear(_ animated: Bool) {
        
        let didTapAddFeatureBefore = UserDefaults.standard.bool(forKey: "didTapAddFeatureBefore")
        
        if(!didTapAddFeatureBefore){
            self.redSettingsIcon.isHidden = false
        }
        
        
        
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
                } else {
                    self.openSettings(UIButton.init())
                    languageWasAlreadySet = true
                }
            }
        }
        
        
    }
    
    func doUI(){
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfAthkarSections
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (tableView.bounds.height / CGFloat.init(self.viewModel.numberOfAthkarSections))
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.theTable.visibleCells.forEach { aCell in
                if let cell = aCell as? HomeSectionTableViewCell{
                    cell.update()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "section") as! HomeSectionTableViewCell
        let section = self.viewModel.athkarSectionCellViewModelForIndex(indexPath.row)
        
        cell.viewModel = section
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section: AthkarSectionDetailsViewModel = self.viewModel.athkarSectionDetailsViewModelForIndex(indexPath.row)
        coordinator?.showAthkarSectionDetails(sectionViewModel: section)
    }
    
    @IBAction func meezanAction(_ sender: UIButton) {
        coordinator?.showMeezan()
    }
    
    @IBAction func openSettings(_ sender: UIButton) {
        coordinator?.showSettings()
    }
}


