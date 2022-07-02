//
//  CucumberishInitializer.swift
//  DailyAthkarBDD
//
//  Created by badi3 on 29/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation
import Cucumberish

class CucumberishInitializer: NSObject{
    @objc class func setupCucumberish(){
        before { _ in
            Given("I launch the app") { args, userInfo in
            }
        }
        
        let bundle = Bundle(for: CucumberishInitializer.self)
        Cucumberish.executeFeatures(inDirectory: "Features", from: bundle, includeTags: nil, excludeTags: nil)
    }
}
