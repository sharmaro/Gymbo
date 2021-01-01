//
//  DashboardCVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DashboardCVD: NSObject {
    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension DashboardCVD {
    struct Constants {
        static let sessionCellHeight = CGFloat(120)
        static let cellMinimumSpacing = CGFloat(10)
    }
}

// MARK: - Funcs
extension DashboardCVD {
}

// MARK: - UICollectionViewDelegate
extension DashboardCVD: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listDelegate?.didSelectItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        listDelegate?.didDeselectItem(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DashboardCVD: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellMinimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellMinimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width
        let cellWidth = totalWidth - 40
        return CGSize(width: cellWidth,
                      height: Constants.sessionCellHeight)
    }
}
