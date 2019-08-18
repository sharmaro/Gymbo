//
//  AddSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/6/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol DimmingViewDelegate: class {
    func animateDimmingView(type: AnimationType)
}

protocol WorkoutListDelegate: class {
    func updateWorkoutList(_ list: [String])
}

enum AnimationType {
    case darken
    case brighten
}

import UIKit

class AddSessionViewController: UIViewController {
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseButton: CustomButton!
    
    private lazy var saveButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 45, height: 20)))
        button.setTitle("Save", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.addTarget(self, action: #selector(saveButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private var sessionNameTextFieldOriginY: CGFloat!
    
    private var defaultSessionNameLabelText = "Session name"
    
    private var workoutList = [Workout]()
    
    private let textViewPlaceholderText = "Add optional additional info here"
    
    private struct Constants {
        static let headerViewHeight = CGFloat(36)
        static let footerViewHeight = CGFloat(36)
        
        static let exerciseTableViewCellHeight = CGFloat(120)
    }
    
    weak var sessionDataModelDelegate: SessionDataModelDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Session"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        sessionNameTextFieldOriginY = sessionNameTextField.frame.origin.y
        sessionNameTextField.borderStyle = .none
        sessionNameTextField.delegate = self
        sessionNameTextField.returnKeyType = .done
        sessionNameTextField.tag = -1
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.isHidden = workoutList.count == 0
        tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: ExerciseTableViewCell().reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
        
        addExerciseButton.setTitle("Add \nExercise", for: .normal)
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.addCornerRadius(addExerciseButton.bounds.width / 2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    private func animateDarkenView() {
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.view.alpha = 0.3
        }
    }
    
    private func animateBrightenView() {
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.view.alpha = 1.0
        }
    }
    
    @objc func saveButton(_ button: CustomButton) {
        let text = (sessionNameTextField.text?.count ?? 0) > 0 ? sessionNameTextField.text : nil
        sessionDataModelDelegate?.updateSessionDataModel(sessionName: text, workoutsList: workoutList)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addSetButtonTapped(_ button: UIButton) {
        guard var numberOfSets = workoutList[button.tag].sets else {
            return
        }
        numberOfSets += 1
        workoutList[button.tag].sets = numberOfSets
        let newWorkoutDetails = WorkoutDetails(reps: 0, weight: 0, time: 0, additionalInfo: "")
        workoutList[button.tag].workoutDetails?.append(newWorkoutDetails)
        tableView.reloadData()
    }
    
    @IBAction func addExerciseButtonTapped(_ sender: Any) {
        if sender is UIButton,
            let addExerciseViewController = storyboard?.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {
            
            animateDimmingView(type: .darken)
            addExerciseViewController.modalPresentationStyle = .custom
            addExerciseViewController.dimmingViewDelegate = self
            addExerciseViewController.workoutListDelegate = self
            present(addExerciseViewController, animated: true, completion: nil)
        } else {
            fatalError("Could not instantiate AddExerciseViewController.")
            
        }
    }
}

extension AddSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return workoutList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.bounds.width, height: Constants.headerViewHeight)))
        headerContainerView.backgroundColor = .white
        
        let exerciseLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: tableView.bounds.width - 40, height: Constants.headerViewHeight)))
        exerciseLabel.text = workoutList[section].name
        exerciseLabel.textColor = .blue
        
        headerContainerView.addSubview(exerciseLabel)
        return headerContainerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.exerciseTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutList[section].sets ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as? ExerciseTableViewCell else {
            fatalError("Could not dequeue cell with identifier `ExerciseTableViewCell`.")
        }
        cell.setsValueLabel.text = "\(indexPath.row + 1)"
        cell.exerciseCellDelegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.footerViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.bounds.width, height: Constants.footerViewHeight)))
        footerContainerView.backgroundColor = .white
        
        let addSetButton = CustomButton(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: tableView.bounds.width - 40, height: Constants.footerViewHeight)))
        addSetButton.setTitle("Add Set", for: .normal)
        addSetButton.addCornerRadius()
        addSetButton.tag = section
        addSetButton.addTarget(self, action: #selector(addSetButtonTapped(_ :)), for: .touchUpInside)
        
        footerContainerView.addSubview(addSetButton)
        return footerContainerView
    }
}

extension AddSessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell at index path: \(indexPath).")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        if yOffset > 0 {
            sessionNameTextField.frame.origin.y = yOffset + sessionNameTextFieldOriginY
        }
    }
}

extension AddSessionViewController: ExerciseTableViewCellDelegate {
    // UITextFieldDelegate funcs
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 6
    }
    
    func didEndEditingTextField(textField: UITextField, textFieldType: TextFieldType, atIndexPath indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            fatalError("Found nil index path for text field after it ended editing")
        }
        
        switch textFieldType {
        case .reps:
            workoutList[indexPath.section].workoutDetails?[indexPath.row].reps = Int(textField.text ?? "0")
        case .weight:
            workoutList[indexPath.section].workoutDetails?[indexPath.row].weight = Double(textField.text ?? "0")
        case .time:
            workoutList[indexPath.section].workoutDetails?[indexPath.row].time = Int(textField.text ?? "0")
        }
    }
    
    // UITextViewDelegate funcs
    func didBeginEditingTextView(textView: UITextView) {
        if textView.text == textViewPlaceholderText {
            textView.text.removeAll()
            textView.textColor = UIColor.black.withAlphaComponent(1)
        }
    }
    
    func shouldChangeCharactersInTextView(textView: UITextView, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func didEndEditingTextView(textView: UITextView, atIndexPath indexPath: IndexPath?) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceholderText
            textView.textColor = UIColor.black.withAlphaComponent(0.2)
        } else if let indexPath = indexPath {
            workoutList[indexPath.section].workoutDetails?[indexPath.row].additionalInfo = textView.text
        }
    }
}

extension AddSessionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension AddSessionViewController: DimmingViewDelegate {
    func animateDimmingView(type: AnimationType) {
        switch type {
        case .darken:
            animateDarkenView()
        case .brighten:
            animateBrightenView()
        }
    }
}

extension AddSessionViewController: WorkoutListDelegate {
    func updateWorkoutList(_ list: [String]) {
        for workoutName in list {
            var workoutDetails = [WorkoutDetails]()
            let workoutDetail = WorkoutDetails(reps: 0, weight: 0, time: 0, additionalInfo: "")
            workoutDetails.append(workoutDetail)
            let newWorkout = Workout(name: workoutName, sets: 1, workoutDetails: workoutDetails)
            workoutList.append(newWorkout)
        }
        
        tableView.isHidden = workoutList.count == 0
        tableView.reloadData()
    }
}
