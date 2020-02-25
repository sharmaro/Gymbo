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
    // MARK: - Properties
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var startSessionButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private lazy var tableHeaderView: SessionHeaderView = {
        var dataModel = SessionHeaderViewModel()
        dataModel.name = session?.name ?? Constants.namePlaceholderText
        dataModel.info = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .black

        let sessionTableHeaderView = SessionHeaderView()
        sessionTableHeaderView.configure(dataModel: dataModel)
        sessionTableHeaderView.isContentEditable = false
        sessionTableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        return sessionTableHeaderView
    }()

    var session: Session?
    var exerciseInfoList: [ExerciseInfo]?

    private let dataModelManager = SessionDataModel.shared

    weak var startSessionDelegate: StartSessionDelegate?
}

// MARK: - Structs/Enums
private extension SessionPreviewViewController {
    struct Constants {
        static let title = "Preview"

        static let sessionPreviewCellHeight = CGFloat(62)

        static let navBarButtonSize = CGSize(width: 80, height: 30)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionPreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupTableHeaderView()
        setupStartSessionButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard isViewLoaded,
            let session = session else {
                return
        }

        title = Constants.title
        exerciseInfoList = dataModelManager.exerciseInfoList(for: session)

        var dataModel = SessionHeaderViewModel()
        dataModel.name = session.name
        dataModel.info = session.info
        dataModel.textColor = .black
        tableHeaderView.configure(dataModel: dataModel)

        updateTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension SessionPreviewViewController {
     private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        // Removes extra lines below shown data
        tableView.tableFooterView = UIView()
        tableView.register(ExerciseTableViewCell.nib,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)
    }

    private func setupTableHeaderView() {
        tableView.tableHeaderView = tableHeaderView

        NSLayoutConstraint.activate([
            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            tableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20),
            tableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        tableHeaderView.backgroundColor = .red

        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    private func setupStartSessionButton() {
        startSessionButton.title = "Start Session"
        startSessionButton.titleLabel?.textAlignment = .center
        startSessionButton.add(backgroundColor: .systemBlue)
        startSessionButton.addCorner()
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
        guard let session = session else {
            fatalError("Can't edit current session")
        }

        let addEditSessionViewController = AddEditSessionViewController.loadFromXib()
        addEditSessionViewController.sessionState = .edit
        addEditSessionViewController.session = session
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }

    @IBAction func startSessionButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        startSessionDelegate?.sessionStarted(session: session)
    }
}

// MARK: - UITableViewDataSource
extension SessionPreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseInfoList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let exerciseTableViewCell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(ExerciseTableViewCell.reuseIdentifier)`.")
        }

        let name = exerciseInfoList?[indexPath.row].exerciseName
        let muscles = exerciseInfoList?[indexPath.row].exerciseMuscles
        let dataModel = ExerciseText(exerciseName: name, exerciseMuscles: muscles, isUserMade: false)

        exerciseTableViewCell.configure(dataModel: dataModel)
        return exerciseTableViewCell
    }
}

// MARK: - UITableViewDelegate
extension SessionPreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.sessionPreviewCellHeight
    }
}
