//
//  CreateEditExerciseVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class CreateEditExerciseVC: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    private let actionButton: CustomButton = {
        let button = CustomButton()
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private var imagesTVCell: ImagesTVCell?
    private var imagesTVCellSelectedIndex: Int?

    var exercise = Exercise()
    var exerciseState = ExerciseState.create

    var customDataSource: CreateEditExerciseTVDS?
    var customDelegate: CreateEditExerciseTVD?

    weak var exerciseDataModelDelegate: ExerciseDataModelDelegate?
    weak var setAlphaDelegate: SetAlphaDelegate?
}

// MARK: - Structs/Enums
private extension CreateEditExerciseVC {
    struct Constants {
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let actionButtonHeight = CGFloat(45)
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditExerciseVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()

        if exerciseState == .edit {
            customDataSource?.exercise = exercise
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension CreateEditExerciseVC: ViewAdding {
    func setupNavigationBar() {
        title = exerciseState.rawValue
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }

    func addViews() {
        view.add(subviews: [tableView, actionButton])
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.register(ExercisesHFV.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHFV.reuseIdentifier)
        tableView.register(TextFieldTVCell.self,
                           forCellReuseIdentifier: TextFieldTVCell.reuseIdentifier)
        tableView.register(MultipleSelectionTVCell.self,
                           forCellReuseIdentifier: MultipleSelectionTVCell.reuseIdentifier)
        tableView.register(ImagesTVCell.self,
                           forCellReuseIdentifier: ImagesTVCell.reuseIdentifier)
        tableView.register(TextViewTVCell.self,
                           forCellReuseIdentifier: TextViewTVCell.reuseIdentifier)
        let verticalSpacing = CGFloat(15)
        tableView.contentInset.bottom = Constants.actionButtonHeight + verticalSpacing

        let state: InteractionState = exerciseState == .create ?
            .disabled : .enabled
        actionButton.set(state: state, animated: false)
        actionButton.title = exerciseState == .create ? "Create" : "Save"
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .primaryBackground }
    }

    func addConstraints() {
        tableView.autoPinSafeEdges(to: view)
        NSLayoutConstraint.activate([
            actionButton.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            actionButton.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            actionButton.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -15),
            actionButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonHeight)
        ])
    }
}

// MARK: - Funcs
extension CreateEditExerciseVC {
    private func updateSaveButton() {
        guard let exerciseName = customDataSource?.exerciseName,
              !exerciseName.isEmpty,
              let groups = customDataSource?.groups,
              !groups.isEmpty else {
                actionButton.set(state: .disabled)
                return
        }
        actionButton.set(state: .enabled)
    }

    private func getInstructionsAndTipsFromCell() -> (instructions: String?, tips: String?) {
        var instructions: String?
        var tips: String?
        if let instructionsCellIndexPath = customDataSource?.indexPathOf(item: .instructions),
            let tipsCellIndexPath = customDataSource?.indexPathOf(item: .tips),
            let instructionsCell = tableView.cellForRow(at: instructionsCellIndexPath)
                as? TextViewTVCell,
            let tipsCell = tableView.cellForRow(at: tipsCellIndexPath)
                as? TextViewTVCell {
            if !(instructionsCell.textViewText?.isEmpty ?? true) {
                instructions = instructionsCell.textViewText
            }

            if !(tipsCell.textViewText?.isEmpty ?? true) {
                tips = tipsCell.textViewText
            }
        }
        return (instructions, tips)
    }

    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            navigationController?.present(imagePickerController, animated: true)
        } else {
            imagesTVCell = nil
            imagesTVCellSelectedIndex = nil
        }
    }

    @objc private func closeButtonTapped() {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
        setAlphaDelegate?.setAlpha(alpha: 1)
    }

    @objc private func actionButtonTapped(sender: Any) {
        guard let groups = customDataSource?.getFormattedGroups(),
              let customDataSource = customDataSource else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        let imageNames = customDataSource.getImageNamesAfterSave()
        let instructionsAndTips = getInstructionsAndTipsFromCell()
        let exerciseName = customDataSource.exerciseName ?? ""
        let exercise = Exercise(name: exerciseName,
                                groups: groups,
                                instructions: instructionsAndTips.instructions,
                                tips: instructionsAndTips.tips,
                                imageNames: imageNames,
                                isUserMade: true)

        switch exerciseState {
        case .create:
            exerciseDataModelDelegate?.create(exercise, completion: { [weak self] result in
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                    self?.setAlphaDelegate?.setAlpha(alpha: 1)
                case .failure(let error):
                    guard let alertData = error.exerciseAlertData(exerciseName: exerciseName) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.presentCustomAlert(alertData: alertData)
                    }
                }
            })
        case .edit:
            let currentExerciseName = customDataSource.exercise.name ?? ""
            exerciseDataModelDelegate?.update(currentExerciseName,
                                              exercise: exercise,
                                              completion: { [weak self] result in
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure(let error):
                    guard let alertData = error.exerciseAlertData(exerciseName: exerciseName) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self?.presentCustomAlert(alertData: alertData)
                    }
                }
            })
        }
    }
}

// MARK: CustomTextFieldDelegate
extension CreateEditExerciseVC: CustomTextFieldDelegate {
    func textFieldEditingChanged(textField: UITextField) {
        customDataSource?.exerciseName = textField.text ?? ""
        updateSaveButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MultipleSelectionTVCellDelegate
extension CreateEditExerciseVC: MultipleSelectionTVCellDelegate {
    func selected(items: [String]) {
        customDataSource?.groups = items
        updateSaveButton()
    }
}

// MARK: - ImageButtonDelegate
extension CreateEditExerciseVC: ImageButtonDelegate {
    func buttonTapped(cell: UITableViewCell, index: Int, function: ButtonFunction) {
        guard let imagesTVCell = cell as? ImagesTVCell else {
            return
        }
        view.endEditing(true)

        self.imagesTVCell = imagesTVCell
        imagesTVCellSelectedIndex = index

        let alertController = UIAlertController()
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.getImage(fromSourceType: .camera)
        }))
        alertController.addAction(UIAlertAction(title: "Photo Library",
                                                style: .default,
                                                handler: { [weak self] _ in
            self?.getImage(fromSourceType: .photoLibrary)
        }))

        if function == .update {
            alertController.addAction(UIAlertAction(title: "Remove Photo",
                                                    style: .destructive,
                                                    handler: { [weak self] _ in
                self?.imagesTVCell?.update(for: index)
                self?.customDataSource?.images = self?.imagesTVCell?.images
                self?.imagesTVCell = nil
                self?.imagesTVCellSelectedIndex = nil
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .destructive,
                                                handler: { [weak self] _ in
            self?.imagesTVCell = nil
            self?.imagesTVCellSelectedIndex = nil
        }))
        navigationController?.present(alertController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CreateEditExerciseVC: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let cell = self?.imagesTVCell,
                let selectedIndex = self?.imagesTVCellSelectedIndex,
                let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }

            cell.update(image: image, for: selectedIndex)
            self?.customDataSource?.images = cell.images
            self?.imagesTVCell = nil
            self?.imagesTVCellSelectedIndex = nil
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagesTVCell = nil
        imagesTVCellSelectedIndex = nil
        picker.dismiss(animated: true)
    }
}
