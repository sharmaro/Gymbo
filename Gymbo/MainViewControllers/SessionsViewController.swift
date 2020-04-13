//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

protocol SessionProgressDelegate: class {
    func sessionDidStart(_ session: Session?)
    func sessionDidEnd(_ session: Session?)
}

protocol SessionDataModelDelegate: class {
    func addSessionData(name: String?, info: String?, exercises: List<Exercise>)
    func saveSelectedSession(_ session: Session)
    func updateSessionCells()
}

// MARK: - Properties
class SessionsViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyExerciseLabel: UILabel!

    class var id: String {
        return String(describing: self)
    }

    private let sessionDataModel = SessionDataModel.shared
    private var dataState: DataState = .notEditing {
        didSet {
            let itemType: UIBarButtonItem.SystemItem = dataState == .editing ? .done : .edit
            let isDataEmpty = sessionDataModel.isEmpty

            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: itemType, target: self, action: #selector(editButtonTapped))
            navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
            navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ? Constants.inactiveAlpha : Constants.activeAlpha

            // Reloading data so it can toggle the shaking animation.
            UIView.performWithoutAnimation {
                collectionView.reloadData()
            }
        }
    }

    private var shouldStartAnotherSession = false
}

// MARK: - Structs/Enums
private extension SessionsViewController {
    struct Constants {
        static let title = "Sessions"

        static let sessionCellHeight = CGFloat(120)
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let defaultYOffset = CGFloat(60)
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
        updateSessionsUI()

        NotificationCenter.default.addObserver(self, selector: #selector(updateSessionsUI), name: .updateSessionsUI, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let isDataEmpty = sessionDataModel.isEmpty
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

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
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

    @objc private func updateSessionsUI() {
        let isDataEmpty = sessionDataModel.isEmpty
        collectionView.isHidden = isDataEmpty
        emptyExerciseLabel.isHidden = !isDataEmpty

        if isDataEmpty {
            dataState = .notEditing
        }

        navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
        navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ? Constants.inactiveAlpha : Constants.activeAlpha
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
            presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
            return UICollectionViewCell()
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0

        UIView.animate(withDuration: 0.5) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard dataState == .notEditing,
            let selectedSession = sessionDataModel.session(for: indexPath.row) else {
            return
        }

        let sessionPreviewViewController = SessionPreviewViewController.loadFromXib()
        sessionPreviewViewController.session = selectedSession
        sessionPreviewViewController.sessionProgressDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: sessionPreviewViewController)
        if #available(iOS 13.0, *) {
            // No op
        } else {
            modalNavigationController.modalPresentationStyle = .custom
            modalNavigationController.transitioningDelegate = self
        }
        present(modalNavigationController, animated: true)
    }
}

// MARK: - UICollectionViewDragDelegate
extension SessionsViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        guard let session = sessionDataModel.session(for: indexPath.row) else {
            presentCustomAlert(title: "Drag Not Allowed", content: "Cannot drag this session.", usesBothButtons: false, rightButtonTitle: "Sounds good")
            return [UIDragItem]()
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

        let items = collectionView.numberOfItems(inSection: 0)
        collectionView.insertItems(at: [.init(row: items, section: 0)])

        updateSessionsUI()
    }

    func saveSelectedSession(_ editedSession: Session) {
        updateSessionsUI()
        collectionView.reloadData()
    }

    func updateSessionCells() {
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }
}

// MARK: - SessionProgressDelegate
extension SessionsViewController: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        guard let isSessionInProgress = tabBarViewController?.isSessionInProgress else {
            return
        }

        if isSessionInProgress {
            presentCustomAlert(title: "Another One?", content: "You already have a workout in progress!", usesBothButtons: true, leftButtonTitle: "My Bad", rightButtonTitle: "Start New Workout") { [weak self] in
                self?.shouldStartAnotherSession = true
                NotificationCenter.default.post(name: .endSession, object: nil)
            }
        } else {
            startSession(session)
        }
    }

    private func startSession(_ session: Session?) {
        guard let tabBarViewController = navigationController?.tabBarViewController else {
            return
        }

        tabBarViewController.isSessionInProgress = true

        let dimmedView = UIView(frame: tabBarViewController.view.frame)
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let shadowContainerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: tabBarViewController.view.frame.height), size: CGSize(width: tabBarViewController.view.frame.width, height: tabBarViewController.view.frame.height - Constants.defaultYOffset)))
        shadowContainerView.addShadow(direction: .up)
        shadowContainerView.hideShadow()

        let startSessionViewController = StartSessionViewController.loadFromXib()
        startSessionViewController.session = session
        startSessionViewController.sessionProgresssDelegate = self
        startSessionViewController.dimmedView = dimmedView
        startSessionViewController.panView = shadowContainerView
        startSessionViewController.initialTabBarFrame = tabBarViewController.tabBar.frame
        // This allows startSessionViewController to extend over the bottom tab bar
        startSessionViewController.extendedLayoutIncludesOpaqueBars = true

        let containerNavigationController = UINavigationController(rootViewController: startSessionViewController)
        containerNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        containerNavigationController.view.roundCorner(radius: 10)

        shadowContainerView.addSubview(containerNavigationController.view)
        containerNavigationController.view.autoPinEdgesTo(superView: shadowContainerView)

        tabBarViewController.view.insertSubview(shadowContainerView, belowSubview: tabBarViewController.tabBar)
        tabBarViewController.addChild(containerNavigationController)
        containerNavigationController.didMove(toParent: tabBarViewController)

        tabBarViewController.view.insertSubview(dimmedView, belowSubview: shadowContainerView)
        tabBarViewController.view.layoutIfNeeded()

        UIView.animate(withDuration: 0.4, delay: 0.1, animations: {
            shadowContainerView.frame.origin = CGPoint(x: 0, y: Constants.defaultYOffset)
            tabBarViewController.tabBar.frame.origin = CGPoint(x: 0, y: tabBarViewController.view.frame.height)
        })
    }

    func sessionDidEnd(_ session: Session?) {
        tabBarViewController?.isSessionInProgress = false
        if shouldStartAnotherSession {
            tabBarViewController?.isSessionInProgress = true
            shouldStartAnotherSession = false

            startSession(session)
        }
    }
}

// MARK: - SessionsCollectionViewCellDelegate
extension SessionsViewController: SessionsCollectionViewCellDelegate {
    func delete(cell: SessionsCollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell)?.row else {
            return
        }

        let sessionName = sessionDataModel.sessionName(for: index)
        presentCustomAlert(title: "Delete Session", content: "Are you sure you want to delete \(sessionName)? This cannot be undone.") { [weak self] in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                    cell.contentView.alpha = 0
                }) { [weak self] (finished) in
                    if finished {
                        self?.sessionDataModel.remove(at: index)
                        self?.collectionView.deleteItems(at: [.init(row: index, section: 0)])
                        self?.updateSessionsUI()
                    }
                }
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
