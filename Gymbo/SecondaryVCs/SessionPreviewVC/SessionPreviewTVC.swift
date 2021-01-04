//
//  SessionPreviewTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionPreviewTVC: UITableViewController {
    private let tableHeaderView = SessionHV()
    private var didLayoutTableHeaderView = false

    private let startSessionButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start Session"
        button.titleLabel?.textAlignment = .center
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    var customDataSource: SessionPreviewTVDS?
    var customDelegate: SessionPreviewTVD?
    var exercisesTVDS: ExercisesTVDS?
    var sessionsCVDS: SessionsCVDS?

    weak var sessionProgressDelegate: SessionProgressDelegate?
}

// MARK: - Structs/Enums
private extension SessionPreviewTVC {
    struct Constants {
        static let startButtonHeight = CGFloat(45)
        static let startButtonBottomSpacing = CGFloat(-20)
        static let exerciseCellHeight = CGFloat(70)
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionPreviewTVC {
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
            didLayoutTableHeaderView = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionPreviewTVC: ViewAdding {
    func setupNavigationBar() {
        title = "Preview"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editButtonTapped))
    }

    func addViews() {
        view.add(subviews: [startSessionButton])
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
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
extension SessionPreviewTVC {
    private func setupTableHeaderView() {
        let dataModel = customDataSource?
            .getSessionHeaderViewModel() ?? SessionHeaderViewModel()
        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = false
    }

    @objc private func closeButtonTapped() {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
    }

    @objc private func editButtonTapped() {
        guard let session = customDataSource?.session else {
            let alertData = AlertData(content: "Can't edit current Session.",
                                      usesBothButtons: false,
                                      rightButtonTitle: "Sounds good")
            presentCustomAlert(alertData: alertData)
            return
        }
        Haptic.sendSelectionFeedback()

        let createEditSessionTVC = VCFactory.makeCreateEditSessionTVC(user: sessionsCVDS?.user,
                                                                      session: session,
                                                                      state: .edit,
                                                                      exercisesTVDS: exercisesTVDS)
        createEditSessionTVC.customDataSource?.sessionDataModelDelegate = self
        navigationController?.pushViewController(createEditSessionTVC, animated: true)
    }

    @objc private func startSessionButtonTapped(_ sender: Any) {
        Haptic.sendImpactFeedback(.heavy)
        dismiss(animated: true) { [weak self] in
            guard let self = self,
                  let session = self.customDataSource?.session else {
                return
            }
            self.sessionProgressDelegate?.sessionDidStart(session)
        }
    }
}

// MARK: - SessionDataModelDelegate
extension SessionPreviewTVC: SessionDataModelDelegate {
    func update(_ currentName: String,
                session: Session,
                completion: @escaping (Result<Any?, DataError>) -> Void) {
        sessionsCVDS?.update(currentName,
                                session: session) { [weak self] result in
            switch result {
            case .success(let value):
                completion(.success(value))
                self?.customDataSource?.session = session
                DispatchQueue.main.async {
                    self?.setupTableHeaderView()
                    self?.tableView.reloadData()
                    // Updating collectionView in SessionsCVC
                    NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
                }
            case .failure(let error):
                completion(.failure(error))
                guard let alertData = error.exerciseAlertData(exerciseName: session.name ?? "") else {
                    return
                }
                self?.presentCustomAlert(alertData: alertData)
            }
        }
    }
}
