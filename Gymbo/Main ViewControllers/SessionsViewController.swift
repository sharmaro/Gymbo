//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

private enum MenuButtonState {
    case quickStart
    case mySavedRoutines
}

class SessionsViewController: UIViewController {
    @IBOutlet weak var menuButtonsContainerView: UIView!
    @IBOutlet weak var quickStartButton: UIButton!
    @IBOutlet weak var mySavedRoutinesButton: UIButton!
    @IBOutlet weak var underlineContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var dataModel: [SessionDataModel]?
    
    private let collectionViewCellID = "MenuBarCollectionViewCell"
    // TODO: Create a private id for custom UITableViewCell
    
    private var menuButtonState = MenuButtonState.quickStart
    
    private lazy var underlineView: UIView = {
       let view = UIView(frame: CGRect(x: quickStartButton.frame.origin.x, y: 0, width: quickStartButton.frame.width, height: underlineContainerView.bounds.height))
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuButtons()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        underlineContainerView.addSubview(underlineView)
    }
    
    private func setupMenuButtons() {
        quickStartButton.tag = 0
        quickStartButton.adjustsImageWhenHighlighted = false
        
        mySavedRoutinesButton.tag = 1
        mySavedRoutinesButton.adjustsImageWhenHighlighted = false
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 0:
                menuButtonState = .quickStart
            case 1:
                menuButtonState = .mySavedRoutines
            default:
                fatalError("Invalid button with tag: \(button.tag).")
            }
            animateUnderlineView(button)
            updateViewFromMenuButton()
        }
    }
    
    private func animateUnderlineView(_ selectedButton: UIButton) {
        if underlineView.frame.origin.x != selectedButton.frame.origin.x {
            UIView.animate(withDuration: 0.2) {
                self.underlineView.frame.size.width = selectedButton.frame.width
                self.underlineView.frame.origin.x = selectedButton.frame.origin.x
            }
        }
    }
    
    private func updateViewFromMenuButton() {
        
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

// TODO: Create custom UITableViewCell class
