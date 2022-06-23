//
//  AppDelegate.swift
//  DailyAthkar
//
//  Created by Mohamed ElSIfi on 4/27/18.
//  Copyright © 2018 Badi3.com. All rights reserved.
//

var languageWasAlreadySet = true;

import Siren
import UIKit
import DLLocalNotifications
import UserNotifications
import OneSignal
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var coordinator: MainCoodinator?
    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        languageWasAlreadySet = LanguageManager.setupCurrentLanguage()
        
        doGlobalStyling()
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        
        let siren = Siren.shared
        siren.rulesManager = RulesManager(
            globalRules: .default
        )
        siren.presentationManager = PresentationManager(
            alertTintColor: DA_STYLE.darkThemeColor
        )
        siren.wail()
        
        
        if(Auth.auth().currentUser == nil){
            Auth.auth().signInAnonymously() { (authResult, error) in
                
                guard let authResult = authResult else{
                    print("error \(error)")
                    return
                }
                let user = authResult.user
                let isAnonymous = user.isAnonymous  // true
                let uid = user.uid
                print("user \(user)")
                print("uid \(uid)")
            }
            
        }else{
            OneSignal.setExternalUserId(Auth.auth().currentUser!.uid)
        }
        
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        
        if let path = Bundle.main.path(forResource: "tokens", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            if let oneSignalAppID = keys?.value(forKey: "ONE_SIGNAL_APP_ID") as? String{
                OneSignal.initWithLaunchOptions(launchOptions,
                                                appId: oneSignalAppID,
                                                handleNotificationAction: nil,
                                                settings: onesignalInitSettings)
                
                OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    Utils.scheduleLocalNotifications(completion: { (success) in
                        print("scheduleLocalNotifications \(success)")
                    })
                })
            }
        }
        
        
        let navController = UINavigationController()
        coordinator = MainCoodinator(navigationController: navController)
        coordinator?.start()
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL{
            print("incomingURL \(incomingURL)")
            
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { (dynamicLink, error) in
                guard error == nil else{
                    print("handleUniversalLink error \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink{
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
            
            if(linkHandled){
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    func handleIncomingDynamicLink(_ dynamicLink : DynamicLink){
        
        print("dynamicLink \(dynamicLink)")
        
        guard let theURL = dynamicLink.url else {
            print("Dynamic link has no URL")
            return
        }
        print("the URL \(theURL.absoluteString)")
        
        
        guard let components = URLComponents(url: theURL, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            print("no parameters")
            return
        }
        
        var parameters = [String: String]()
        for item in queryItems {
            if let value = item.value{
                parameters[item.name] = value
            }
        }
        print("parameters \(parameters)")
        
        if let actionType = parameters["type"]{
            switch (actionType){
            case "invite":
                if let uid = parameters["uid"] {
                    Meezan.registerMyInviter(inviterUID: uid)
                }
            default:
                break
            }
        }
        
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url){
            self.handleIncomingDynamicLink(dynamicLink)
            return true
        }else{
            return false
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func doGlobalStyling(){
        
        
        
        //            for fontFamilyName in UIFont.familyNames{
        //                for fontName in UIFont.fontNames(forFamilyName: fontFamilyName){
        //                    print("Family: \(fontFamilyName)     Font: \(fontName)")
        //                }
        //            }
        
        
        self.window?.tintColor = DA_STYLE.darkThemeColor
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor =  DA_STYLE.darkThemeColor
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : DA_STYLE.darkThemeColor]
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            //NSAttributedStringKey.font: DA_STYLE.defaultBoldFont.withSize(17)
        ]
        
        UISegmentedControl.appearance().tintColor = DA_STYLE.darkThemeColor
        
        //UIBarButtonItem.appearance().setTitleTextAttributes([
        //NSAttributedStringKey.font : ShopXStyle.defaultNormalFont.withSize(16)],
        //                                            for: UIControlState.normal)
        //UIBarButtonItem.appearance().setTitleTextAttributes([
        //NSAttributedStringKey.font : ShopXStyle.defaultNormalFont.withSize(16)],
        //                                              for: UIControlState.highlighted)
        
        
        
        
    }
    
    
}
