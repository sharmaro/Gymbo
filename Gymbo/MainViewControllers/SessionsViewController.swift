//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol SessionDataModelDelegate: class {
    func addSessionData(name: String?, info: String?, exercises: List<Exercise>)
    func saveSelectedSession(_ session: Session)
    func updateSessionCells()
}

import UIKit
import RealmSwift

class SessionsViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var emptyExerciseLabel: UILabel!

    class var id: String {
        return String(describing: self)
    }

    private let dataModelManager = SessionDataModelManager.shared
    private var isEditingMode = false
}

// MARK: - Structs/Enums
private extension SessionsViewController {
    struct Constants {
        static let sessionCellHeight = CGFloat(120)
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
    }
}

// MARK: - UIViewController Funcs
extension SessionsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshMainView()
    }
}

// MARK: - Funcs
extension SessionsViewController {
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+ Session", style: .plain, target: self, action: #selector(addSessionButtonTapped))
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(SessionsCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SessionsCollectionViewCell.reuseIdentifier)
    }

    private func refreshMainView() {
        let isDataEmpty = dataModelManager.sessionsCount == 0
        collectionView.isHidden = isDataEmpty
        emptyExerciseLabel.isHidden = !isDataEmpty

        navigationItem.leftBarButtonItem?.isEnabled = !isDataEmpty
        navigationItem.leftBarButtonItem?.customView?.alpha = isDataEmpty ? Constants.inactiveAlpha : Constants.activeAlpha

        if isDataEmpty {
            navigationItem.leftBarButtonItem?.title = "Edit"
        }

        if !isDataEmpty {
            collectionView.reloadData()
        }
    }

    @objc private func editButtonTapped() {
        let itemType: UIBarButtonItem.SystemItem = isEditingMode ? .edit : .done
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: itemType, target: self, action: #selector(editButtonTapped))
        isEditingMode.toggle()

        /// Reloading data so it can toggle the shaking animation.
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
    }

    @objc private func addSessionButtonTapped() {
        guard let addEditSessionViewController = storyboard?.instantiateViewController(withIdentifier: AddEditSessionViewController.id) as? AddEditSessionViewController else {
                NSLog("Could not instantiate AddEditSessionViewController.")
                return
        }
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
        return dataModelManager.sessionsCount ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SessionsCollectionViewCell.reuseIdentifier, for: indexPath) as? SessionsCollectionViewCell else {
            fatalError("Could not dequeue cell with identifier `SessionsCollectionViewCell`")
        }
        var dataModel = SessionsCollectionViewCellModel()
        dataModel.title = dataModelManager.getSessionName(forIndex: indexPath.row)
        dataModel.info = dataModelManager.sessionInfoText(forIndex: indexPath.row)

        cell.configure(dataModel: dataModel)
        cell.isEditing = isEditingMode
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
        guard !isEditingMode,
            let sessionPreviewViewController = storyboard?.instantiateViewController(withIdentifier: SessionPreviewViewController.id) as? SessionPreviewViewController,
            let selectedSession = dataModelManager.getSession(forIndex: indexPath.row) else {
            return
        }

        sessionPreviewViewController.session = selectedSession
        sessionPreviewViewController.sessionDataModelDelegate = self
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

// MARK: - SessionDataModelDelegate
extension SessionsViewController: SessionDataModelDelegate {
    func addSessionData(name: String?, info: String?, exercises: List<Exercise>) {
        let session = Session(name: name, info: info, exercises: exercises)
        dataModelManager.addSession(session: session)

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
        guard let startSessionViewController = storyboard?.instantiateViewController(withIdentifier: StartSessionViewController.id) as? StartSessionViewController else {
            NSLog("Could not instantiate StartSessionViewController.")
            return
        }

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
                self?.dataModelManager.removeSessionAtIndex(index)
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
