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
}
