//
//  CreateEditSessionTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/3/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class CreateEditSessionTVC: UITableViewController {
    private let tableHeaderView = SessionHV()

    private lazy var saveButton: CustomButton = {
        let button = CustomButton()
        button.title = "Save"
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableFooterView: UIView = {
        let view = UIView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(
                    width: self.view.frame.width,
                    height: 75
                )
            )
        )
        return view
    }()

    private var didLayoutTableHeaderView = false

    private var realm: Realm? {
        try? Realm()
    }

    var customDataSource: CreateEditSessionTVDS?
    var customDelegate: CreateEditSessionTVD?
    var exercisesTVDS: ExercisesTVDS?

    weak var sessionDataModelDelegate: SessionDataModelDelegate?
}

// MARK: - Structs/Enums
private extension CreateEditSessionTVC {
    struct Constants {
        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "Info"
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditSessionTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
        registerForKeyboardNotifications()
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
extension CreateEditSessionTVC: ViewAdding {
    func setupNavigationBar() {
        title = customDataSource?.sessionState.rawValue ?? ""

        if isOnlyChildVC {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                               target: self,
                                                               action: #selector(closeButtonTapped))
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addExerciseButtonTapped))
    }

    func addViews() {
        tableFooterView.add(subviews: [saveButton])
        tableView.tableFooterView = tableFooterView
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ExercisesHFV.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHFV.reuseIdentifier)
        tableView.register(ExerciseHeaderTVCell.self,
                           forCellReuseIdentifier: ExerciseHeaderTVCell.reuseIdentifier)
        tableView.register(ExerciseDetailTVCell.self,
                           forCellReuseIdentifier: ExerciseDetailTVCell.reuseIdentifier)
        tableView.register(ButtonTVCell.self,
                           forCellReuseIdentifier: ButtonTVCell.reuseIdentifier)

        if mainTBC?.isSessionInProgress ?? false {
            tableView.contentInset.bottom = minimizedHeight
        }

        let session = customDataSource?.session
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = customDataSource?.sessionState == .create ?
                             .secondaryText : .primaryText

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.customTextViewDelegate = self

        var buttonState = InteractionState.disabled
        if let sessionState = customDataSource?.sessionState {
            buttonState = sessionState == .create ? .disabled : .enabled
        }
        saveButton.set(state: buttonState, animated: false)
    }

    func setupColors() {
        view.backgroundColor = .primaryBackground
    }

    func addConstraints() {
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = tableHeaderView
        NSLayoutConstraint.activate([
            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor),

            saveButton.topAnchor.constraint(equalTo: tableFooterView.topAnchor, constant: 15),
            saveButton.leadingAnchor.constraint(equalTo: tableFooterView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: tableFooterView.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - Funcs
extension CreateEditSessionTVC {
    private func saveSession(name: String?, info: String?) {
        guard let session = customDataSource?.session,
              let sessionState = customDataSource?.sessionState else {
            return
        }

        let sessionToInteractWith = session.safeCopy
        sessionToInteractWith.name = name
        sessionToInteractWith.info = info
        if sessionState == .create {
            createSession(newSession: sessionToInteractWith)
        } else {
            updateSession(newSession: sessionToInteractWith,
                          currentSession: session)
        }
    }

    private func createSession(newSession: Session) {
        sessionDataModelDelegate?.create(newSession,
                                         completion: { [weak self] (result) in
            switch result {
            case .success:
                self?.dismissAppropriately()
            case .failure(let error):
                guard let alertData = error
                        .exerciseAlertData(
                            exerciseName: newSession.name ?? ""
                        ) else {
                    return
                }
                self?.presentCustomAlert(alertData: alertData)
            }
        })
    }

    private func updateSession(newSession: Session, currentSession: Session) {
        sessionDataModelDelegate?.update(currentSession.name ?? "",
                                         session: newSession,
                                         completion: { [weak self] (result) in
            switch result {
            case .success:
                self?.dismissAppropriately()
            case .failure(let error):
                guard let alertData = error
                        .exerciseAlertData(
                            exerciseName: currentSession.name ?? ""
                        ) else {
                    return
                }
                self?.presentCustomAlert(alertData: alertData)
            }
        })
    }

    @objc private func closeButtonTapped(_ sender: Any) {
        dismissAppropriately()
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        view.endEditing(true)

        let exercisesVC = VCFactory.makeExercisesVC(presentationStyle: .modal,
                                                     exerciseUpdatingDelegate: self,
                                                     exercisesTVDS: exercisesTVDS)

        let modalNC = VCFactory.makeMainNC(rootVC: exercisesVC,
                                           transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)
    }

    @objc private func saveButtonTapped(_ sender: Any) {
        guard sender is CustomButton else {
            return
        }

        // Calls text field and text view didEndEditing() to save data
        view.endEditing(true)
        guard tableHeaderView.isFirstTextValid,
            let sessionName = tableHeaderView.firstText else {
            return
        }
        saveSession(name: sessionName, info: tableHeaderView.secondText)
    }
}

// MARK: - CustomTextViewDelegate
extension CreateEditSessionTVC: CustomTextViewDelegate {
    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell?) {
        tableView.performBatchUpdates({
            textView.sizeToFit()
        })

        guard textView.tag == 0 else {
            return
        }

        let saveButtonState: InteractionState = textView
            .text.isEmpty ? .disabled : .enabled
        saveButton.set(state: saveButtonState)
    }

    func textViewDidBeginEditing(_ textView: UITextView, cell: UITableViewCell?) {
        if textView.textColor == .secondaryText {
            textView.text.removeAll()
            textView.textColor = .primaryText
        }
    }

    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell?) {
        if textView.text.isEmpty {
            let name = customDataSource?.session.name
            let info = customDataSource?.session.info
            let textInfo = [name, info]

            if let text = textInfo[textView.tag] {
                textView.text = text
                textView.textColor = .primaryText
            } else {
                textView.text = textView.tag == 0 ?
                    Constants.namePlaceholderText : Constants.infoPlaceholderText
                textView.textColor = .secondaryText
            }
            return
        }
    }
}
