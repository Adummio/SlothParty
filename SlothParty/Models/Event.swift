//
//  Event.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 29/04/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

struct EventData{
    var ID: CKRecord.ID
    var name: String
    var penaltyID: Int
    var place: CLLocation
    var dateTime: NSDate
    var admins: [UserData]?
    var participants: [UserData]?
}

class Event {
    var eventData: EventData
    
    var joining: [UserData]? = []
    var refused: [UserData]? = []
    var pending: [UserData]? = []
    
    init(ID: CKRecord.ID = CKRecord.ID(), name: String = String(), penaltyID: Int = Int(), place: CLLocation = CLLocation(), dateTime: NSDate = NSDate(), admins: [UserData] = [], participants: [UserData] = []) {
        
        eventData = EventData(ID: ID, name: name, penaltyID: penaltyID, place: place, dateTime: dateTime, admins: admins, participants: participants)
    }
    
    func saveEvent(group: GroupData, completionHandler: @escaping (Bool) -> Void){
        if eventData.ID == CKRecord.ID() {
            eventData.admins!.append(UserManager.shared.userInfo)
            CloudDBController.shared.createEvent(name: eventData.name, place: eventData.place, dateTime: eventData.dateTime, admins: eventData.admins!, penaltyID: eventData.penaltyID, group: group) { (event) in
                print("event created successfully")
                completionHandler(true)
            }
        } else {
            CloudDBController.shared.editEvent(event: eventData, newPlace: eventData.place, newDate: eventData.dateTime, newName: eventData.name) { (success) in
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
    
    func loadEvent(eventID: CKRecord.ID, group: GroupData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readEvent(eventID: eventID) { (event) in
            self.eventData = event
            completionHandler(true)
        }
    }
    
    func loadParticipations(completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readParticipations(event: eventData) { (participations) in
            for participation in participations {
                if participation.accepted == .confirmed {
                    self.joining?.append(participation.user!)
                } else if participation.accepted == .denied {
                    self.refused?.append(participation.user!)
                } else {
                    self.pending?.append(participation.user!)
                }
                let count = self.joining!.count + self.pending!.count + self.refused!.count
                if count == participations.count {
                    completionHandler(true)
                }
            }
            
            completionHandler(false)
        }
    }
    
    func makeAdmin(member: UserData, completionHandler: @escaping (Bool) -> Void){
        for participant in eventData.participants! {
            if participant.username == member.username {
                CloudDBController.shared.promoteMemberToAdmin(user: member, event: self.eventData) { (success) in
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
        for user in eventData.admins! {
            if user.username == admin.username {
                CloudDBController.shared.degradeAdminToMember(user: admin, event: self.eventData) { (success) in
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
    
    func getDelayforMember(member: UserData, completionHandler: @escaping (Int) -> Void){
        CloudDBController.shared.readParticipation(event: eventData, user: member) { (participation) in
            completionHandler(participation.delay)
        }
    }
}
