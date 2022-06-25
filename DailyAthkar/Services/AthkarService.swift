//
//  AthkarService.swift
//  DailyAthkar
//
//  Created by badi3 on 25/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

class AthakrService{

    static func getAthkarSectionFromJSONFile()->[AthkarSection]{
        if let path = Bundle.main.path(forResource:"db", ofType: "json")
        {
            let url = URL.init(fileURLWithPath: path)
            do{
                let jsonData = try Data.init(contentsOf: url)
                let athkarSections = try! JSONDecoder().decode([AthkarSection].self, from: jsonData)
                    return athkarSections
    
    
            } catch{
                return []
            }
    
        }
        return []
    }

}
