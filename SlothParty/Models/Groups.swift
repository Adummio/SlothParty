//
//  Group.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 30/04/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation
import CloudKit

struct GroupData{
    var ID: CKRecord.ID
    var name: String
    var picID: Int
    var admins: [UserData]
    var members: [UserData]
    var events: [EventData]
}

class Group {
    var groupData: GroupData
    
    init(ID: CKRecord.ID = CKRecord.ID(), name: String = String(), picID: Int = Int(), admins: [UserData] = [], members: [UserData] = [], events: [EventData] = []) {
        
        groupData = GroupData(ID: ID, name: name, picID: picID, admins: admins, members: members, events: events)
    }
    
    func saveGroup(completionHandler: @escaping (Bool) -> Void) {
        if groupData.ID == CKRecord.ID() {
            groupData.admins.append(UserManager.shared.userInfo)
            CloudDBController.shared.createGroup(name: groupData.name, admins: groupData.admins, members: groupData.members, picID: groupData.picID, events: groupData.events) { (group) in
                print("group created successfully")
                completionHandler(true)
            }
        } else {
            CloudDBController.shared.updateGroup(name: groupData.name, picID: groupData.picID, group: groupData) { (success) in
                if success {
                    print("update successful")
                    completionHandler(true)
                } else {
                    print("update failed")
                    completionHandler(false)
                }
            }
        }
    }
    
    func loadGroup(group: CKRecord.Reference, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readGroup(group: group) { (group) in
            self.groupData = group
            completionHandler(true)
        }
    }
    
    func makeAdmin(member: UserData, completionHandler: @escaping (Bool) -> Void){
        for user in groupData.members {
            if user.username == member.username {
                CloudDBController.shared.promoteMemberToAdmin(user: member, group: self.groupData) { (success) in
                    if success {
                        print("member made admin")
                        completionHandler(true)
                    } else {
                        print("member not made admin, ERROR")
                        completionHandler(false)
                    }
                }
            } else {
                print("the user selected is not in the participants")
                completionHandler(false)
            }
        }
    }
    
    func makeParticipant(admin: UserData, completionHandler: @escaping (Bool) -> Void){
        for user in groupData.admins {
            if user.username == admin.username {
                CloudDBController.shared.degradeAdminToMember(user: admin, group: self.groupData) { (success) in
                    if success {
                        print("admin made member")
                        completionHandler(true)
                    } else {
                        print("admin not made member, ERROR")
                        completionHandler(false)
                    }
                }
            } else {
                print("the user selected is not in the admins")
                completionHandler(false)
            }
        }
    }
    
    func addMember(user: UserData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.addMemberToGroup(member: user, group: groupData) { (success) in
            if success {
                print("member added successfully")
                completionHandler(true)
            } else {
                print("adding member failed")
                completionHandler(false)
            }
        }
    }
    
    func removeMember(user: UserData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.removeMemberFromGroup(user: user, group: groupData) { (success) in
            if success {
                print("member removed successfully")
                completionHandler(true)
            } else {
                print("remmoving member failed")
                completionHandler(false)
            }
        }
    }
}
