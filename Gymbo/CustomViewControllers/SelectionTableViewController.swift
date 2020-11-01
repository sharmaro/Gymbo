//
//  SelectionTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/1/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionTableViewController: UITableViewController {
    private var items: [String]
    private var selected: String
    private let labelTableViewCellHeight = CGFloat(70)

    weak var selectionDelegate: SelectionDelegate?

    init(items: [String], selected: String, title: String = "Selection") {
        self.items = items
        self.selected = selected
        super.init(style: .plain)
        self.title = title
    }

    required init?(coder: NSCoder) {
        items = [String]()
        selected = ""
        super.init(coder: coder)
        title = "Selection"
    }
}
// MARK: - Structs/Enums
extension SelectionTableViewController {}

// MARK: - UIViewController Var/Funcs
extension SelectionTableViewController {
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
extension SelectionTableViewController: ViewAdding {
    func setupNavigationBar() {
        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.register(LabelTableViewCell.self,
                           forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)
    }

    func setupColors() {
        view.backgroundColor = .mainWhite
    }
}

// MARK: - Funcs
extension SelectionTableViewController {}

// MARK: - UITableViewDataSource
extension SelectionTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LabelTableViewCell.reuseIdentifier,
                for: indexPath) as? LabelTableViewCell else {
            fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
        }

        let item = items[indexPath.row]
        cell.configure(text: item)

        if item == selected {
            let imageView = UIImageView(frame: CGRect(origin: .zero,
                                                      size: CGSize(width: 15,
                                                                   height: 15)))
            imageView.tintColor = .mainBlack
            imageView.image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SelectionTableViewController {
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        labelTableViewCellHeight
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        labelTableViewCellHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]

        selectionDelegate?.selected(item: item)
        navigationController?.popViewController(animated: true)
    }
}
