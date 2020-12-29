//
//  CreateEditExerciseTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
class CreateEditExerciseTVC: UITableViewController {
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
private extension CreateEditExerciseTVC {
    struct Constants {
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let actionButtonHeight = CGFloat(45)
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditExerciseTVC {
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
extension CreateEditExerciseTVC: ViewAdding {
    func setupNavigationBar() {
        title = exerciseState.rawValue
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [actionButton])
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.register(LabelTVCell.self,
                           forCellReuseIdentifier: LabelTVCell.reuseIdentifier)
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
        [view, tableView].forEach { $0.backgroundColor = .dynamicWhite }
    }

    func addConstraints() {
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
extension CreateEditExerciseTVC {
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
        if let instructionsCellRow = customDataSource?.indexOf(item: .instructions),
            let tipsCellRow = customDataSource?.indexOf(item: .tips),
            let instructionsCell = tableView.cellForRow(at: IndexPath(row: instructionsCellRow, section: 0))
                as? TextViewTVCell,
            let tipsCell = tableView.cellForRow(at: IndexPath(row: tipsCellRow, section: 0))
                as? TextViewTVCell {
            if !(instructionsCell.textViewText?.isEmpty ?? true) {
                instructions = instructionsCell.textViewText
                instructions?.append("\n")
            }

            if !(tipsCell.textViewText?.isEmpty ?? true) {
                tips = tipsCell.textViewText
                tips?.append("\n")
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

    @objc private func cancelButtonTapped() {
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

// MARK: - ListDataSource
extension CreateEditExerciseTVC: ListDataSource {
    func cellForRowAt(tvCell: UITableViewCell) {
        if let textFieldTVCell = tvCell as? TextFieldTVCell {
            textFieldTVCell.customTextFieldDelegate = self
        } else if let multipleSelectionTVCell = tvCell as? MultipleSelectionTVCell {
            multipleSelectionTVCell.multipleSelectionTVCellDelegate = self
        } else if let imagesTVCell = tvCell as? ImagesTVCell {
            imagesTVCell.imagesTVCellDelegate = self
        } else if let textViewTVCell = tvCell as? TextViewTVCell {
            textViewTVCell.customTextViewDelegate = self
        }
    }
}

// MARK: - ListDelegate
extension CreateEditExerciseTVC: ListDelegate {
}

// MARK: - CustomTextViewDelegate
extension CreateEditExerciseTVC: CustomTextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView, cell: UITableViewCell?) {
        textView.animateBorderColorAndWidth(fromColor: .defaultUnselectedBorder,
                                            toColor: .defaultSelectedBorder,
                                            fromWidth: .defaultUnselectedBorder,
                                            toWidth: .defaultSelectedBorder)
    }

    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell?) {
        tableView.performBatchUpdates({
            textView.sizeToFit()
        })

        guard let cell = cell,
              let indexPath = tableView.indexPath(for: cell) else {
            fatalError("Couldn't get indexPath")
        }
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell?) {
        guard let cell = cell,
              let indexPath = tableView.indexPath(for: cell) else {
            fatalError("Couldn't get indexPath")
        }

        let tableRow = customDataSource?.item(at: indexPath)
        let text = textView.text ?? ""
        if tableRow == .instructions {
            customDataSource?.instructions = text
        } else if tableRow == .tips {
            customDataSource?.tips = text
        }

        textView.animateBorderColorAndWidth(fromColor: .defaultSelectedBorder,
                                            toColor: .defaultUnselectedBorder,
                                            fromWidth: .defaultSelectedBorder,
                                            toWidth: .defaultUnselectedBorder)
    }
}

// MARK: CustomTextFieldDelegate
extension CreateEditExerciseTVC: CustomTextFieldDelegate {
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
extension CreateEditExerciseTVC: MultipleSelectionTVCellDelegate {
    func selected(items: [String]) {
        customDataSource?.groups = items
        updateSaveButton()
    }
}

// MARK: - ImagesTVCellDelegate
extension CreateEditExerciseTVC: ImagesTVCellDelegate {
    func buttonTapped(cell: ImagesTVCell, index: Int, function: ButtonFunction) {
        view.endEditing(true)

        imagesTVCell = cell
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
extension CreateEditExerciseTVC: UIImagePickerControllerDelegate,
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
