//
//  AllSessionDaysCVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionDaysCVD: NSObject {
    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension AllSessionDaysCVD {
    struct Constants {
        static let cellHeight = CGFloat(80)
        static let cellMinimumSpacing = CGFloat(20)
    }
}

// MARK: - Funcs
extension AllSessionDaysCVD {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AllSessionDaysCVD: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
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
        CGSize(width: collectionView.frame.width,
               height: Constants.cellHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension AllSessionDaysCVD: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        listDelegate?.didSelectItem(at: indexPath)
    }
}
