//
//  CreateEditExerciseTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

protocol CreateEditExerciseDelegate: class {
    func createExerciseInfo(_ info: ExerciseInfo, success: @escaping(() -> Void), fail: @escaping(() -> Void))
    func updateExerciseInfo(_ currentName: String, info: ExerciseInfo, success: @escaping(() -> Void), fail: @escaping(() -> Void))
}

extension CreateEditExerciseDelegate {
    func createExerciseInfo(_ info: ExerciseInfo, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
    func updateExerciseInfo(_ currentName: String, info: ExerciseInfo, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
}

enum ExerciseState: String {
    case create = "Create Exercise"
    case edit = "Edit Exercise"
}

// MARK: - Properties
class CreateEditExerciseTableViewController: UITableViewController {
    private let saveButton: CustomButton = {
        let button = CustomButton()
        button.title = "Save"
        button.add(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private var tableData: [TableRow] = [.nameTitle, .name, .muscleGroupsTitle,
                                         .muscleGroups, .imagesTitle, .images,
                                         .instructionsTitle, .instructions, .tipsTitle, .tips]

    private var exerciseDataModel = ExerciseDataModel.shared

    // Data stored from cell inputs
    private var exerciseName = ""
    private var muscleGroups = [String]()
    private var imagesTableViewCell: ImagesTableViewCell?
    private var imagesTableViewCellSelectedIndex: Int?
    private var images = [UIImage]()
    private var instructions = ""
    private var tips = ""

    var exerciseInfo = ExerciseInfo()
    var exerciseState = ExerciseState.create

    weak var createEditExerciseDelegate: CreateEditExerciseDelegate?
    weak var setAlphaDelegate: SetAlphaDelegate?
}

// MARK: - Structs/Enums
private extension CreateEditExerciseTableViewController {
    struct Constants {
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
        static let muscleGroupsCellHeight = CGFloat(150)
        static let imagesCellHeight = CGFloat(100)
        static let tableViewFooterHeight = CGFloat(55)
    }

    enum TableRow: String {
        case nameTitle = "Exercise Name"
        case name
        case muscleGroupsTitle = "Muscle Groups"
        case muscleGroups
        case imagesTitle = "Images (Optional)"
        case images
        case instructionsTitle = "Instructions (Optional)"
        case instructions
        case tipsTitle = "Tips (Optional)"
        case tips

        var height: CGFloat {
            switch self {
            case .nameTitle, .name, .muscleGroupsTitle, .imagesTitle, .instructionsTitle, .instructions, .tipsTitle, .tips:
                return UITableView.automaticDimension
            case .muscleGroups:
                return Constants.muscleGroupsCellHeight
            case .images:
                return Constants.imagesCellHeight
            }
        }
    }
}

// MARK: - ViewAdding
extension CreateEditExerciseTableViewController: ViewAdding {
    func setupNavigationBar() {
        title = exerciseState.rawValue
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        view.backgroundColor = .white

        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.register(LargeTitleTableViewCell.self, forCellReuseIdentifier: LargeTitleTableViewCell.reuseIdentifier)
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(MultipleSelectionTableViewCell.self, forCellReuseIdentifier: MultipleSelectionTableViewCell.reuseIdentifier)
        tableView.register(ImagesTableViewCell.self, forCellReuseIdentifier: ImagesTableViewCell.reuseIdentifier)
        tableView.register(TextViewTableViewCell.self, forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier)

        exerciseState == .create ? saveButton.makeUninteractable(animated: false) : saveButton.makeInteractable(animated: false)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

        let tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: Constants.tableViewFooterHeight)))
        tableFooterView.add(subviews: [saveButton])
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: tableFooterView.topAnchor, constant: 5),
            saveButton.leadingAnchor.constraint(equalTo: tableFooterView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: tableFooterView.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: tableFooterView.bottomAnchor, constant: -10)
        ])
        tableView.tableFooterView = tableFooterView
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditExerciseTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        if exerciseState == .edit {
            setupFromExistingExerciseInfo()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }
}

// MARK: - Funcs
extension CreateEditExerciseTableViewController {
    private func updateSaveButton() {
        guard !exerciseName.isEmpty,
            muscleGroups.count > 0 else {
                saveButton.makeUninteractable(animated: true)
                return
        }
        saveButton.makeInteractable(animated: true)
    }

