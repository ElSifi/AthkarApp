//
//  SettingsViewController.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 5/1/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

enum StringKeys : String {
    case SettingsItemLanguage  = "SettingsItemLanguage"
    case SettingsItemTashkeel  = "SettingsItemTashkeel"
    case SettingsItemTranslationOrTransLitration  = "SettingsItemTranslationOrTransLitration"
    case SettingsItemAllAthkarOrOnlyShortOnes  = "SettingsItemAllAthkarOrOnlyShortOnes"
    case SettingsItemBackGroundImage  = "SettingsItemBackGroundImage"
    case SettingsItemArabicFont  = "SettingsItemArabicFont"
    case SettingsItemArabicFontSize  = "SettingsItemArabicFontSize"
    case SettingsItemLEnglishFont  = "SettingsItemLEnglishFont"
    case SettingsItemLEnglishFontSize  = "SettingsItemLEnglishFontSize"
    case SettingsItemSmartAutoSelection  = "SettingsItemSmartAutoSelection"
    case SettingsItemEnableReminder  = "SettingsItemEnableReminder"
    
    case UserDidSwipeMainSections = "UserDidSwipeMainSections"
    case UserDidSwipeForSharing = "UserDidSwipeForSharing"
    case UserDidSwipeForAudio = "UserDidSwipeForAudio"

    
    var savedValue : Any?{
        let defaults = UserDefaults.standard
        return defaults.value(forKey: self.rawValue)
    }
    
    func saveValue(value : Any?){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: self.rawValue)
        defaults.synchronize()
    }
}

struct SettingsItem {
    
    struct SettingsItemValue {
        var id : String
        var title : String
    }
    
    var id : String
    var title : String
    var values : [SettingsItemValue]
    var selectedValueID : String?
    var otherOptions : [String : Any]?
    
    var selectedValue : SettingsItemValue?{
        if let selectedID = self.selectedValueID{
            for option in self.values {
                if(selectedID == option.id){
                    return option
                }
            }
        }else{
            return self.values.first
        }
        return self.values.first
    }
    
    
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Storyboarded {
    
    var coordinator : SettingsCoodinator?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsItems.count
    }
    
