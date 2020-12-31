//
//  ExercisesTVC+ExerciseDataModelDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension ExercisesTVC: ExerciseDataModelDelegate {
    func create(_ exercise: Exercise, completion: @escaping (Result<Any?, DataError>) -> Void) {
        customDataSource?.create(exercise) { [weak self] result in
            switch result {
            case .success(let value):
                completion(.success(value))
                self?.tableView.reloadData()
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
