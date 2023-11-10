//
//  CacheManager.swift
//  SlothParty
//
//  Created by Yuri Spaziani on 14/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation
import CoreLocation


struct CodableUserData : Codable{
    var ID: String
    var username: String
    var score: Int
    var avatarID: Int
    
    
    init(user: UserData){
        ID = user.ID.recordName
        username = user.username
        score = user.score
        avatarID = user.avatarID
    }
}

struct CodableGroupData : Codable{
    var ID: String
    var name: String
    var picID: Int
    var admins: [CodableUserData]
    var members: [CodableUserData]?
    var events: [CodableEventData]?
    
    init(group: GroupData){
        ID = group.ID.recordName
        name = group.name
        picID = group.picID
        admins = []
        for admin in group.admins{
            admins.append(CodableUserData(user: admin))
        }
        for member in group.members{
            members?.append(CodableUserData(user: member))
        }
        for event in group.events{
            events?.append(CodableEventData(event: event))
        }
    }
}

struct CodableEventData : Codable{
    var ID: String
    var name: String
    var penaltyID: Int
    var latitude: Double
    var longitude: Double
    var dateTime: Date
    var admins: [CodableUserData]
    var participants: [CodableUserData]?
    
    init(event: EventData){
        ID = event.ID.recordName
        name = event.name
        penaltyID = event.penaltyID
        latitude = event.place.coordinate.latitude
        longitude = event.place.coordinate.longitude
        dateTime = event.dateTime as Date
        admins = []
        for admin in event.admins!{
            admins.append(CodableUserData(user: admin))
        }
        for participant in event.participants ?? []{
            participants?.append(CodableUserData(user: participant))
        }
    }
}

struct CodableFriendsData : Codable{
    var ID: String
    var contacts: [CodableUserData]?
    
    init(friendList: Friends){
        ID = friendList.ID.recordName
        for contact in friendList.contacts{
            contacts?.append(CodableUserData(user: contact))
        }
    }
}

struct CodableParticipation : Codable{
    var ID: String
    var accepted: Int
    var delay: Int
    var event: CodableEventData
    
    init(participation: Participation){
        ID = participation.ID.recordName
        accepted = participation.accepted.rawValue
        delay = participation.delay
        event = CodableEventData(event: participation.event)
    }
}


class CacheManager{
    
    static let shared = CacheManager()
    
    let userCache: Cache<String, CodableUserData> = {
        let cache = Cache<String, CodableUserData>()
        return cache.loadCache(withName: "userCache")
    }()
    
    let groupCache: Cache<String, CodableGroupData> = {
        let cache = Cache<String, CodableGroupData>()
        return cache.loadCache(withName: "groupsCache")
    }()
    
    let friendsCache: Cache<String, CodableFriendsData> = {
        let cache = Cache<String, CodableFriendsData>()
        return cache.loadCache(withName: "friendsCache")
    }()
    
    let participationsCache: Cache<String, CodableParticipation> = {
        let cache = Cache<String, CodableParticipation>()
        return cache.loadCache(withName: "participationsCache")
    }()
    
    private init(){
        
    }
}
