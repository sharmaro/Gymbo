//
//  UICollectionView+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension UICollectionView {
    func reloadWithoutAnimation() {
        UIView.performWithoutAnimation {
            reloadData()
        }
    }

    func reloadAndScrollToTop() {
        reloadData()
        if numberOfSections > 0,
           numberOfItems(inSection: 0) > 0 {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            scrollToItem(at: firstIndexPath,
                         at: .bottom, animated: true)
        }
    }
}
