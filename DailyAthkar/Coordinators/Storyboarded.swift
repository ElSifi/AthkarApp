//
//  Storyboarded.swift
//  DailyAthkar
//
//  Created by badi3 on 22/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import Foundation

protocol Storyboarded {
    static func instantiate() -> Self
}


extension Storyboarded where Self:UIViewController{
    static func instantiate()-> Self{
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id) as! Self
    }
}
