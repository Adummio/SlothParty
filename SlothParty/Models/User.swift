//
//  UserData.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 28/04/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation
import CloudKit

struct UserData{
    var ID: CKRecord.ID
    var name: String
    var surname: String
    var username: String
    var score: Int
    var avatarID: Int
    var groupList: [CKRecord.Reference]?
}

class User {
    var userData: UserData
    
    init(ID: CKRecord.ID = CKRecord.ID(), name: String = String(), surname: String = String(), username: String = String(), score: Int = Int(), avatarID: Int = Int())  {
        
        userData = UserData(ID: ID, name: name, surname: surname, username: username, score: score, avatarID: avatarID, groupList: [])
    }
    
    func loadUser(user: CKRecord.ID, completionHandler: @escaping (Bool) -> Void){
        let reference = CKRecord.Reference(recordID: user, action: .deleteSelf)
        
        CloudDBController.shared.readUserData(userReference: reference) { (userData) in
            self.userData = userData
            completionHandler(true)
        }
    }
}
