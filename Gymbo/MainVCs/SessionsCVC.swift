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
    private let sessionDataModel = SessionDataModel()

    private var dataState: DataState = .notEditing {
        didSet {
            let itemType: UIBarButtonItem.SystemItem = dataState == .editing ? .done : .edit
            let isDataEmpty = sessionDataModel.isEmpty

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

    private var shouldStartAnotherSession = false
}

// MARK: - Structs/Enums
private extension SessionsCVC {
    struct Constants {
        static let title = "Sessions"

        static let cellMinimumSpacing = CGFloat(10)
        static let sessionCellHeight = CGFloat(120)
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let sessionStartedInsetConstant = CGFloat(50)
    }

    enum DataState {
        case editing
        case notEditing

        mutating func toggle() {
            self = self == .editing ? .notEditing : .editing
        }
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionsCVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
        setupSessionDataModel()

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

        let isDataEmpty = sessionDataModel.isEmpty
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
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
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
    private func setupSessionDataModel() {
        sessionDataModel.dataFetchDelegate = self
        sessionDataModel.fetchData()
    }

    @objc private func updateSessionsUI() {
        let isDataEmpty = sessionDataModel.isEmpty
        collectionView.isHidden = isDataEmpty

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

// MARK: - UICollectionViewDataSource
extension SessionsCVC {
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        sessionDataModel.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sessionsCVCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SessionsCVCell.reuseIdentifier,
                for: indexPath) as? SessionsCVCell else {
            fatalError("Could not dequeue \(SessionsCVCell.reuseIdentifier)")
        }

        var dataModel = SessionsCVCellModel()
        dataModel.title = sessionDataModel.sessionName(for: indexPath.row)
        dataModel.info = sessionDataModel.sessionInfoText(for: indexPath.row)
        dataModel.isEditing = dataState == .editing

        sessionsCVCell.alpha = 1
        sessionsCVCell.configure(dataModel: dataModel)
        sessionsCVCell.sessionsCVCellDelegate = self
        return sessionsCVCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SessionsCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellMinimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.cellMinimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        let totalWidth = collectionView.frame.width
        let columns = CGFloat(2)
        let columnSpacing = CGFloat(10)
        let itemWidth = (totalWidth -
            sectionInset.left -
            sectionInset.right -
            (columnSpacing * (columns - 1))) /
            columns

        return CGSize(width: itemWidth, height: Constants.sessionCellHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension SessionsCVC {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard dataState == .notEditing,
            let selectedSession = sessionDataModel.session(for: indexPath.row) else {
                Haptic.sendNotificationFeedback(.warning)
                return
        }
        Haptic.sendSelectionFeedback()

        let sessionPreviewVC = SessionPreviewVC()
        sessionPreviewVC.session = selectedSession
        sessionPreviewVC.sessionProgressDelegate = mainTBC

        let modalNavigationController = UINavigationController(
            rootViewController: sessionPreviewVC)
        present(modalNavigationController, animated: true)
    }
}

// MARK: - UICollectionViewDragDelegate
extension SessionsCVC: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {

        guard let session = sessionDataModel.session(for: indexPath.row) else {
            let alertData = AlertData(title: "Drag Not Allowed",
                                      content: "Cannot drag this session.",
                                      usesBothButtons: false,
                                      rightButtonTitle: "Sounds good")
            presentCustomAlert(alertData: alertData)
            return [UIDragItem]()
        }
        let itemProvider = NSItemProvider(object: session)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = session
        return [dragItem]
    }

    // Used for showing the view when the session is being dragged
    func collectionView(_ collectionView: UICollectionView,
                        dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SessionsCVCell else {
            return nil
        }

        let previewParameters = UIDragPreviewParameters()
        let path = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)

        previewParameters.visiblePath = path
        previewParameters.backgroundColor = .clear
        return previewParameters
    }
}

// MARK: - UICollectionViewDropDelegate
extension SessionsCVC: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?)
        -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        // It helps to use the (0, 0) if there is only one cell
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)

        switch coordinator.proposal.operation {
        case .move:
            let items = coordinator.items
            for item in items {
                guard let sourceIndexPath = item.sourceIndexPath,
                    let fromSession = sessionDataModel.session(for: sourceIndexPath.row) else {
                    return
                }

                sessionDataModel.remove(at: sourceIndexPath.item)
                sessionDataModel.insert(session: fromSession, at: destinationIndexPath.item)

                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        default:
            return
        }
    }
}

// MARK: - SessionDataModelDelegate
extension SessionsCVC: SessionDataModelDelegate {
    func create(_ session: Session, completion: @escaping (Result<Any?, DataError>) -> Void) {
        sessionDataModel.create(session: session) { [weak self] result in
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
        sessionDataModel.update(currentName,
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

    func sessionDidEnd(_ session: Session?) {
        collectionView.contentInset = .zero
    }
}

// MARK: - SessionsCVCellDelegate
extension SessionsCVC: SessionsCVCellDelegate {
    func delete(cell: SessionsCVCell) {
        guard let index = collectionView.indexPath(for: cell)?.row else {
            return
        }

        let sessionName = sessionDataModel.sessionName(for: index)
        let rightButtonAction = { [weak self] in
            Haptic.sendImpactFeedback(.heavy)
            DispatchQueue.main.async {
                UIView.animate(withDuration: .defaultAnimationTime,
                               delay: 0.0,
                               options: [],
                               animations: {
                                cell.alpha = 0
                               }) { [weak self] (finished) in
                    if finished {
                        self?.sessionDataModel.remove(at: index)
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

// MARK: - DataFetchDelegate
extension SessionsCVC: DataFetchDelegate {
    func didEndFetch() {
        updateSessionsUI()
        collectionView.reloadData()
    }
}
