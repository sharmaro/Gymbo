//
//  SessionsPreviewViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct ExerciseInfo {
    var exerciseName: String?
    var exerciseMuscles: String?
}

class SessionPreviewViewController: UIViewController {
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startSessionButton: CustomButton!

    private lazy var closeButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Close", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var editButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Edit", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 1
        button.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
        return button
    }()

    var selectedSession: Session?
    var exerciseInfoList: [ExerciseInfo]?

    private var infoTextViewOriginY: CGFloat = 0

    private let dataModelManager = SessionDataModelManager.shared

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    private struct Constants {
        static let navBarButtonSize: CGSize = CGSize(width: 80, height: 30)

        static let textViewPlaceholderText = "Info"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard isViewLoaded,
            let session = selectedSession else {
                return
        }

        title = session.name
        exerciseInfoList = dataModelManager.getExerciseInfoList(forSession: session)

        updateInfoTextView(infoText: session.info)
        updateTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        setupInfoTextView()
        setupTableView()
        setupStartSessionButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sessionDataModelDelegate?.updateSessionCells()
    }

     private func setupNavigationItem() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
    }

    private func setupInfoTextView() {
        infoTextView.textContainerInset = .zero
        infoTextView.textContainer.lineFragmentPadding = 0
        infoTextView.textContainer.lineBreakMode = .byTruncatingTail
        infoTextView.isUserInteractionEnabled = false
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SessionPreviewTableViewCell.nib,
                           forCellReuseIdentifier: SessionPreviewTableViewCell.reuseIdentifier)
    }

    private func setupStartSessionButton() {
        startSessionButton.setTitle("Start Session", for: .normal)
        startSessionButton.titleLabel?.textAlignment = .center
        startSessionButton.addCornerRadius()
    }

    private func updateInfoTextView(infoText: String? = Constants.textViewPlaceholderText) {
        infoTextView.text = infoText
        if infoTextView.text == Constants.textViewPlaceholderText {
            infoTextView.textColor = UIColor.black.withAlphaComponent(0.2)
        }
    }

    private func updateTableView() {
        tableView.isHidden = exerciseInfoList == nil
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }

    @objc private func leftBarButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func rightBarButtonTapped() {
        guard let session = selectedSession,
            let addEditSessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddEditSessionViewController") as? AddEditSessionViewController else {
                NSLog("Could not instantiate AddEditSessionViewController.")
                return
        }
        addEditSessionViewController.sessionState = .edit
        addEditSessionViewController.addEditSession = session
        navigationController?.pushViewController(addEditSessionViewController, animated: true)
    }

    @IBAction func startSessionButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        // Call some delegate function that presents a new screen where the session has started
    }
}

extension SessionPreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseInfoList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sessionPreviewCell = tableView.dequeueReusableCell(withIdentifier: SessionPreviewTableViewCell.reuseIdentifier, for: indexPath) as? SessionPreviewTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(ExerciseDetailTableViewCell.reuseIdentifier)`.")
        }

        sessionPreviewCell.clearLabels()
        sessionPreviewCell.exerciseNameLabel.text = exerciseInfoList?[indexPath.row].exerciseName
        sessionPreviewCell.exerciseMusclesLabel.text = exerciseInfoList?[indexPath.row].exerciseMuscles

        return sessionPreviewCell
    }
}

// MARK: - UITableViewDelegate Funcs

extension SessionPreviewViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        if yOffset > 0 {
            infoTextView.frame.origin.y = yOffset + infoTextViewOriginY
        }
    }
}
