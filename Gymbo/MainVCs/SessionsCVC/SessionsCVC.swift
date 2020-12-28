//
//  SessionsCVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/12/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
class SessionsCVC: UICollectionViewController {
    private var dataState: DataState = .notEditing {
        didSet {
            customDataSource?.dataState = dataState

            let itemType: UIBarButtonItem.SystemItem = dataState == .editing ? .done : .edit

            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: itemType,
                                                               target: self,
                                                               action: #selector(editButtonTapped))
            navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
            navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ?
                Constants.inactiveAlpha : Constants.activeAlpha

            // Reloading data so it can toggle the shaking animation.
            collectionView.reloadWithoutAnimation()
        }
    }

    private var isDataEmpty: Bool {
        customDataSource?.isEmpty ?? true
    }

    var customDataSource: SessionsCVDS?
    var customDelegate: SessionsCVD?
}

// MARK: - Structs/Enums
private extension SessionsCVC {
    struct Constants {
        static let title = "Sessions"

        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let sessionStartedInsetConstant = CGFloat(50)
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionsCVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateSessionsUI),
                                               name: .updateSessionsUI,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadCVWithoutAnimation),
                                               name: .reloadDataWithoutAnimation,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
        navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ?
            Constants.inactiveAlpha : Constants.activeAlpha
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dataState = .notEditing
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionsCVC: ViewAdding {
    func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                           target: self,
                                                           action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addSessionButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        collectionView.dataSource = customDataSource
        collectionView.delegate = customDelegate
        collectionView.dragDelegate = customDataSource
        collectionView.dropDelegate = customDataSource

        collectionView.delaysContentTouches = false
        collectionView.dragInteractionEnabled = true
        collectionView.reorderingCadence = .fast
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(SessionsCVCell.self,
                                forCellWithReuseIdentifier: SessionsCVCell.reuseIdentifier)
    }

    func setupColors() {
        navigationController?.view.backgroundColor = .dynamicWhite
        collectionView.backgroundColor = .dynamicWhite
    }
}

// MARK: - Funcs
extension SessionsCVC {
    @objc private func updateSessionsUI() {
        if isDataEmpty {
            dataState = .notEditing
        }

        navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
        navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ?
            Constants.inactiveAlpha : Constants.activeAlpha
    }

    @objc private func editButtonTapped() {
        Haptic.sendSelectionFeedback()
        dataState.toggle()
    }

    @objc private func addSessionButtonTapped() {
        Haptic.sendSelectionFeedback()
        let createEditSessionTVC = CreateEditSessionTVC()
        createEditSessionTVC.sessionState = .create
        createEditSessionTVC.sessionDataModelDelegate = self
        navigationController?.pushViewController(createEditSessionTVC, animated: true)
    }

    @objc private func reloadCVWithoutAnimation() {
        collectionView.reloadWithoutAnimation()
    }
}

// MARK: - ListDataSource
extension SessionsCVC: ListDataSource {
    func reloadData() {
        collectionView.reloadData()
    }

    func deleteCell(cvCell: UICollectionViewCell) {
        guard let cell = cvCell as? SessionsCVCell,
              let index = collectionView.indexPath(for: cell)?.row else {
            return
        }

        let sessionName = cell.sessionName ?? ""
        let rightButtonAction = { [weak self] in
            Haptic.sendImpactFeedback(.heavy)
            DispatchQueue.main.async {
                UIView.animate(withDuration: .defaultAnimationTime) {
                    cell.alpha = 0
                } completion: { [weak self] (finished) in
                    if finished {
                        self?.customDataSource?.remove(at: index)
                        self?.collectionView.deleteItems(at: [.init(row: index, section: 0)])
                        self?.updateSessionsUI()
                    }
                }
            }
        }
        let alertData = AlertData(title: "Delete Session",
                                  content: "Are you sure you want to delete \(sessionName)?",
                                  rightButtonAction: rightButtonAction)
        presentCustomAlert(alertData: alertData)
    }
}

// MARK: - ListDelegate
extension SessionsCVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard dataState == .notEditing,
              let selectedSession = customDataSource?.session(for: indexPath.row) else {
                Haptic.sendNotificationFeedback(.warning)
                return
        }
        Haptic.sendSelectionFeedback()

        let sessionPreviewVC = SessionPreviewVC()
        sessionPreviewVC.session = selectedSession
        sessionPreviewVC.sessionProgressDelegate = mainTBC

        let modalNavigationController = MainNC(rootVC: sessionPreviewVC)
        present(modalNavigationController, animated: true)
    }
}

// MARK: - SessionDataModelDelegate
extension SessionsCVC: SessionDataModelDelegate {
    func create(_ session: Session, completion: @escaping (Result<Any?, DataError>) -> Void) {
        customDataSource?.create(session: session) { [weak self] result in
            switch result {
            case .success(let value):
                completion(.success(value))
                DispatchQueue.main.async {
                    self?.updateSessionsUI()
                    self?.collectionView.reloadWithoutAnimation()
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

    func update(_ currentName: String,
                session: Session,
                completion: @escaping (Result<Any?, DataError>) -> Void) {
        customDataSource?.update(currentName,
                                session: session) { [weak self] result in
            switch result {
            case .success(let value):
                completion(.success(value))
                DispatchQueue.main.async {
                    self?.updateSessionsUI()
                    self?.collectionView.reloadData()
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

// MARK: - SessionProgressDelegate
extension SessionsCVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        collectionView.contentInset.bottom = Constants.sessionStartedInsetConstant
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        collectionView.contentInset = .zero
    }
}

// MARK: - DataFetchDelegate
extension SessionsCVC: DataFetchDelegate {
    func didEndFetch() {
        updateSessionsUI()
        collectionView.reloadData()
    }
}
