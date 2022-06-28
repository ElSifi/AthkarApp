//
//  DailyAthkarTests.swift
//  DailyAthkarTests
//
//  Created by badi3 on 27/06/2022.
//  Copyright © 2022 iPhonePal.com. All rights reserved.
//

import XCTest
@testable import DailyAthkar

class DailyAthkarTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_athkarDatabaseIsValid() throws {
        let expectation = XCTestExpectation(description: "Athkar Database Is Valid")
        var athkarList: [AthkarSection] = []
        AthakrService.getAthkarSectionFromJSONFile { fetchedAthkarList in
            athkarList = fetchedAthkarList
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
        XCTAssertFalse(athkarList.isEmpty)
    }

}
