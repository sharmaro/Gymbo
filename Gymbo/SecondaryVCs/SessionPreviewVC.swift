//
//  SessionPreviewVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionPreviewVC: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let tableHeaderView = SessionHeaderView()
    private var didLayoutTableHeaderView = false

    private let startSessionButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start Session"
        button.titleLabel?.textAlignment = .center
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    var session: Session?

    weak var sessionProgressDelegate: SessionProgressDelegate?
}

// MARK: - Structs/Enums
private extension SessionPreviewVC {
    struct Constants {
        static let title = "Preview"

        static let startButtonHeight = CGFloat(45)
        static let startButtonBottomSpacing = CGFloat(-20)
        static let exerciseCellHeight = CGFloat(70)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionPreviewVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        if !didLayoutTableHeaderView {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.tableHeaderView?.layoutIfNeeded()
                self.tableView.tableHeaderView = self.tableView.tableHeaderView
            }
        }
        didLayoutTableHeaderView = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionPreviewVC: ViewAdding {
    func setupNavigationBar() {
        title = Constants.title

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView, startSessionButton])
    }

    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseTVCell.self,
                           forCellReuseIdentifier: ExerciseTVCell.reuseIdentifier)

        let spacing = CGFloat(15)
        tableView.contentInset.bottom = Constants.startButtonHeight +
                                        (-1 * Constants.startButtonBottomSpacing) +
                                        spacing

        setupTableHeaderView()

        startSessionButton.addTarget(self, action: #selector(startSessionButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .dynamicWhite }
    }

    func addConstraints() {
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = tableHeaderView

        NSLayoutConstraint.activate([
            tableView.safeAreaLayoutGuide.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor),

            startSessionButton.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            startSessionButton.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            startSessionButton.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Constants.startButtonBottomSpacing),
            startSessionButton.heightAnchor.constraint(equalToConstant: Constants.startButtonHeight)
        ])
    }
}

// MARK: - Funcs
extension SessionPreviewVC {
    private func setupTableHeaderView() {
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .dynamicBlack

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = false
    }

    @objc private func cancelButtonTapped() {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
    }

    @objc private func editButtonTapped() {
        Haptic.sendSelectionFeedback()
        guard let session = session else {
            let alertData = AlertData(content: "Can't edit current Session.",
                                      usesBothButtons: false,
                                      rightButtonTitle: "Sounds good")
            presentCustomAlert(alertData: alertData)
            return
        }

        let createEditSessionTVC = CreateEditSessionTVC()
        createEditSessionTVC.sessionState = .edit
        createEditSessionTVC.session = session
        createEditSessionTVC.sessionDataModelDelegate = self
        navigationController?.pushViewController(createEditSessionTVC, animated: true)
    }

    @objc private func startSessionButtonTapped(_ sender: Any) {
        Haptic.sendImpactFeedback(.heavy)
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.sessionProgressDelegate?.sessionDidStart(self.session)
        }
    }
}

// MARK: - UITableViewDataSource
extension SessionPreviewVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        session?.exercises.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let exerciseTVCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseTVCell.reuseIdentifier,
            for: indexPath) as? ExerciseTVCell,
            let exercise = session?.exercises[indexPath.row] else {
            fatalError("Could not dequeue \(ExerciseTVCell.reuseIdentifier)")
        }

        exerciseTVCell.configure(dataModel: exercise)
        return exerciseTVCell
    }
}

// MARK: - UITableViewDelegate
extension SessionPreviewVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.exerciseCellHeight
    }
}

// MARK: -
extension SessionPreviewVC: SessionDataModelDelegate {
    func update(_ currentName: String,
                session: Session,
                completion: @escaping (Result<Any?, DataError>) -> Void) {
//        sessionDataModel.update(currentName,
//                                session: session) { [weak self] result in
//            switch result {
//            case .success(let value):
//                completion(.success(value))
//                self?.session = session
//                DispatchQueue.main.async {
//                    self?.setupTableHeaderView()
//                    self?.tableView.reloadData()
//                    // Updating collectionView in SessionsCVC
//                    NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
//                }
//            case .failure(let error):
//                completion(.failure(error))
//                guard let alertData = error.exerciseAlertData(exerciseName: session.name ?? "") else {
//                    return
//                }
//                self?.presentCustomAlert(alertData: alertData)
//            }
//        }
    }
}
