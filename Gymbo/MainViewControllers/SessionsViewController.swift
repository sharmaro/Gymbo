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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyExerciseLabel: UILabel!

    private lazy var editButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 30)))
        button.setTitle("Edit", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var addSessionButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 30)))
        button.setTitle("+ Session", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.addTarget(self, action: #selector(addSessionButtonTapped), for: .touchUpInside)
        return button
    }()

    private let dataModelManager = SessionDataModelManager.shared

    private var isEditingMode = false

    private struct Constants {
        static let sessionCellHeight: CGFloat = 120
        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItems()
        setupCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshMainView()
    }

    // MARK: - Helper funcs

    private func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addSessionButton)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(SessionsCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SessionsCollectionViewCell.reuseIdentifier)
    }

    private func refreshMainView() {
        collectionView.isHidden = dataModelManager.sessionsCount == 0
        emptyExerciseLabel.isHidden = !collectionView.isHidden

        editButton.isEnabled = !collectionView.isHidden
        editButton.alpha = editButton.isEnabled ? Constants.activeAlpha : Constants.inactiveAlpha

        if !editButton.isEnabled {
            editButton.setTitle("Edit", for: .normal)
        }

        if !collectionView.isHidden {
            collectionView.reloadData()
        }
    }

    // MARK: - @objc Funcs

    @objc private func editButtonTapped() {
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }

        let title = isEditingMode ? "Edit" : "Done"
        editButton.setTitle(title, for: .normal)
        isEditingMode.toggle()
    }

    @objc private func addSessionButtonTapped() {
        guard let addEditSessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddEditSessionViewController") as? AddEditSessionViewController else {
                NSLog("Could not instantiate AddEditSessionViewController.")
                return
        }
        addEditSessionViewController.sessionState = .add
        addEditSessionViewController.sessionDataModelDelegate = self
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }
}

// MARK: - UICollectionView funcs

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

        cell.clearLabels()
        cell.sessionTitleLabel.text = dataModelManager.getSessionName(forIndex: indexPath.row)
        cell.exercisesInfoTextView.text = dataModelManager.sessionInfoText(forIndex: indexPath.row)
        cell.isEditing = isEditingMode
        cell.sessionsCollectionViewCellDelegate = self
        cell.contentView.alpha = 1

        return cell
    }
}

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

extension SessionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isEditingMode,
            let sessionPreviewViewController = storyboard?.instantiateViewController(withIdentifier: "SessionPreviewViewController") as? SessionPreviewViewController,
            let selectedSession = dataModelManager.getSession(forIndex: indexPath.row) else {
            return
        }

        let navigationController = UINavigationController(rootViewController: sessionPreviewViewController)
        if #available(iOS 13.0, *) {
            // No op
        } else {
            navigationController.modalPresentationStyle = .custom
            navigationController.transitioningDelegate = self
        }
        sessionPreviewViewController.selectedSession = selectedSession
        sessionPreviewViewController.sessionDataModelDelegate = self

        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - Saving Session func

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

extension SessionsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
