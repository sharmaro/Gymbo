//
//  MultipleSelectionTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class MultipleSelectionTableViewCell: UITableViewCell {
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private var selectionTitles = [String]() {
        didSet {
            collectionView.reloadData()
        }
    }
    private var initiallySelectedIndexPathsSet = Set<IndexPath>()

    weak var multipleSelectionTableViewCellDelegate: MultipleSelectionTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - Structs/Enums
private extension MultipleSelectionTableViewCell {
    struct Constants {
        static let minimumLineSpacing = CGFloat(5)
    }
}

// MARK: - UITableViewCell Var/Funcs
extension MultipleSelectionTableViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension MultipleSelectionTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [collectionView])
    }

    func setupViews() {
        selectionStyle = .none

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SelectionCollectionViewCell.self,
                                forCellWithReuseIdentifier: SelectionCollectionViewCell.reuseIdentifier)
    }

    func setupColors() {
        backgroundColor = .mainWhite
        contentView.backgroundColor = .clear
        collectionView.backgroundColor = .mainWhite
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
extension MultipleSelectionTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(titles: [String], selectedTitles: [String] = []) {
        selectionTitles = titles

        for selected in selectedTitles {
            if let row = titles.firstIndex(of: selected) {
                initiallySelectedIndexPathsSet.insert(IndexPath(row: row, section: 0))
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MultipleSelectionTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectionTitles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let selectionCollectionViewCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectionCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SelectionCollectionViewCell else {
            fatalError("Could not dequeue \(SelectionCollectionViewCell.reuseIdentifier)")
        }

        let group = selectionTitles[indexPath.row]
        selectionCollectionViewCell.configure(title: group)
        // Setting the tapped state to cells that are initially selected, then removing them from the set
        if initiallySelectedIndexPathsSet.contains(indexPath) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            selectionCollectionViewCell.isSelected = true
            selectionCollectionViewCell.tapped()
            initiallySelectedIndexPathsSet.remove(indexPath)
        }
        return selectionCollectionViewCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MultipleSelectionTableViewCell: UICollectionViewDelegateFlowLayout {
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
extension MultipleSelectionTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
        guard let selectionCollectionViewCell = collectionView.cellForItem(
            at: indexPath) as? SelectionCollectionViewCell else {
            return
        }

        selectionCollectionViewCell.tapped()
        let selectedText = getTextFrom(indexPaths: collectionView.indexPathsForSelectedItems)
        multipleSelectionTableViewCellDelegate?.selected(items: selectedText)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
        guard let selectionCollectionViewCell = collectionView.cellForItem(
            at: indexPath) as? SelectionCollectionViewCell else {
            return
        }

        selectionCollectionViewCell.tapped()
        let selectedText = getTextFrom(indexPaths: collectionView.indexPathsForSelectedItems)
        multipleSelectionTableViewCellDelegate?.selected(items: selectedText)
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
