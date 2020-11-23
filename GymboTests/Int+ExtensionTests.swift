//
//  Int+ExtensionTests.swift
//  GymboTests
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import XCTest
@testable import Gymbo

class Int_ExtensionTests: XCTestCase {
    override class func setUp() {
        super.setUp()
    }

    override class func tearDown() {
        super.tearDown()
    }

    func testTwoDigits() {
        var formattedString = ""

        formattedString = 60.twoDigitsString
        XCTAssertEqual(formattedString, "60")

        formattedString = 0.twoDigitsString
        XCTAssertEqual(formattedString, "00")

        formattedString = 10.twoDigitsString
        XCTAssertEqual(formattedString, "10")
    }

    func testMinutesAndSecondsString() {
        var formattedText = ""

        formattedText = 60.minutesAndSecondsString
        XCTAssertEqual(formattedText, "01:00")

        formattedText = 10.minutesAndSecondsString
        XCTAssertEqual(formattedText, "00:10")

        formattedText = 130.minutesAndSecondsString
        XCTAssertEqual(formattedText, "02:10")
    }
}
