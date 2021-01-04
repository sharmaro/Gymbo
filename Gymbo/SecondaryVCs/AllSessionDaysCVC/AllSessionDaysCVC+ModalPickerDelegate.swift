//
//  AllSessionDaysCVC+ModalPickerDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import Foundation

extension AllSessionDaysCVC: ModalPickerDelegate {
    func selected(row: Int) {
        customDataSource?.selected(index: row)
        collectionView.reloadAndScrollToTop()
    }
}
