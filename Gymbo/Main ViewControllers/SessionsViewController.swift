//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class SessionsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var dataModel: [SessionDataModel]?
    
    private let collectionViewCellID = "MenuBarCollectionViewCell"
    // TODO: Create a private id for custom UITableViewCell
    
    private let menuTitles: [String] = ["Quick Start", "My Saved Routines"]
    
    private struct CellHeight {
        public static let quickStart: CGFloat = 100
        public static let savedRoutines: CGFloat = 120
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: [])
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
    }
}

extension SessionsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let menuBarCell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellID, for: indexPath) as? MenuBarCollectionViewCell else {
            fatalError("Could not dequeue `MenuBarCollectionViewCell` at index path: \(indexPath)")
        }
        menuBarCell.titleLabel.text = menuTitles[indexPath.row]
        return menuBarCell
    }
}

extension SessionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Quick Start selected")
        case 1:
            print("My Saved Routines selected")
        default:
            fatalError("Incorrect index path selected: \(indexPath).")
        }
    }
}

extension SessionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.bounds.width / 2) - 10, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}

extension SessionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[section].workouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO:
        return UITableViewCell()
    }
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath)")
    }
}

class MenuBarCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            if isSelected {
                // Do nothing
            } else {
                titleLabel.textColor = isHighlighted ? .black : .lightGray
                underlineView.backgroundColor = isHighlighted ? .black : .lightGray
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? .black : .lightGray
            underlineView.backgroundColor = isSelected ? .black : .lightGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        underlineView.layer.cornerRadius = 1
    }
}

// TODO: Create custom UITableViewCell class
