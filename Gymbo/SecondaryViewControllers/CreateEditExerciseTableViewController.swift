//
//  CreateEditExerciseTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
class CreateEditExerciseTableViewController: UITableViewController {
    private let actionButton: CustomButton = {
        let button = CustomButton()
        button.add(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private var createEditExerciseDataModel = CreateEditExerciseDataModel()

    private var imagesTableViewCell: ImagesTableViewCell?
    private var imagesTableViewCellSelectedIndex: Int?

    var exercise = Exercise()
    var exerciseState = ExerciseState.create

    weak var exerciseDataModelDelegate: ExerciseDataModelDelegate?
    weak var setAlphaDelegate: SetAlphaDelegate?
}

// MARK: - Structs/Enums
private extension CreateEditExerciseTableViewController {
    struct Constants {
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let actionButtonHeight = CGFloat(45)
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditExerciseTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()

        if exerciseState == .edit {
            createEditExerciseDataModel.exercise = exercise
            createEditExerciseDataModel.setupFromExistingExercise()
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
extension CreateEditExerciseTableViewController: ViewAdding {
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
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.register(LabelTableViewCell.self,
                           forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)
        tableView.register(TextFieldTableViewCell.self,
                           forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(MultipleSelectionTableViewCell.self,
                           forCellReuseIdentifier: MultipleSelectionTableViewCell.reuseIdentifier)
        tableView.register(ImagesTableViewCell.self,
                           forCellReuseIdentifier: ImagesTableViewCell.reuseIdentifier)
        tableView.register(TextViewTableViewCell.self,
                           forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier)
        let verticalSpacing = CGFloat(15)
        tableView.contentInset.bottom = Constants.actionButtonHeight + verticalSpacing

        exerciseState == .create ?
            actionButton.makeUninteractable(animated: false) :
            actionButton.makeInteractable(animated: false)
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
extension CreateEditExerciseTableViewController {
    private func updateSaveButton() {
        guard let exerciseName = createEditExerciseDataModel.exerciseName,
              !exerciseName.isEmpty,
              let groups = createEditExerciseDataModel.groups,
              !groups.isEmpty else {
                actionButton.makeUninteractable(animated: true)
                return
        }
        actionButton.makeInteractable(animated: true)
    }

    private func getImageNamesAfterSave(from exerciseName: String,
                                        and images: [UIImage]) -> List<String> {
        let imageNames = Utility.saveImages(name: exerciseName,
                                                images: images,
                                                isUserMade: true,
                                                directory: .userImages) ?? [""]

        let thumbnails = images.map { $0.thumbnail ?? UIImage() }
        Utility.saveImages(name: exerciseName,
                           images: thumbnails,
                           isUserMade: true,
                           directory: .userThumbnails)

        let imageFilePathsList = List<String>()
        imageFilePathsList.append(objectsIn: imageNames)
        return imageFilePathsList
    }

    private func getInstructionsAndTipsFromCell() -> (instructions: String?, tips: String?) {
        var instructions: String?
        var tips: String?
        if let instructionsCellRow = createEditExerciseDataModel.indexOf(item: .instructions),
            let tipsCellRow = createEditExerciseDataModel.indexOf(item: .tips),
            let instructionsCell = tableView.cellForRow(at: IndexPath(row: instructionsCellRow, section: 0))
                as? TextViewTableViewCell,
            let tipsCell = tableView.cellForRow(at: IndexPath(row: tipsCellRow, section: 0))
                as? TextViewTableViewCell {
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

    private func getFormattedGroups() -> String? {
        guard var dataModelGroups = createEditExerciseDataModel.groups else {
            return nil
        }

        dataModelGroups.sort()

        var groups = ""
        for (index, name) in dataModelGroups.enumerated() {
            let groupName = name.lowercased()
            if index < dataModelGroups.count - 1 {
                groups += "\(groupName), "
            } else {
                groups += "\(groupName)"
            }
        }
        return groups
    }

    @objc private func cancelButtonTapped() {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
        setAlphaDelegate?.setAlpha(alpha: 1)
    }

    @objc private func actionButtonTapped(sender: Any) {
        Haptic.sendImpactFeedback(.medium)
        guard let groups = getFormattedGroups() else {
            return
        }

        let imageNames = getImageNamesAfterSave(from: createEditExerciseDataModel.exerciseName ?? "",
                                                and: createEditExerciseDataModel.images ?? [])
        let instructionsAndTips = getInstructionsAndTipsFromCell()
        let exercise = Exercise(name: createEditExerciseDataModel.exerciseName,
                                groups: groups,
                                instructions: instructionsAndTips.instructions,
                                tips: instructionsAndTips.tips,
                                imageNames: imageNames,
                                isUserMade: true)
        let exerciseName = createEditExerciseDataModel.exerciseName ?? ""
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
            let currentExerciseName = createEditExerciseDataModel.exercise.name ?? ""
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

// MARK: - UITableViewDataSource
extension CreateEditExerciseTableViewController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        createEditExerciseDataModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = createEditExerciseDataModel.cellForRow(in: tableView, at: indexPath)

        if let textFieldTableViewCell = cell as? TextFieldTableViewCell {
            textFieldTableViewCell.customTextFieldDelegate = self
        }

        if let multipleSelectionTableViewCell = cell as? MultipleSelectionTableViewCell {
            multipleSelectionTableViewCell.multipleSelectionTableViewCellDelegate = self
        }

        if let imagesTableViewCell = cell as? ImagesTableViewCell {
            imagesTableViewCell.imagesTableViewCellDelegate = self
        }

        if let textViewTableViewCell = cell as? TextViewTableViewCell {
            textViewTableViewCell.customTextViewDelegate = self
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateEditExerciseTableViewController {
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        createEditExerciseDataModel.heightForRow(at: indexPath)
    }

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        createEditExerciseDataModel.heightForRow(at: indexPath)
    }
}

// MARK: - CustomTextViewDelegate
extension CreateEditExerciseTableViewController: CustomTextViewDelegate {
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

        let tableRow = createEditExerciseDataModel.tableItem(at: indexPath)
        let text = textView.text ?? ""
        if tableRow == .instructions {
            createEditExerciseDataModel.instructions = text
        } else if tableRow == .tips {
            createEditExerciseDataModel.tips = text
        }

        textView.animateBorderColorAndWidth(fromColor: .defaultSelectedBorder,
                                            toColor: .defaultUnselectedBorder,
                                            fromWidth: .defaultSelectedBorder,
                                            toWidth: .defaultUnselectedBorder)
    }
}

// MARK: CustomTextFieldDelegate
extension CreateEditExerciseTableViewController: CustomTextFieldDelegate {
    func textFieldEditingChanged(textField: UITextField) {
        createEditExerciseDataModel.exerciseName = textField.text ?? ""
        updateSaveButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MultipleSelectionTableViewCellDelegate
extension CreateEditExerciseTableViewController: MultipleSelectionTableViewCellDelegate {
    func selected(items: [String]) {
        createEditExerciseDataModel.groups = items
        updateSaveButton()
    }
}

// MARK: - ImagesTableViewCellDelegate
extension CreateEditExerciseTableViewController: ImagesTableViewCellDelegate {
    func buttonTapped(cell: ImagesTableViewCell, index: Int, function: ButtonFunction) {
        view.endEditing(true)

        imagesTableViewCell = cell
        imagesTableViewCellSelectedIndex = index

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
                self?.imagesTableViewCell?.update(for: index)
                self?.imagesTableViewCell = nil
                self?.imagesTableViewCellSelectedIndex = nil
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .destructive,
                                                handler: { [weak self] _ in
            self?.imagesTableViewCell = nil
            self?.imagesTableViewCellSelectedIndex = nil
        }))
        navigationController?.present(alertController, animated: true)
    }

    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            navigationController?.present(imagePickerController, animated: true)
        } else {
            imagesTableViewCell = nil
            imagesTableViewCellSelectedIndex = nil
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CreateEditExerciseTableViewController: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let cell = self?.imagesTableViewCell,
                let selectedIndex = self?.imagesTableViewCellSelectedIndex,
                let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }

            cell.update(image: image, for: selectedIndex)
            self?.createEditExerciseDataModel.images = cell.images
            self?.imagesTableViewCell = nil
            self?.imagesTableViewCellSelectedIndex = nil
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagesTableViewCell = nil
        imagesTableViewCellSelectedIndex = nil
        picker.dismiss(animated: true)
    }
}
