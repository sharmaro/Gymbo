//
//  SessionDataModelDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

protocol SessionDataModelDelegate: class {
    func create(_ session: Session, success: @escaping(() -> Void), fail: @escaping(() -> Void))
    func update(_ currentName: String, session: Session,
                success: @escaping(() -> Void), fail: @escaping(() -> Void))
}

extension SessionDataModelDelegate {
    func create(_ session: Session, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
    func update(_ currentName: String, session: Session,
                success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
}
