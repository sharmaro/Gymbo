//
//  SessionPreviewViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct ExerciseInfo {
    var exerciseName: String?
    var exerciseMuscles: String?
}

// MARK: - Properties
class SessionPreviewViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

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

    private lazy var startSessionButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.title = "Start Session"
        button.titleLabel?.textAlignment = .center
        button.add(backgroundColor: .systemBlue)
        button.addCorner()
        button.addTarget(self, action: #selector(startSessionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var session: Session?
    var exerciseInfoList: [ExerciseInfo]?

    private let dataModelManager = SessionDataModel.shared

    weak var sessionProgressDelegate: SessionProgressDelegate?
}

// MARK: - Structs/Enums
private extension SessionPreviewViewController {
    struct Constants {
        static let title = "Preview"

        static let sessionPreviewCellHeight = CGFloat(62)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionPreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupNavigationBar()
        addMainViews()
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

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    private func addMainViews() {
        view.addSubviews(views: [tableView, startSessionButton])
    }

    private func setupTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: startSessionButton.topAnchor, constant: -15)
        ])

        tableView.delegate = self
        tableView.dataSource = self
        // Removes extra lines below shown data
        tableView.tableFooterView = UIView()
        tableView.register(ExerciseTableViewCell.self,
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
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    private func setupStartSessionButton() {
        view.addSubview(startSessionButton)

        NSLayoutConstraint.activate([
            startSessionButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            startSessionButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            startSessionButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            startSessionButton.heightAnchor.constraint(equalToConstant: 45)
        ])
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
            presentCustomAlert(content: "Can't edit current Session.", usesBothButtons: false, rightButtonTitle: "Sounds good") {
            }
            return
        }

        let addEditSessionViewController = AddEditSessionViewController()
        addEditSessionViewController.sessionState = .edit
        addEditSessionViewController.session = session
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }

    @objc private func startSessionButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        sessionProgressDelegate?.sessionDidStart(session)
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
            presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
            return UITableViewCell()
        }

        let name = exerciseInfoList?[indexPath.row].exerciseName
        let muscles = exerciseInfoList?[indexPath.row].exerciseMuscles
        let dataModel = ExerciseText(name: name, muscles: muscles, isUserMade: false)

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
