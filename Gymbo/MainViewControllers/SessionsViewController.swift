//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

protocol SessionDataModelDelegate: class {
    func addSessionData(name: String?, info: String?, exercises: List<Exercise>)
    func saveSelectedSession(_ session: Session)
    func updateSessionCells()
}

class SessionsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyExerciseLabel: UILabel!

    class var id: String {
        return String(describing: self)
    }

    private let sessionDataModel = SessionDataModel.shared
    private var dataState: DataState = .notEditing {
        didSet {
            let itemType: UIBarButtonItem.SystemItem = dataState == .editing ? .done : .edit
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: itemType, target: self, action: #selector(editButtonTapped))

            // Reloading data so it can toggle the shaking animation.
            UIView.performWithoutAnimation {
                collectionView.reloadData()
            }
        }
    }
}

// MARK: - Structs/Enums
private extension SessionsViewController {
    struct Constants {
        static let title = "Sessions"

        static let sessionCellHeight = CGFloat(120)
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
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
extension SessionsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        refreshMainView()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshMainView), name: .refreshSessions, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let isDataEmpty = sessionDataModel.count == 0
        navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
        navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ? Constants.inactiveAlpha : Constants.activeAlpha
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dataState = .notEditing
    }
}

// MARK: - Funcs
extension SessionsViewController {
    private func setupNavigationBar() {
        title = Constants.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+ Session", style: .plain, target: self, action: #selector(addSessionButtonTapped))
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.delaysContentTouches = false
        collectionView.dragInteractionEnabled = true
        collectionView.reorderingCadence = .fast
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(SessionsCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SessionsCollectionViewCell.reuseIdentifier)
    }

    @objc private func refreshMainView() {
        let isDataEmpty = sessionDataModel.count == 0
        collectionView.isHidden = isDataEmpty
        emptyExerciseLabel.isHidden = !isDataEmpty

        if isDataEmpty {
            dataState = .notEditing
        }

        navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
        navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ? Constants.inactiveAlpha : Constants.activeAlpha

        collectionView.reloadData()
    }

    @objc private func editButtonTapped() {
        dataState.toggle()
    }

    @objc private func addSessionButtonTapped() {
        let addEditSessionViewController = AddEditSessionViewController.loadFromXib()
        addEditSessionViewController.sessionState = .add
        addEditSessionViewController.sessionDataModelDelegate = self
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension SessionsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessionDataModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SessionsCollectionViewCell.reuseIdentifier, for: indexPath) as? SessionsCollectionViewCell else {
            fatalError("Could not dequeue cell with identifier `SessionsCollectionViewCell`")
        }
        var dataModel = SessionsCollectionViewCellModel()
        dataModel.title = sessionDataModel.sessionName(for: indexPath.row)
        dataModel.info = sessionDataModel.sessionInfoText(for: indexPath.row)
        dataModel.isEditing = dataState == .editing

        cell.contentView.alpha = 1
        cell.configure(dataModel: dataModel)
        cell.sessionsCollectionViewCellDelegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SessionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalWidth = collectionView.bounds.width
        let itemWidth = (totalWidth - 30) / 2

        return CGSize(width: itemWidth, height: Constants.sessionCellHeight)
    }
}

// MARK: - UICollectionViewDelegate
extension SessionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard dataState == .notEditing,
            let selectedSession = sessionDataModel.session(for: indexPath.row) else {
            return
        }

        let sessionPreviewViewController = SessionPreviewViewController.loadFromXib()
        sessionPreviewViewController.session = selectedSession
        sessionPreviewViewController.startSessionDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: sessionPreviewViewController)
        if #available(iOS 13.0, *) {
            // No op
        } else {
            modalNavigationController.modalPresentationStyle = .custom
            modalNavigationController.transitioningDelegate = self
        }
        present(modalNavigationController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDragDelegate
extension SessionsViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        guard let session = sessionDataModel.session(for: indexPath.row) else {
            fatalError("Session to drag at row \(indexPath.row) is nil")
        }
        let itemProvider = NSItemProvider(object: session)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = session

        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SessionsCollectionViewCell else {
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
extension SessionsViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // It helps to use the (0, 0) if there is only one cell
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)

        switch coordinator.proposal.operation {
        case .move:
            let items = coordinator.items
            for item in items {
                guard let sourceIndexPath = item.sourceIndexPath else {
                    return
                }

                collectionView.performBatchUpdates({
                    guard let fromSession = sessionDataModel.session(for: sourceIndexPath.row) else {
                        return
                    }

                    sessionDataModel.remove(at: sourceIndexPath.item)
                    sessionDataModel.insert(session: fromSession, at: destinationIndexPath.item)

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
extension SessionsViewController: SessionDataModelDelegate {
    func addSessionData(name: String?, info: String?, exercises: List<Exercise>) {
        let session = Session(name: name, info: info, exercises: exercises)
        sessionDataModel.add(session: session)

        refreshMainView()
    }

    func saveSelectedSession(_ editedSession: Session) {
        refreshMainView()
    }

    func updateSessionCells() {
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
}

// MARK: - StartSessionDelegate
extension SessionsViewController: StartSessionDelegate {
    func sessionStarted(session: Session?) {
        let startSessionViewController = StartSessionViewController.loadFromXib()
        startSessionViewController.session = session

        let modalNavigationController = UINavigationController(rootViewController: startSessionViewController)
        if #available(iOS 13.0, *) {
            // No op
        } else {
            modalNavigationController.modalPresentationStyle = .custom
            modalNavigationController.transitioningDelegate = self
        }
        present(modalNavigationController, animated: true, completion: nil)
    }
}

// MARK: - SessionsCollectionViewCellDelegate
extension SessionsViewController: SessionsCollectionViewCellDelegate {
    func delete(cell: SessionsCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell)?.row else {
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            cell.contentView.alpha = 0
        }) { [weak self] (finished) in
            if finished {
                self?.sessionDataModel.remove(at: index)
                self?.refreshMainView()
            }
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SessionsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
