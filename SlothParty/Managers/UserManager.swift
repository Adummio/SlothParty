//
//  UserManager.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 02/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import CloudKit
import Foundation

class UserManager {
    static let shared = UserManager()

    var userInfo = UserData(ID: CKRecord.ID(recordName: "temp"), name: "", surname: "", username: "", score: 0, avatarID: 0)
    var friendship = Friends(ID: CKRecord.ID(recordName: "temp"), contacts: [])
    var events: [EventData]?
    var groups: [GroupData]?

    private init() {
    }
    
    func saveUser(completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.updateUser(user: UserManager.shared.userInfo) { (success) in
            if success {
                print("user data updated successfully")
                completionHandler(true)
            } else {
                print("user data updating failed")
                completionHandler(false)
            }
        }
    }
    
    func loadFriendsList(completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readFriendsList(user: userInfo) { (friends) in
            self.friendship = friends!
            completionHandler(true)
        }
    }
    
    func addFriend(user: UserData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.addFriend(friend: user) { (success) in
            if success {
                print("friend added successfully")
                completionHandler(true)
            } else {
                print("adding friend failed")
                completionHandler(false)
            }
        }
    }
    
    func removeFriend(user: UserData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.removeFriend(friend: user) { (success) in
            if success {
                print("friend removed successfully")
                completionHandler(true)
            } else {
                print("removing friend failed")
                completionHandler(false)
            }
        }
    }
    
    func replyInvitation(event: EventData, type: ParticipationType, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readParticipation(event: event) { (participation) in
            CloudDBController.shared.replyEventInvitation(participation: participation, value: type) { (success) in
                if success {
                    print("invitation replied successfully")
                    completionHandler(true)
                } else {
                    print("invitation replying failed")
                    completionHandler(false)
                }
            }
        }
    }
    
    func loadGroups(completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readAllGroups { (groups) in
            self.groups = groups
            completionHandler(true)
        }
    }
    
    func loadEvents(completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readEventsFromAllGroups(userID: UserManager.shared.userInfo.ID) { (events) in
            self.events = events
            completionHandler(true)
        }
    }
    
    func loadEventsFromGroups(){
        if self.groups?.count == 0{
            self.events = []
        }
        else{
            var eventsList : [EventData] = []
            
            for group in self.groups!{
                eventsList.append(contentsOf: group.events)
            }
            
            self.events = eventsList
        }
        
    }
    
    func loadGroupsAndEvents(completionHandler: @escaping (Bool) -> Void){
        self.loadGroups { (success) in
            self.loadEventsFromGroups()
            completionHandler(true)
        }
    }
    
    func checkIn(event: EventData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.updateParticipation(event: event) { (success) in
            if success {
                print("checked in!")
                completionHandler(true)
            } else {
                print("could not check in")
                completionHandler(false)
            }
        }
    }
}
