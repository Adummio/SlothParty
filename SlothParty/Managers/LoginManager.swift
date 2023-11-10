//
//  LoginManager.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 01/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import CloudKit
import Foundation

class LoginManager {
    static let shared = LoginManager()
    
    private init() {
    }
    
    func firstLoginProcedure(ID: String, name: String, surname: String, username: String, score: Int, groups: [GroupData], avatarID: Int, friendList: [UserData], completionHandler: @escaping (Bool) -> Void) {
        CloudDBController.shared.readPrivateUserData(ID: ID) { userReference, found in
            
            if found == true {
                CloudDBController.shared.readUserData(userReference: userReference!) { userData in
                    UserManager.shared.userInfo = userData
                    JsonManager.shared.saveUser(user: UserManager.shared.userInfo.ID)
                    
                    let concurrentQueue = DispatchQueue(label: "com.some.concurrentQueue", attributes: .concurrent)


                    concurrentQueue.async {
                        UserManager.shared.loadFriendsList { (success) in
                            NSLog("Friendlist download complete")
                        }

                        UserManager.shared.loadGroupsAndEvents{ (success) in
                            NSLog("Grouplist and events downloads complete")
                            
                            DispatchQueue.main.async {
                                completionHandler(true)
                            }
                        }
                    }
                }
                
            } else {
                CloudDBController.shared.createUser(name: name, surname: surname, username: username, score: score, groups: groups, avatarID: avatarID, friendList: friendList) { userData, friend in
                    
                    CloudDBController.shared.createPrivateUserData(appleID: ID, userID: userData.ID) { isCreated in
                        
                        UserManager.shared.userInfo = userData
                        UserManager.shared.friendship = friend!
                        
                        JsonManager.shared.saveUser(user: UserManager.shared.userInfo.ID)
                        
                        completionHandler(isCreated)
                        
                        
                    }
                }
            }
        }
    }
    
    func loginProcedure(ID: String, completionHandler: @escaping (Bool) -> Void) {
        
        
        CloudDBController.shared.readPrivateUserData(ID: ID) { userReference, _ in
            
            CloudDBController.shared.readUserData(userReference: userReference!) { userData in
                UserManager.shared.userInfo = userData
                JsonManager.shared.saveUser(user: UserManager.shared.userInfo.ID)
                
                let concurrentQueue = DispatchQueue(label: "com.some.concurrentQueue", attributes: .concurrent)


                concurrentQueue.async {
                    UserManager.shared.loadFriendsList { (success) in
                        NSLog("Friendlist download complete")
                    }

                    UserManager.shared.loadGroupsAndEvents { (success) in
                        NSLog("Grouplist and events downloads complete")
                        
                        DispatchQueue.main.async {
                            completionHandler(true)
                        }
                    }
                }
            }
            
            
            
        }
    }
}
