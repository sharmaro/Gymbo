//
//  Date+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/1/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import Foundation

extension Date {
    func formattedString(type: SizeType) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        switch type {
        case .short:
            dateFormatter.dateFormat = "EE., MMM. dd, YY"
        case .medium:
            dateFormatter.dateFormat = "EEEE, MMMM dd, YYYY"
        case .long:
            dateFormatter.dateFormat = "EEEE, MMMM dd, YYYY | hh:mm:ss a"
        }
        return dateFormatter.string(from: date)
    }

    func isEqual(to date: Date,
                 toGranularity component: Calendar.Component,
                 in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSame(component: Calendar.Component, as date: Date) -> Bool {
        isEqual(to: date, toGranularity: component)
    }

    func isSameCalendarDate(as date: Date) -> Bool {
        isEqual(to: date, toGranularity: .year) &&
        isEqual(to: date, toGranularity: .month) &&
        isEqual(to: date, toGranularity: .day)
    }
}
