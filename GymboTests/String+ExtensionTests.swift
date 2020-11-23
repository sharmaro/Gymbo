//
//  String+ExtensionTests.swift
//  GymboTests
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import XCTest
@testable import Gymbo

class String_ExtensionTests: XCTestCase {
    override class func setUp() {
        super.setUp()
    }

    override class func tearDown() {
        super.tearDown()
    }

    func testSecondsFromTime() {
        var formattedResponse = 0

        formattedResponse = "00:00".secondsFromTime ?? 0
        XCTAssertEqual(formattedResponse, 0)

        formattedResponse = "10:10".secondsFromTime ?? 0
        XCTAssertEqual(formattedResponse, 610)

        formattedResponse = "02:40".secondsFromTime ?? 0
        XCTAssertEqual(formattedResponse, 160)

        formattedResponse = "09:00".secondsFromTime ?? 0
        XCTAssertEqual(formattedResponse, 540)
    }
}
