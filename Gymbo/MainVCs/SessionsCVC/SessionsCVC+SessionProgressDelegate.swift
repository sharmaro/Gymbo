//
//  SessionsCVC+SessionProgressDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension SessionsCVC: SessionProgressDelegate {
    private struct Constants {
        static let sessionStartedInsetConstant = CGFloat(50)
    }

    func sessionDidStart(_ session: Session?) {
        collectionView.contentInset.bottom = Constants.sessionStartedInsetConstant
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        collectionView.contentInset = .zero
    }
}
