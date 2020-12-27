//
//  SessionProgressDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

protocol SessionProgressDelegate: class {
    func sessionDidStart(_ session: Session?)
    func sessionDidEnd(_ session: Session?, endType: EndType)
}
