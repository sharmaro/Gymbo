//
//  Directory.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/16/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

enum Directory {
    case workoutInfo
    case exercises
    case stockThumbnails
    case userImages
    case userThumbnails

    var directory: String {
        let baseStockPath = "Workout Info"
        let response: String

        switch self {
        case .workoutInfo:
            response = baseStockPath
        case .exercises:
            response = "\(baseStockPath)/Exercises"
        case .stockThumbnails:
            response = "\(baseStockPath)/Stock Thumbnails"
        case .userImages:
            response = "User Images"
        case .userThumbnails:
            response = "User Thumbnails"
        }
        return response
    }

    var isStockDirectory: Bool {
        self == .workoutInfo ||
        self == .exercises ||
        self == .stockThumbnails
    }

    var url: URL? {
        let url: URL?
        if isStockDirectory {
            guard let resourcePath = Bundle.main.resourcePath else {
                fatalError("Couldn't get main resource path")
            }

            url = URL(fileURLWithPath: resourcePath)
        } else {
            url = FileManager().urls(for: .documentDirectory,
                                            in: .userDomainMask).first
        }
        return url?.appendingPathComponent(directory)
    }
}