    private func setupFromExistingExerciseInfo() {
        exerciseName = exerciseInfo.name ?? ""
        muscleGroups = Util.getStringArraySeparated(by: ",", text: exerciseInfo.muscles)
        images = getUIImageFromData(list: exerciseInfo.imagesData)
        instructions = exerciseInfo.instructions ?? ""
        tips = exerciseInfo.tips ?? ""
    }

    private func getUIImageFromData(list: List<Data>) -> [UIImage] {
        var images = [UIImage]()
        for data in list {
            if let imageToAdd = UIImage(data: data) {
                images.append(imageToAdd)
            }
        }
        return images
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
        setAlphaDelegate?.setAlpha(alpha: 1)
    }

    @objc private func saveButtonTapped(sender: UIButton) {
        var groups = ""
        muscleGroups.sort()
        for (index, name) in muscleGroups.enumerated() {
            let groupName = name.lowercased()
            if index < muscleGroups.count - 1 {
                groups += "\(groupName), "
            } else {
                groups += "\(groupName)"
            }
        }

        let imagesData = List<Data>()
        for image in images {
            if let data = image.jpegData(compressionQuality: 0.5) {
                imagesData.append(data)
            }
        }

        var instructions: String? = nil
        var tips: String? = nil
        if let instructionsCellRow = tableData.firstIndex(of: .instructions),
            let tipsCellRow = tableData.firstIndex(of: .tips),
            let instructionsCell = tableView.cellForRow(at: IndexPath(row: instructionsCellRow, section: 0)) as? TextViewTableViewCell,
            let tipsCell = tableView.cellForRow(at: IndexPath(row: tipsCellRow, section: 0)) as? TextViewTableViewCell {
            if !(instructionsCell.textViewText?.isEmpty ?? true) {
                instructions = instructionsCell.textViewText
                instructions?.append("\n")
            }

            if !(tipsCell.textViewText?.isEmpty ?? true) {
                tips = tipsCell.textViewText
                tips?.append("\n")
            }
        }

        let exerciseInfo = ExerciseInfo(name: exerciseName, muscles: groups, groups: groups, instructions: instructions, tips: tips, imagesData: imagesData, isUserMade: true)
        switch exerciseState {
        case .create:
            createEditExerciseDelegate?.createExerciseInfo(exerciseInfo, success: { [weak self] in
                self?.dismiss(animated: true)
                }, fail: { [weak self] in
                    self?.presentCustomAlert(title: "Oops!", content: "Can't create exercise \(self?.exerciseName ?? "") because it already exists!", usesBothButtons: false, rightButtonTitle: "Sounds good.")
            })
        case .edit:
            createEditExerciseDelegate?.updateExerciseInfo(self.exerciseInfo.name ?? "", info: exerciseInfo, success: { [weak self] in
                self?.dismiss(animated: true)
            }, fail: { [weak self] in
                self?.presentCustomAlert(title: "Oops!", content: "Couldn't edit exercise \(self?.exerciseName ?? "")", usesBothButtons: false, rightButtonTitle: "Sounds good.")
            })
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateEditExerciseTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let tableItem = tableData[indexPath.row]

        switch tableItem {
        case .nameTitle, .muscleGroupsTitle, .imagesTitle, .instructionsTitle, .tipsTitle:
            guard let largeTitleTableViewCell = tableView.dequeueReusableCell(withIdentifier: LargeTitleTableViewCell.reuseIdentifier, for: indexPath) as? LargeTitleTableViewCell else {
                fatalError("Could not dequeue \(LargeTitleTableViewCell.reuseIdentifier)")
            }

            largeTitleTableViewCell.configure(title: tableItem.rawValue)
            cell = largeTitleTableViewCell
        case .name:
            guard let textFieldTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as? TextFieldTableViewCell else {
                fatalError("Could not dequeue \(TextFieldTableViewCell.reuseIdentifier)")
            }

            textFieldTableViewCell.configure(text: exerciseInfo.name ?? "", placeHolder: "Exercise name...")
            textFieldTableViewCell.textFieldTableViewCellDelegate = self
            cell = textFieldTableViewCell
        case .muscleGroups:
            guard let multipleSelectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: MultipleSelectionTableViewCell.reuseIdentifier, for: indexPath) as? MultipleSelectionTableViewCell else {
                fatalError("Could not dequeue \(MultipleSelectionTableViewCell.reuseIdentifier)")
            }

            let selectedTitlesArray = Util.getStringArraySeparated(by: ",", text: exerciseInfo.muscles).map {
                $0.capitalized
            }
            multipleSelectionTableViewCell.configure(titles: exerciseDataModel.defaultExerciseGroups(), selectedTitles: selectedTitlesArray)
            multipleSelectionTableViewCell.multipleSelectionTableViewCellDelegate = self
            cell = multipleSelectionTableViewCell
        case .images:
            guard let imagesTableViewCell = tableView.dequeueReusableCell(withIdentifier: ImagesTableViewCell.reuseIdentifier, for: indexPath) as? ImagesTableViewCell else {
                fatalError("Could not dequeue \(ImagesTableViewCell.reuseIdentifier)")
            }

            let existingImages = getUIImageFromData(list: exerciseInfo.imagesData)
            let defaultImage = UIImage(named: "add")
            imagesTableViewCell.configure(existingImages: existingImages, defaultImage: defaultImage, type: .button)
            imagesTableViewCell.imagesTableViewCellDelegate = self
            cell = imagesTableViewCell
        case .instructions, .tips:
            guard let textViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseIdentifier, for: indexPath) as? TextViewTableViewCell else {
                fatalError("Could not dequeue \(TextViewTableViewCell.reuseIdentifier)")
            }

            let text = tableItem == .instructions ? exerciseInfo.instructions : exerciseInfo.tips
            textViewTableViewCell.configure(text: text)
            textViewTableViewCell.textViewTableViewCellDelegate = self
            cell = textViewTableViewCell
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateEditExerciseTableViewController {
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableItem = tableData[indexPath.row]
        return tableItem.height
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableItem = tableData[indexPath.row]
        return tableItem.height
    }
}

// MARK: - UITextFieldDelegate
extension CreateEditExerciseTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - TextViewTableViewCellDelegate
extension CreateEditExerciseTableViewController: TextViewTableViewCellDelegate {
    func textViewDidChange(_ textView: UITextView, cell: TextViewTableViewCell) {
        tableView.performBatchUpdates({
            textView.sizeToFit()
        })

        if let indexPathOfCell = tableView.indexPath(for: cell) {
            tableView.scrollToRow(at: indexPathOfCell, at: .bottom, animated: true)
        }
    }
}

// MARK: TextFieldTableViewCellDelegate
extension CreateEditExerciseTableViewController: TextFieldTableViewCellDelegate {
    func textFieldEditingChanged(textField: UITextField) {
        exerciseName = textField.text ?? ""
        updateSaveButton()
    }
}

// MARK: - MultipleSelectionTableViewCellDelegate
extension CreateEditExerciseTableViewController: MultipleSelectionTableViewCellDelegate {
    func selected(items: [String]) {
        muscleGroups = items
        updateSaveButton()
    }
}

// MARK: - ImagesTableViewCellDelegate
extension CreateEditExerciseTableViewController: ImagesTableViewCellDelegate {
    func buttonTapped(cell: ImagesTableViewCell, index: Int, function: ButtonFunction) {
        imagesTableViewCell = cell
        imagesTableViewCellSelectedIndex = index

        let alertController = UIAlertController()
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.getImage(fromSourceType: .camera)
        }))
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            self?.getImage(fromSourceType: .photoLibrary)
        }))

        if function == .update {
            alertController.addAction(UIAlertAction(title: "Remove Photo", style: .destructive, handler: { [weak self] _ in
                self?.imagesTableViewCell?.update(for: index)
                self?.imagesTableViewCell = nil
                self?.imagesTableViewCellSelectedIndex = nil
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { [weak self] _ in
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
extension CreateEditExerciseTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let cell = self?.imagesTableViewCell,
                let selectedIndex = self?.imagesTableViewCellSelectedIndex,
                let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }

            cell.update(image: image, for: selectedIndex)
            self?.images = cell.images
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