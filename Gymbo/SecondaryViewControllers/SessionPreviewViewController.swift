//
//  SessionsPreviewViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol StartSessionDelegate: class {
    func sessionStarted(session: Session?)
}

struct ExerciseInfo {
    var exerciseName: String?
    var exerciseMuscles: String?
}

class SessionPreviewViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startSessionButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private lazy var sessionTableHeaderView: SessionTableHeaderView = {
        let sessionTableHeaderView = SessionTableHeaderView()
        sessionTableHeaderView.nameTextView.text = session?.name ?? Constants.sessionNamePlaceholderText
        sessionTableHeaderView.infoTextView.text = session?.info ?? Constants.sessionInfoPlaceholderText

        sessionTableHeaderView.isContentEditable = false
        sessionTableHeaderView.translatesAutoresizingMaskIntoConstraints = false

        return sessionTableHeaderView
    }()

    var session: Session?
    var exerciseInfoList: [ExerciseInfo]?

    private let dataModelManager = SessionDataModelManager.shared

    weak var sessionDataModelDelegate: SessionDataModelDelegate?
    weak var startSessionDelegate: StartSessionDelegate?

    private struct Constants {
        static let sessionPreviewCellHeight = CGFloat(55)

        static let navBarButtonSize = CGSize(width: 80, height: 30)

        static let title = "Preview"
        static let sessionNamePlaceholderText = "Session name"
        static let sessionInfoPlaceholderText = "No Info"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard isViewLoaded,
            let session = session else {
                return
        }

        title = Constants.title
        exerciseInfoList = dataModelManager.getExerciseInfoList(forSession: session)

        updateSessionTextViews(name: session.name, info: session.info)
        updateTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupTableHeaderView()
        setupStartSessionButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sessionDataModelDelegate?.updateSessionCells()
    }

     private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SessionPreviewTableViewCell.nib,
                           forCellReuseIdentifier: SessionPreviewTableViewCell.reuseIdentifier)
    }

    private func setupTableHeaderView() {
        tableView.tableHeaderView = sessionTableHeaderView

        NSLayoutConstraint.activate([
            sessionTableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            sessionTableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            sessionTableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20),
            sessionTableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        sessionTableHeaderView.backgroundColor = .red

        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    private func setupStartSessionButton() {
        startSessionButton.setTitle("Start Session", for: .normal)
        startSessionButton.titleLabel?.textAlignment = .center
        startSessionButton.addColor(backgroundColor: .systemBlue)
        startSessionButton.addCornerRadius()
    }

    private func updateSessionTextViews(name: String?, info: String?) {
        sessionTableHeaderView.nameTextView.text = name
        sessionTableHeaderView.infoTextView.text = info
    }

    private func updateTableView() {
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func editButtonTapped() {
        guard let session = session,
            let addEditSessionViewController = storyboard?.instantiateViewController(withIdentifier: AddEditSessionViewController.id) as? AddEditSessionViewController else {
                NSLog("Could not instantiate AddEditSessionViewController.")
                return
        }

        addEditSessionViewController.sessionState = .edit
        addEditSessionViewController.session = session
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }

    @IBAction func startSessionButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        startSessionDelegate?.sessionStarted(session: session)
    }
}

extension SessionPreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseInfoList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sessionPreviewCell = tableView.dequeueReusableCell(withIdentifier: SessionPreviewTableViewCell.reuseIdentifier, for: indexPath) as? SessionPreviewTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(SessionPreviewTableViewCell.reuseIdentifier)`.")
        }

        sessionPreviewCell.clearLabels()
        sessionPreviewCell.exerciseNameLabel.text = exerciseInfoList?[indexPath.row].exerciseName
        sessionPreviewCell.exerciseMusclesLabel.text = exerciseInfoList?[indexPath.row].exerciseMuscles

        return sessionPreviewCell
    }
}

extension SessionPreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.sessionPreviewCellHeight
    }
}
