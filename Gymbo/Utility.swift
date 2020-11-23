//
//  Utility.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
struct Utility {
}

// MARK: - Funcs
extension Utility {
    static func formattedString(stringToFormat string: String?, type: SessionDetailType) -> String {
        guard let string = string,
            !string.isEmpty else {
            return "--"
        }

        var suffix = ""
        switch type {
        case .name:
            return string
        case .sets:
            suffix = Utility.formatPluralString(inputString: string, suffixBase: "set")
        case .reps(let areUnique):
            if areUnique {
                return "unique reps"
            }

            suffix = Utility.formatPluralString(inputString: string, suffixBase: "rep")
        case .weight:
            suffix = Utility.formatPluralString(inputString: string, suffixBase: "lb")
        case .time:
            suffix = Utility.formatPluralString(inputString: string, suffixBase: "sec")
        }
        return "\(string) \(suffix)"
    }

    static func formatPluralString(inputString: String, suffixBase: String) -> String {
        let isDouble = inputString.contains(".")

        let correctSuffix: String

        if isDouble {
            if let doubleValue = Double(inputString), doubleValue != 0 {
                correctSuffix = doubleValue > 1 ? "\(suffixBase)s" : suffixBase
            } else {
                correctSuffix = "0 \(suffixBase)s"
            }
        } else {
            if let intValue = Int(inputString), intValue != 0 {
                correctSuffix = intValue > 1 ? "\(suffixBase)s" : suffixBase
            } else {
                correctSuffix = "\(suffixBase)s"
            }
        }
        return correctSuffix
    }

    static func getImageFrom(name: String,
                             directory: Directory) -> UIImage? {
        // Get exercise folder name without the file extension
        // Ex: ab roller crunch_0.jpg -> ab roller crunch
        var lastPathComponent = name
        if directory == .exercises {
            let exerciseFolder = name.split(separator: "_").first ?? ""
            lastPathComponent = "\(exerciseFolder)/\(name)"
        }

        guard let contentPath = directory.url?.appendingPathComponent(lastPathComponent).path,
              let fileData = FileManager().contents(atPath: contentPath) else {
            fatalError("Couldn't get image: \(name)")
        }

        return UIImage(data: fileData)
    }

    @discardableResult static func saveImages(name: String,
                                              images: [UIImage],
                                              isUserMade: Bool,
                                              directory: Directory) -> [String]? {
        let lowercasedName = name.lowercased()
        guard let contentURL = directory.url else {
            fatalError("Couldn't get URL for document directory")
        }

        var urls = [URL]()
        for index in 0 ..< images.count {
            let pathExtension = isUserMade ? "\(lowercasedName)_\(index).jpg" : name
            let url = contentURL.appendingPathComponent(pathExtension)
            urls.append(url)
        }

        Utility.createDirectory(at: contentURL.path)

        for (image, url) in zip(images, urls) {
            Utility.saveImage(image: image, url: url, compressionQuality: 1)
        }
        return urls.map { "\($0.path)".replacingOccurrences(of: "\(contentURL.path)/", with: "") }
    }

    private static func createDirectory(at path: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    private static func saveImage(image: UIImage,
                                  url: URL,
                                  compressionQuality: CGFloat) {
        guard let jpegRepresentation = image.jpegData(compressionQuality: 1) else {
            fatalError("Couldn't get jpegData")
        }

        do {
            try jpegRepresentation.write(to: url,
                                        options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    static func removeImages(names: [String]) {
        guard let userImageURL = Directory.userImages.url,
              let userThumbnailsURL = Directory.userThumbnails.url else {
            fatalError("Couldn't get URL to delete: \(names.first ?? "")")
        }

        names.forEach {
            let imagePath = URL(fileURLWithPath: userImageURL.path)
                .appendingPathComponent($0).path
            try? FileManager().removeItem(atPath: imagePath)

            let thumbnailPath = URL(fileURLWithPath: userThumbnailsURL.path)
                .appendingPathComponent($0).path
            try? FileManager().removeItem(atPath: thumbnailPath)
        }
    }
}
