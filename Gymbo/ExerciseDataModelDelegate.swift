//
//  ExerciseDataModelDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//
protocol ExerciseDataModelDelegate: AnyObject {
    func create(_ exercise: Exercise,
                completion: @escaping (Result<Any?, DataError>) -> Void)
    func update(_ currentName: String,
                exercise: Exercise,
                completion: @escaping(Result<Any?, DataError>) -> Void)
}

extension ExerciseDataModelDelegate {
    func create(_ exercise: Exercise,
                completion: @escaping (Result<Any?, DataError>) -> Void) {}
    func update(_ currentName: String,
                exercise: Exercise,
                completion: @escaping(Result<Any?, DataError>) -> Void) {}
}
