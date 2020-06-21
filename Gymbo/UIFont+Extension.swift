//
//  UIFont+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension UIFont {
    private func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits) ?? UIFontDescriptor()
        return UIFont(descriptor: descriptor, size: 0) // 0 size means it's unaffected
    }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let traits = [UIFontDescriptor.TraitKey.weight: weight]
        let descriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: traits])
        return UIFont(descriptor: descriptor, size: 0) // 0 size means it's unaffected
    }

    static let xxSmall = UIFont.systemFont(ofSize: .xxSmall)
    static let xSmall = UIFont.systemFont(ofSize: .xSmall)
    static let small = UIFont.systemFont(ofSize: .small)
    static let normal = UIFont.systemFont(ofSize: .normal)
    static let medium = UIFont.systemFont(ofSize: .medium)
    static let large = UIFont.systemFont(ofSize: .large)
    static let xLarge = UIFont.systemFont(ofSize: .xLarge)
    static let xxLarge = UIFont.systemFont(ofSize: .xxLarge)
    static let huge = UIFont.systemFont(ofSize: .huge)

    var ultraLight: UIFont {
        return withWeight(.ultraLight)
    }

    var light: UIFont {
        return withWeight(.light)
    }

    var regular: UIFont {
        return withWeight(.regular)
    }

    var medium: UIFont {
        return withWeight(.medium)
    }

    var semibold: UIFont {
        return withWeight(.semibold)
    }

    var heavy: UIFont {
        return withWeight(.heavy)
    }

    var bold: UIFont {
        return withTraits(.traitBold)
    }

    var italic: UIFont {
        return withTraits(.traitItalic)
    }
}
