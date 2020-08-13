//
//  ExerciseDataModelDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

protocol ExerciseDataModelDelegate: class {
    func create(_ exercise: Exercise, success: @escaping(() -> Void), fail: @escaping(() -> Void))
    func update(_ currentName: String,
                exercise: Exercise,
                success: @escaping(() -> Void),
                fail: @escaping(() -> Void))
}

extension ExerciseDataModelDelegate {
    func create(_ exercise: Exercise, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
    func update(_ currentName: String,
                exercise: Exercise,
                success: @escaping(() -> Void),
                fail: @escaping(() -> Void)) {}
}
