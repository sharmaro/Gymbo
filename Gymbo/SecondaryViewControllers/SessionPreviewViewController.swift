//
//  SessionPreviewViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct SessionPreviewInfo {
    var exerciseName: String?
    var exerciseMuscles: String?
}

class SessionPreviewViewController: UIViewController {
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startSessionButton: CustomButton!

    private lazy var closeButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Close", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var editButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Edit", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 1
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    var sessionPreviewInfo: [SessionPreviewInfo]?

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    private struct Constants {
        static let navBarButtonSize: CGSize = CGSize(width: 60, height: 20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupTableView()
        setupStartWorkoutButton()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SessionPreviewTableViewCell.nib,
                           forCellReuseIdentifier: SessionPreviewTableViewCell.reuseIdentifier)

        if sessionPreviewInfo == nil {
            tableView.isHidden = true
        }
    }

    private func setupNavigationItem() {
        customNavigationItem.title = title
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }

    private func setupStartWorkoutButton() {
        startSessionButton.setTitle("Start Session", for: .normal)
        startSessionButton.titleLabel?.textAlignment = .center
        startSessionButton.addCornerRadius()
    }

    @objc private func navBarButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Close button tapped
            dismiss(animated: true, completion: { [weak self] in
                self?.sessionDataModelDelegate?.clearSelectedSessionIndex()
            })
        case 1: // Edit button tapped
            dismiss(animated: true, completion: { [weak self] in
                self?.sessionDataModelDelegate?.editSelectedSession()
            })
        default:
            fatalError("Unrecognized navigation bar button pressed")
        }
    }

    @IBAction func startSessionButtonTapped(_ sender: Any) {
        print(#function)
        dismiss(animated: true, completion: nil)
        // Call some delegate function that presents a new screen where the workout has started
    }
}

extension SessionPreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionPreviewInfo?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sessionPreviewCell = tableView.dequeueReusableCell(withIdentifier: SessionPreviewTableViewCell.reuseIdentifier, for: indexPath) as? SessionPreviewTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(WorkoutDetailTableViewCell.reuseIdentifier)`.")
        }

        sessionPreviewCell.clearLabels()
        sessionPreviewCell.exerciseNameLabel.text = sessionPreviewInfo?[indexPath.row].exerciseName
        sessionPreviewCell.exerciseMusclesLabel.text = sessionPreviewInfo?[indexPath.row].exerciseMuscles

        return sessionPreviewCell
    }
}

extension SessionPreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected index path: \(indexPath)")
    }
}
