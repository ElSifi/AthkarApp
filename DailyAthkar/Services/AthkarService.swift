//
//  AthkarService.swift
//  DailyAthkar
//
//  Created by badi3 on 25/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

class AthakrService{

    static func getAthkarSectionFromJSONFile(_ completion: ([AthkarSection])->())-> Void{
        if let path = Bundle.main.path(forResource:"db", ofType: "json")
        {
            let url = URL.init(fileURLWithPath: path)
            do{
                let jsonData = try Data.init(contentsOf: url)
                let athkarSections = try! JSONDecoder().decode([AthkarSection].self, from: jsonData)
                    completion(athkarSections)
    
    
            } catch{
                completion([])
            }
    
        }else{
            completion([])
        }
    }

}
