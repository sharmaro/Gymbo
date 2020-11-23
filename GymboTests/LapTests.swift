//
//  LapTests.swift
//  GymboTests
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import XCTest
@testable import Gymbo

class LapTests: XCTestCase {
    var lap = Lap(minutes: 0,
                  seconds: 0,
                  centiSeconds: 0)

    override class func setUp() {
        super.setUp()
    }

    override class func tearDown() {
        super.tearDown()
    }

    func testTotalTime() {
        XCTAssertEqual(lap.totalTime, 0)

        lap = Lap(minutes: 60, seconds: 60, centiSeconds: 60)
        XCTAssertEqual(lap.totalTime, 366_060)

        lap = Lap(minutes: 10, seconds: 0, centiSeconds: 60)
        XCTAssertEqual(lap.totalTime, 60_060)
    }

    func testText() {
        lap = Lap(minutes: 60, seconds: 60, centiSeconds: 60)
        XCTAssertEqual(lap.text, "60:60.60")

        lap = Lap(minutes: 10, seconds: 0, centiSeconds: 60)
        XCTAssertEqual(lap.text, "10:00.60")

        lap = Lap(minutes: 0, seconds: 0, centiSeconds: 0)
        XCTAssertEqual(lap.text, "00:00.00")
    }
}
