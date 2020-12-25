//
//  MultipleSelectionTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class MultipleSelectionTVCell: UITableViewCell {
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private var selectionTitles = [String]()
    private var initiallySelectedIndexPathsSet = Set<IndexPath>()

    weak var multipleSelectionTVCellDelegate: MultipleSelectionTVCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension MultipleSelectionTVCell {
    struct Constants {
        static let minimumLineSpacing = CGFloat(5)
    }
}

// MARK: - UITableViewCell Var/Funcs
extension MultipleSelectionTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension MultipleSelectionTVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [collectionView])
    }

    func setupViews() {
        selectionStyle = .none

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SelectionCVCell.self,
                                forCellWithReuseIdentifier: SelectionCVCell.reuseIdentifier)
    }

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        collectionView.backgroundColor = .dynamicWhite
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension MultipleSelectionTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(titles: [String], selectedTitles: [String] = []) {
        selectionTitles = titles
        initiallySelectedIndexPathsSet.removeAll()

        for selected in selectedTitles {
            if let row = titles.firstIndex(of: selected) {
                initiallySelectedIndexPathsSet.insert(IndexPath(row: row, section: 0))
            }
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension MultipleSelectionTVCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectionTitles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let selectionCVCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SelectionCVCell.reuseIdentifier,
                for: indexPath) as? SelectionCVCell else {
            fatalError("Could not dequeue \(SelectionCVCell.reuseIdentifier)")
        }

        let group = selectionTitles[indexPath.row]
        selectionCVCell.configure(title: group)
        // Setting the tapped state to cells that are initially selected
        if initiallySelectedIndexPathsSet.contains(indexPath) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            selectionCVCell.isSelected = true
            selectionCVCell.tapped()
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            selectionCVCell.isSelected = false
            selectionCVCell.tapped()
        }
        return selectionCVCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MultipleSelectionTVCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalWidth = collectionView.frame.width
        let columns = CGFloat(3)
        let columnSpacing = CGFloat(5)
        let itemWidth = (totalWidth - ((columns - 1) * columnSpacing)) / columns

        let totalHeight = collectionView.frame.height
        let rows = CGFloat(3)
        let rowSpacing = CGFloat(5)
        let itemHeight = (totalHeight - ((rows - 1) * rowSpacing)) / rows

        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension MultipleSelectionTVCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
        guard let selectionCVCell = collectionView.cellForItem(
                at: indexPath) as? SelectionCVCell else {
            return
        }

        selectionCVCell.tapped()
        let selectedText = getTextFrom(indexPaths: collectionView.indexPathsForSelectedItems)
        multipleSelectionTVCellDelegate?.selected(items: selectedText)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
        guard let selectionCVCell = collectionView.cellForItem(
                at: indexPath) as? SelectionCVCell else {
            return
        }

        selectionCVCell.tapped()
        let selectedText = getTextFrom(indexPaths: collectionView.indexPathsForSelectedItems)
        multipleSelectionTVCellDelegate?.selected(items: selectedText)
    }

    private func getTextFrom(indexPaths: [IndexPath]?) -> [String] {
        guard let indexPaths = indexPaths else {
            return []
        }

        var text = [String]()
        indexPaths.forEach {
            text.append(selectionTitles[$0.row])
        }
        return text
    }
}
