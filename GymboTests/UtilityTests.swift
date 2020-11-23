//
//  UtilityTests.swift
//  GymboTests
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import XCTest
@testable import Gymbo

class UtilityTests: XCTestCase {
    override class func setUp() {
        super.setUp()
    }

    override class func tearDown() {
        super.tearDown()
    }

    func testFormattedStringTypeName() {
        var formattedString = ""

        formattedString = Utility.formattedString(stringToFormat: "0", type: .name)
        XCTAssertEqual(formattedString, "0")

        formattedString = Utility.formattedString(stringToFormat: "1", type: .name)
        XCTAssertEqual(formattedString, "1")

        formattedString = Utility.formattedString(stringToFormat: "10", type: .name)
        XCTAssertEqual(formattedString, "10")
    }

    func testFormattedStringTypeSets() {
        var formattedString = ""

        formattedString = Utility.formattedString(stringToFormat: "0", type: .sets)
        XCTAssertEqual(formattedString, "0 sets")

        formattedString = Utility.formattedString(stringToFormat: "1", type: .sets)
        XCTAssertEqual(formattedString, "1 set")

        formattedString = Utility.formattedString(stringToFormat: "10", type: .sets)
        XCTAssertEqual(formattedString, "10 sets")
    }

    func testFormattedStringTypeReps() {
        var formattedString = ""

        formattedString = Utility.formattedString(stringToFormat: "0",
                                                  type: .reps(areUnique: true))
        XCTAssertEqual(formattedString, "unique reps")

        formattedString = Utility.formattedString(stringToFormat: "1",
                                                  type: .reps(areUnique: false))
        XCTAssertEqual(formattedString, "1 rep")

        formattedString = Utility.formattedString(stringToFormat: "10",
                                                  type: .reps(areUnique: true))
        XCTAssertEqual(formattedString, "unique reps")
    }

    func testFormattedStringTypeWeight() {
        var formattedString = ""

        formattedString = Utility.formattedString(stringToFormat: "0", type: .weight)
        XCTAssertEqual(formattedString, "0 lbs")

        formattedString = Utility.formattedString(stringToFormat: "1", type: .weight)
        XCTAssertEqual(formattedString, "1 lb")

        formattedString = Utility.formattedString(stringToFormat: "10", type: .weight)
        XCTAssertEqual(formattedString, "10 lbs")
    }

    func testFormattedStringTypeTime() {
        var formattedString = ""

        formattedString = Utility.formattedString(stringToFormat: "0", type: .time)
        XCTAssertEqual(formattedString, "0 secs")

        formattedString = Utility.formattedString(stringToFormat: "1", type: .time)
        XCTAssertEqual(formattedString, "1 sec")

        formattedString = Utility.formattedString(stringToFormat: "10", type: .time)
        XCTAssertEqual(formattedString, "10 secs")
    }

    func testFormatPluralString() {
        var formattedString = ""

        formattedString = Utility.formatPluralString(inputString: "10",
                                                         suffixBase: "base")
        XCTAssertEqual(formattedString, "bases")

        formattedString = Utility.formatPluralString(inputString: "0.5",
                                                         suffixBase: "base")
        XCTAssertEqual(formattedString, "base")

        formattedString = Utility.formatPluralString(inputString: "1",
                                                         suffixBase: "base")
        XCTAssertEqual(formattedString, "base")

        formattedString = Utility.formatPluralString(inputString: "0",
                                                         suffixBase: "base")
        XCTAssertEqual(formattedString, "bases")
    }
}
