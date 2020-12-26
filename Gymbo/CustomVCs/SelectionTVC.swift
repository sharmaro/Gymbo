//
//  SelectionTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/1/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionTVC: UITableViewController {
    private var items: [String]
    private var selected: String

    weak var selectionDelegate: SelectionDelegate?

    init(items: [String], selected: String, title: String = "Selection") {
        self.items = items
        self.selected = selected
        super.init(style: .plain)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension SelectionTVC {
    struct Constants {
        static let labelTVCellHeight = CGFloat(70)
    }
}

// MARK: - UIViewController Var/Funcs
extension SelectionTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SelectionTVC: ViewAdding {
    func setupNavigationBar() {
        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.register(LabelTVCell.self,
                           forCellReuseIdentifier: LabelTVCell.reuseIdentifier)
    }

    func setupColors() {
        view.backgroundColor = .dynamicWhite
    }
}

// MARK: - Funcs
extension SelectionTVC {}

// MARK: - UITableViewDataSource
extension SelectionTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LabelTVCell.reuseIdentifier,
                for: indexPath) as? LabelTVCell else {
            fatalError("Could not dequeue \(LabelTVCell.reuseIdentifier)")
        }

        let item = items[indexPath.row]
        cell.configure(text: item)
        cell.accessoryView = nil

        if item == selected {
            let imageView = UIImageView(frame: CGRect(origin: .zero,
                                                      size: CGSize(width: 15,
                                                                   height: 15)))
            imageView.tintColor = .dynamicBlack
            imageView.image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
            cell.accessoryView = imageView
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SelectionTVC {
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.labelTVCellHeight
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.labelTVCellHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()

        let item = items[indexPath.row]

        selectionDelegate?.selected(item: item)
        navigationController?.popViewController(animated: true)
    }
}
