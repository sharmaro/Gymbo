//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol SessionDataModelDelegate: class {
    func addSessionData(name: String?, workouts: List<Workout>)
    func editSelectedSession()
    func saveSelectedSession(_ session: Session)
    func clearSelectedSessionIndex()
}

import UIKit
import RealmSwift

class SessionsViewController: UIViewController {
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addSessionButton: CustomButton!
    @IBOutlet weak var emptyExerciseLabel: UILabel!

    private let dataModelManager = SessionDataModelManager.shared

    private var selectedIndex: Int?

    private var isEditingMode = false

    private struct Constants {
        static let sessionCellHeight: CGFloat = 120
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupAddSessionButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshMainView()
    }

    // MARK: - Helper funcs

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
        if !collectionView.isHidden {
            collectionView.reloadData()
        }
    }

    private func setupAddSessionButton() {
        addSessionButton.setTitle("+ Add Session", for: .normal)
        addSessionButton.titleLabel?.textAlignment = .center
        addSessionButton.addCornerRadius()
    }

    // MARK: - IBAction funcs


    @IBAction func editButtonTapped(_ sender: Any) {
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }

        editButton.title = isEditingMode ? "Edit" : "Done"
        isEditingMode.toggle()
    }

    @IBAction func addSessionButtonPressed(_ sender: Any) {
        guard sender is UIButton,
            let addEditSessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddEditSessionViewController") as? AddEditSessionViewController else {
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
        cell.workoutsInfoTextView.text = dataModelManager.workoutsInfoText(forIndex: indexPath.row)
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
        guard !isEditingMode, indexPath.row < collectionView.numberOfItems(inSection: indexPath.section),
        let sessionCell = collectionView.cellForItem(at: indexPath) as? SessionsCollectionViewCell,
        let sessionPreviewViewController = storyboard?.instantiateViewController(withIdentifier: "SessionPreviewViewController") as? SessionPreviewViewController else {
            return
        }

        selectedIndex = indexPath.row
        if #available(iOS 13.0, *) {
            // No op
        } else {
            sessionPreviewViewController.modalPresentationStyle = .custom
            sessionPreviewViewController.transitioningDelegate = self
        }
        sessionPreviewViewController.title = sessionCell.sessionTitleLabel.text
        sessionPreviewViewController.sessionDataModelDelegate = self
        sessionPreviewViewController.sessionPreviewInfo = dataModelManager.getSessionPreviewInfo(forIndex: indexPath.row)
        present(sessionPreviewViewController, animated: true, completion: nil)
    }
}

// MARK: - Saving Session func

extension SessionsViewController: SessionDataModelDelegate {
    func addSessionData(name: String?, workouts: List<Workout>) {
        let session = Session(name: name, workouts: workouts)
        dataModelManager.addSession(session: session)

        refreshMainView()
    }

    func editSelectedSession() {
        guard let sessionIndex = selectedIndex,
            let selectedSession = dataModelManager.getSession(forIndex: sessionIndex),
            let addEditSessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddEditSessionViewController") as? AddEditSessionViewController else {
                NSLog("Could not instantiate AddEditSessionViewController.")
                return
        }
        addEditSessionViewController.sessionState = .edit
        addEditSessionViewController.sessionDataModelDelegate = self
        addEditSessionViewController.addEditSession = selectedSession
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }

    func saveSelectedSession(_ editedSession: Session) {
        refreshMainView()
    }

    func clearSelectedSessionIndex() {
        selectedIndex = nil
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
