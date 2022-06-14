//
//  Meezan.swift
//  DailyAthkar
//
//  Created by badi3 on 4/6/19.
//  Copyright © 2019 iPhonePal.com. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Meezan {
    static let usersCollectionName = "users"
    
    struct KEYS {
        static let AppLaunchesKeyName = "appLaunchesCount"
    }

    static func recordTheAppLaunch(userUID : String){
        let db = Firestore.firestore()
        let userRef = db.collection(usersCollectionName).document(userUID)
        userRef.updateData([KEYS.AppLaunchesKeyName: FieldValue.increment(Int64(1))])
    }
}
