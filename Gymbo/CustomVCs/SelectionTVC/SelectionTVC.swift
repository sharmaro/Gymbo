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
    var customDataSource: SelectionTVDS?
    var customDelegate: SelectionTVD?

    init(title: String = "Selection") {
        super.init(nibName: nil, bundle: nil)

        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
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
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.register(LabelTVCell.self,
                           forCellReuseIdentifier: LabelTVCell.reuseIdentifier)
    }

    func setupColors() {
        [view, tableView].forEach { $0?.backgroundColor = .dynamicWhite }
    }
}
