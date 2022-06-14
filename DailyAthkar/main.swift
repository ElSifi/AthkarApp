//
//  main.swift
//  DailyAthkar
//
//  Created by badi3 on 4/10/19.
//  Copyright © 2019 Badi3.com. All rights reserved.
//

class MyApplication: UIApplication {
    override init() {
        let notFirstOpenKey = "notFirstOpen"
        let notFirstOpen = UserDefaults.standard.bool(forKey: notFirstOpenKey)
        if notFirstOpen == false {
            UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
            UserDefaults.standard.set(true, forKey: notFirstOpenKey)
            UserDefaults.standard.synchronize()
        }
        super.init()
    }
}

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)
    ),
    NSStringFromClass(MyApplication.self),
    NSStringFromClass(AppDelegate.self)
)
