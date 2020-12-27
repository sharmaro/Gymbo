//
//  UserDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class UserDataModel: NSObject {
    static var shared = UserDataModel()

    private var realm: Realm? {
        try? Realm()
    }

    var user: User?

    var isFirstTimeLoad: Bool {
        get {
            (realm?.objects(User.self).first?.isFirstTimeLoad) ?? true
        }
        set {
            try? realm?.write {
                realm?.objects(User.self).first?.isFirstTimeLoad = newValue
            }
        }
    }
}

// MARK: - Structs/Enums
private extension UserDataModel {
}

// MARK: - Funcs
extension UserDataModel {
    func loadUser() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            if self?.realm?.objects(User.self).first == nil {
                try? self?.realm?.write {
                    self?.realm?.add(User())
                }
            }

            let backgroundUser = self?.realm?.objects(User.self).first ?? User()
            let threadSafeUser = ThreadSafeReference(to: backgroundUser)

            DispatchQueue.main.async {
                guard let mainThreadUser = self?.realm?.resolve(threadSafeUser) else {
                    return
                }
                self?.user = mainThreadUser
            }
        }
    }
}
