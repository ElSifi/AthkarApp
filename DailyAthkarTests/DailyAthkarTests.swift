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
        XCTAssertEqual(athkarList.count, 5)
    }

}

class When_opening_a_fresh_install_of_the_app: XCTestCase {

    //test default settings
    //should ask about settings
    //should teach user about the app

}

class When_opening_a_second_opening_of_the_app: XCTestCase {

    //should not ask about settings
    //should not teach user about the app

}

class When_opening_athkar: XCTestCase {

    //athkar should be parsed right
    //should open long and short forms right


}

class When_reading_athkar: XCTestCase{
    //should play sound right
    //should render think sharable image right
    //should move to next think when finished playing one
    //should increment count when tapped
}
