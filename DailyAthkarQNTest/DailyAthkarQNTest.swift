//
//  DailyAthkarQNTest.swift
//  DailyAthkarQNTest
//
//  Created by badi3 on 02/07/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import XCTest
import Quick
import Nimble

@testable import DailyAthkar

class DailyAthkarQNTest: QuickSpec {

    override func spec() {
        describe("DB JSON parsing") {
            it("should parse the local database fine") {
                
                
                var athkarList: [AthkarSection] = []
                AthakrService.getAthkarSectionFromJSONFile { fetchedAthkarList in
                    athkarList = fetchedAthkarList
                }
                
                expect(athkarList.count).toEventually(equal(5))
                
            }
        }
    }

}
