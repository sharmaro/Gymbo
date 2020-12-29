//
//  SessionsCVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionsCVD: NSObject {
    var dataState: DataState = .notEditing

    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension SessionsCVD {
    struct Constants {
        static let cellMinimumSpacing = CGFloat(10)
        static let sessionCellHeight = CGFloat(120)
    }
}

// MARK: - Funcs
extension SessionsCVD {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SessionsCVD: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        let sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let totalWidth = collectionView.frame.width
        let columns = CGFloat(2)
        let columnSpacing = CGFloat(10)
        let itemWidth = (totalWidth -
            sectionInset.left -
            sectionInset.right -
            (columnSpacing * (columns - 1))) /
            columns

        return CGSize(width: itemWidth, height: Constants.sessionCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        .zero
    }
}

// MARK: - UICollectionViewDelegate
extension SessionsCVD: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        listDelegate?.didSelectItem(at: indexPath)
    }
}