    deinit{
        coordinator?.settingsSaved()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let valueLabel = cell.viewWithTag(2) as! UILabel
        
        titleLabel.text = self.settingsItems[indexPath.row].title
        var subTitle = "tap to choose".localized
        
        if let preloadedTitle = self.settingsItems[indexPath.row].otherOptions?["title"] as? String{
            subTitle = preloadedTitle
        }
        
        if let firstOptionTitle = self.settingsItems[indexPath.row].selectedValue?.title{
            subTitle = firstOptionTitle
        }
        
        valueLabel.text = subTitle
        
        let didTapAddFeatureBefore = UserDefaults.standard.bool(forKey: "didTapAddFeatureBefore")
        if(self.settingsItems[indexPath.row].id == "featureRequests" && !didTapAddFeatureBefore){
            titleLabel.textColor = UIColor.red
        }else{
            titleLabel.textColor = UIColor.black
        }
        
        
        return cell
    }
    
    
    var settingsItems : [SettingsItem] {
        var array : [SettingsItem] = []
        array.append(SettingsItem.init(
            id: StringKeys.SettingsItemLanguage.rawValue,
            title: "app language".localized,
            values: [
                SettingsItem.SettingsItemValue.init(id: "ar", title: "arabic".localized),
                SettingsItem.SettingsItemValue.init(id: "en", title: "english".localized)
            ],
            selectedValueID: currentLanguageMode.rawValue,
            otherOptions: nil)
        )
        switch currentLanguageMode {
        case .arabic:
            array.append(SettingsItem.init(
                id: StringKeys.SettingsItemTashkeel.rawValue,
                title: "التشكيل",
                values: [
                    SettingsItem.SettingsItemValue.init(id: "true", title: "بتشكيل".localized),
                    SettingsItem.SettingsItemValue.init(id: "false", title: "بدون تشكيل".localized)
                ],
                selectedValueID: StringKeys.SettingsItemTashkeel.savedValue as? String,
                otherOptions: nil)
            )
            
            array.append(SettingsItem.init(
                id: StringKeys.SettingsItemArabicFont.rawValue,
                title: "font".localized,
                values: [
                ],
                selectedValueID: StringKeys.SettingsItemArabicFont.savedValue as? String,
                otherOptions: nil)
            )
            
        case .english:
            array.append(SettingsItem.init(
                id: StringKeys.SettingsItemTranslationOrTransLitration.rawValue,
                title: "Text Mode",
                values: [
                    SettingsItem.SettingsItemValue.init(id: "translation", title: "Translation".localized),
                    SettingsItem.SettingsItemValue.init(id: "transliteration", title: "transliteration".localized)
                ],
                selectedValueID: StringKeys.SettingsItemTranslationOrTransLitration.savedValue as? String,
                otherOptions: nil)
            )
            
            array.append(SettingsItem.init(
                id: StringKeys.SettingsItemLEnglishFont.rawValue,
                title: "font".localized,
                values: [],
                selectedValueID: StringKeys.SettingsItemLEnglishFont.savedValue as? String,
                otherOptions: nil)
            )
        }
        
        array.append(SettingsItem.init(
            id: StringKeys.SettingsItemAllAthkarOrOnlyShortOnes.rawValue,
            title: "Text length Mode".localized,
            values: [
                SettingsItem.SettingsItemValue.init(id: "all", title: "all athkar".localized),
                SettingsItem.SettingsItemValue.init(id: "short", title: "only short athkar".localized)
            ],
            selectedValueID: StringKeys.SettingsItemAllAthkarOrOnlyShortOnes.savedValue as? String,
            otherOptions: ["title" : "tap to choose".localized])
        )
        
        array.append(SettingsItem.init(
            id: "share",
            title: "share the app".localized,
            values: [],
            selectedValueID: "share",
            otherOptions: ["title" : ""])
        )
        
        array.append(SettingsItem.init(
            id: "rate",
            title: "rate the app".localized,
            values: [],
            selectedValueID: "rate",
            otherOptions: ["title" : ""])
        )
        
//        array.append(SettingsItem.init(
//            id: "contact",
//            title: "contact developer".localized,
//            values: [],
//            selectedValueID: "contact",
//            otherOptions: ["title" : ""])
//        )
        
        array.append(SettingsItem.init(
            id: "featureRequests",
            title: "Feature Requests".localized,
            values: [],
            selectedValueID: "featureRequests",
            otherOptions: ["title" : ""])
        )
        
        if let currentUser = Auth.auth().currentUser, !currentUser.isAnonymous{
            
                array.append(SettingsItem.init(
                    id: "logout",
                    title: "log out".localized,
                    values: [],
                    selectedValueID: "",
                    otherOptions: ["title" : ""])
                )
            
        }else{
            array.append(SettingsItem.init(
                id: "login",
                title: "log in".localized,
                values: [],
                selectedValueID: "",
                otherOptions: ["title" : ""])
            )
        }
        
        return array
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem.init(title: "save".localized, style: .plain, target: self, action: #selector(SettingsViewController.close(_:)))
        self.navigationItem.leftBarButtonItem = closeButton
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let item = self.settingsItems[indexPath.row]
        print(item.id)
        
        if let theEnumID : StringKeys = StringKeys.init(rawValue: item.id){
            switch theEnumID {
            case .SettingsItemLEnglishFont, .SettingsItemArabicFont:
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "FontSelectionViewController") as! FontSelectionViewController
                self.show(vc, sender: self)
            
            default:
                
                let buttons = item.values.map { settingsItemValue in
                    return settingsItemValue.title
                }
                let alert = UIAlertController.show(in: self, withTitle: item.title, message: nil, preferredStyle: UIAlertController.Style.alert, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: buttons) { popOverController in
                    
                } tap: { alertController, alertAction, index in
                    let selectedItem = item.values.first { settingsItemValue in
                        return settingsItemValue.title == alertAction.title
                    }
                    guard let value = selectedItem?.id as? String else { return }
                    print(theEnumID, value)
                    if let theEnumID : StringKeys = StringKeys.init(rawValue: item.id){
                        switch (theEnumID, value) {
                        
                        case (.SettingsItemLanguage, _):
                            self.changeAppLanguageTo(value)
                        default:
                            theEnumID.saveValue(value: value)
                            tableView.reloadData()
                        }
                    }
                }

                alert.view.tintColor = UIColor.primary
            }
        }else{
            switch(item.id){
            case "share":
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                Meezan.getMyInvitationLink(withoutLogin: true, completion: { (link, error) in
                    hud.hide(animated: true)
                    if let theURL = link{
                        let textToShare = String(format: NSLocalizedString("share message", comment: ""), theURL)
                        let objectsToShare = [textToShare, theURL] as [Any]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        activityVC.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
                        self.present(activityVC, animated: true, completion: nil)
                    }
                })
            case "contact":
                
                
                let phoneNumber =  "+201066276777"
                let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
                let testWhatsappURl = URL(string: "whatsapp://send?text=Message")!
                
                let twitterURL = URL(string: "twitter://user?screen_name=mo_badi3")!
                
                if (UIApplication.shared.canOpenURL(testWhatsappURl)) {
                    UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                }else if (UIApplication.shared.canOpenURL(twitterURL)) {
                    UIApplication.shared.open(twitterURL, options: [:], completionHandler: nil)
                }
            case "rate":
                rateApp(appId: "id821664774") { success in
                    print("RateApp \(success)")
                }
            case "logout":
                UIAlertController.showAlert(in: self, withTitle: "Are you sure you want to log out?".localized, message: nil, cancelButtonTitle: "Cancel".localized, destructiveButtonTitle: "Yes, log me out".localized, otherButtonTitles: nil) { (controller, action, index) in
                    print(index)
                    if(index == 1){
                        try! Auth.auth().signOut()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            case "login":
                Meezan.loginWithPhone(viewController: self)
                break;
                
            case "featureRequests":
                let vc = DemocraticFeatures.listVC()
                self.present(vc, animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: "didTapAddFeatureBefore")
            break;
                
            default:
                print("\(item.id) NOT HANDLED")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    
        func changeAppLanguageTo(_ languageCode: String) {
            print("languageCode \(languageCode)")
//            UIAlertController.showAlert(in: self, withTitle: "Language change", message: "App Restart is required", cancelButtonTitle: "cancel and keep current language", destructiveButtonTitle: nil, otherButtonTitles: ["change language and restart app"], tap: { (controller, action, index) in
//                print(index)
//
//                if(index == 2){
//
//
////                    [[NSUserDefaults standardUserDefaults] setObject:@[@"ar-sa"] forKey:@"AppleLanguages"];
////                    [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:LanguageSaveKey];
////                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
//
//            })
            
//            return
//
            self.dismiss(animated: true) {
                let index = ["en", "ar"].index(where: { (language) -> Bool in
                    return languageCode == language
                })

                LanguageManager.saveLanguage(by: index!)
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.coordinator?.start()
            }
    
        }
    
    @objc func close(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}
