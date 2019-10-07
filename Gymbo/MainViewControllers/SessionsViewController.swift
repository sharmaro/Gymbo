//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol SessionDataModelDelegate: class {
    func saveSessionData(name: String?, workouts: List<Workout>)
}

import UIKit
import RealmSwift

class SessionsViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addSessionButton: CustomButton!
    @IBOutlet weak var emptyExerciseLabel: UILabel!

    private let dataModelManager = SessionDataModelManager.shared

    private struct Constants {
        static let sessionTitleHeight = CGFloat(22)
        static let sessionCellLineHeight = CGFloat(20)
        static let sessionCellHeight = CGFloat(40)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
//        refreshMainView()
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
        collectionView.register(SessionsCollectionViewCell.nib, forCellWithReuseIdentifier: SessionsCollectionViewCell.reuseIdentifier)
    }

    private func refreshMainView() {
        collectionView.isHidden = dataModelManager.sessionsCount == 0
        emptyExerciseLabel.isHidden = !collectionView.isHidden
        if collectionView.isHidden {
            // No op
        } else {
            collectionView.reloadData()
        }
    }

    private func setupAddSessionButton() {
        addSessionButton.setTitle("Add \nSession", for: .normal)
        addSessionButton.titleLabel?.textAlignment = .center
        addSessionButton.addCornerRadius(addSessionButton.bounds.width / 2)
    }

    // MARK: - IBAction funcs

    @IBAction func addSessionButtonPressed(_ sender: Any) {
        if sender is UIButton,
            let sessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddSessionViewController") as? AddSessionViewController {
            sessionViewController.sessionDataModelDelegate = self
            navigationController?.pushViewController(sessionViewController, animated: true)
        } else {
            fatalError("Could not instantiate AddSessionViewController.")

        }
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
        cell.sessionTitleLabel.text = dataModelManager.getSessionNameForIndex(index: indexPath.row)
        cell.workoutsInfoLabel.text = dataModelManager.workoutsInfoTextForSession(index: indexPath.row)

        return cell
    }
}

extension SessionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width - 40
        var height = Constants.sessionCellHeight

        let workoutsCount = CGFloat(dataModelManager.workoutsCountForSession(index: indexPath.row))

        if workoutsCount > 0 {
            height = (Constants.sessionCellLineHeight * workoutsCount) + Constants.sessionTitleHeight
        }

        return CGSize(width: width, height: height)
    }
}

extension SessionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected item at index path: \(indexPath)")
    }
}

// MARK: - Saving Session func

extension SessionsViewController: SessionDataModelDelegate {
    func saveSessionData(name: String?, workouts: List<Workout>) {
        let session = Session(name: name, workouts: workouts)
        dataModelManager.saveSession(session: session)

        refreshMainView()
    }
}

// DELETE THIS
extension SessionsViewController {
    @IBAction func deleteData(_ sender: Any) {
        SessionDataModelManager.shared.removeAllRealmData()
        refreshMainView()
    }
}
