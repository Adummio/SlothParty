//
//  JsonManager.swift
//  SlothParty
//
//  Created by Massimo Maddaluno on 20/02/2020.
//  Copyright © 2020 McDoNot. All rights reserved.
//

import CloudKit
import Foundation
import SwiftKeychainWrapper

/// The class which handles the json file.
class JsonManager {
    static let shared = JsonManager()

    private init() {
    }

    /// Call this function in order to load the bool value related to firstLogin field in firstLogin.json
    func loadJson() -> Bool {
        var temp = userLogin()
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("firstLogin.json")

            let data = try Data(contentsOf: fileURL)
            temp = try JSONDecoder().decode(userLogin.self, from: data)
        } catch {
            print(error)
        }

        return temp.firstLogin
    }

    /// Call this function in order to update the value  related to firstLogin field in firstLogin.json
    func saveJson(value: Bool) {
        let t = userLogin(firstLogin: value)
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("firstLogin.json")

            try JSONEncoder().encode(t)
                .write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    func loadUser(completionHandler: @escaping () -> Void) {
        let keyWrapper = KeychainWrapper(serviceName: "AccountSloth")
        
        let recordID = CKRecord.ID(recordName: keyWrapper.string(forKey: "recordID")!)
        
        CloudDBController.shared.readUserData(userReference: CKRecord.Reference(recordID: recordID, action: .deleteSelf)) { user in
            UserManager.shared.userInfo = user
            
            let concurrentQueue = DispatchQueue(label: "com.some.concurrentQueue", attributes: .concurrent)


            concurrentQueue.async {
                UserManager.shared.loadFriendsList { (success) in
                    NSLog("Friendlist download complete")
                }

                UserManager.shared.loadGroupsAndEvents { (success) in
                    NSLog("Grouplist and events downloads complete")
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                }
            }
        }
    }

    func saveUser(user: CKRecord.ID) {
        let keyWrapper = KeychainWrapper(serviceName: "AccountSloth")

        keyWrapper.set(user.recordName, forKey: "recordID")
        
    }
}

struct userLogin: Codable {
    var firstLogin = Bool()
}
