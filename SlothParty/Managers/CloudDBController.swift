// MARK: - DOCUMENTATION

// createUser(name:surname:username:score:groups:avatarID:friendsList:completionHandler:)  Inserted in class  Works
///call this functions to insert a new user in the DB

// createPrivateUsarData(appleID:userID:completionHandler:)                           Works
///call this function to link a user's appleID ot its reference in User table, inserting a new row in the UserIdentifier table in the DB

// createGroup(name:admins:members:picID:events:completionHandler:)  Inserted in class      Works
///call this function to insert a new group in the DB

// createEvent(name:place:dateTime:admins:penaltyID:group:completionHandler:)  Works
///call this function to insert a new event in the DB



// readPrivateUserData(appleID:completionHandler:)                     Works
///call this function to get the row of a user in the User table using its appleID

// readUserData(userReference:completionHandler:)  Inserted in class   Works
///call this function to get a user's info using its reference in the User table in the DB

// readUserFromUsername(username:completionHandler:)                    Works
///call this function to get a user's info using its username (it will return a list of users having the username containing the input username)

// readMembersAdimnsInGroup(groupID:completionHandler:)  Make private?  Works
///call this function to get the lists of members and admins of a group

// readMembersAdminsInEvent(eventID:completionHandler:)  Make private?   Works
///call this function to get the lists of members and admins of an event

// readEventsFromGroup(groupID:completionHandler:)  Make private?        Works
///call this function to get the list of event for a group

// readEventsFromAllGroups(userID:completionHandler:)   Inserted in class Works
///call this function to get the list of the events from all groups for a user

// readFriendsList(user:completionHandler:)  Inserted in class             Works
///call this function to get the friends list of a user

// readParticipations(event:completionHandler:)                           Works
///call this function to get the list of the participations for an event from Participation table in the DB

// readParticipation(event:completionHandler:)  Inserted in class          Works
///call this function to get the participation linked to the event and the current user

// readEvent(eventID:completionHandler:)  Inserted in class                Works
///call this function to read an event from Event table

// readGroup(group:completionHandler:)  Inserted in class                  Works
///call this function to read a group from Group table

// readAllGroups(completionHandler:)  Inserted in class                    Works
///call this function to read all the groups for the current user



// addMemberToGroup(member:group:completionHandler:)  Inserted in class    Works
///call this function to add a new member to a group

// replyEventInvitation(participation:value:completionHandler:)  Inserted in class  Works
///call this function to reply to an invitation

// removeMemberFromGroup(user:group:completionHandler:)  Inserted in class  Works
///call this function to remove a user from a group

// editEvent(event:newPlace:newDate:newName:completionHandler:)  Inserted in class  Works
///call this function to modify some parameter of the event (some of them have a default value)

// promoteMemberToAdmin(user:group:completionHandler:)  Inserted in class   Works
///call this function to make a normal member an admin in a group

// promoteMemberToAdmin(user:event:completionHandler:)  Inserted in class   TO TEST
///call this function to make a normal member an admin in an event

// degradeAdminToMember(user:group:completionHandler:)  Inserted in class   Works
///calll this function to make an admin a normal member in a group

// degradeAdminToMember(user:event:completionHandler:)  Inserted in class   TO TEST
///calll this function to make an admin a normal member in an event

// addFriend(friend:completionHandler:)  Inserted in class                   Works
///call this function to add a new friend to the list

// removeFriend(friend:completionHandler:)  Inserted in class                Works
///call this function to remove a friend from the list

// updateUser(username:score:avatarID:group:completionHandler:)  Inserted in class   Works
///call this function to modify some parameter of a user (some of them have a default value)

// updateGroup(name:picID:group:event:completionHandler:)  Inserted in class         Works
///call this function to modify some parameter of a group (some of them have a default value)

import CloudKit
import CoreLocation
import Foundation

/// Use this class to access to iCloud database.
class CloudDBController {
    /// Use this istance to access to methods.
    static let shared = CloudDBController()

    var container: CKContainer
    var publicDB: CKDatabase
    var sharedDB: CKDatabase
    private let privateDB: CKDatabase
    private var delegate: CloudControllerDelegate?

    private init() {
        container = CKContainer(identifier: "iCloud.Mad-Max.sloth")
        publicDB = container.publicCloudDatabase
        sharedDB = container.sharedCloudDatabase
        privateDB = container.privateCloudDatabase
    }

    // MARK: - CREATE

    /// This is an helper function.
    private func createUser(name: String, surname: String, username: String, score: Int, groups: [CKRecord.ID], avatarID: Int, completionHandler: @escaping (Bool, CKRecord.ID?) -> Void) {
        var groupList: [CKRecord.Reference] = []

        for group in groups {
            groupList.append(CKRecord.Reference(recordID: group, action: .none))
        }

        let recordObject = CKRecord(recordType: "User")

        recordObject.setValue(name, forKey: "name")
        recordObject.setValue(surname, forKey: "surname")
        recordObject.setValue(username, forKey: "username")
        recordObject.setValue(score, forKey: "score")
        recordObject.setValue(groups, forKey: "groups")
        recordObject.setValue(avatarID, forKey: "avatarID")

        publicDB.save(recordObject) { record, error in
            if error == nil {
                print("Object Saved")
                completionHandler(true, record!.recordID)
            } else {
                print(error!.localizedDescription as String)
                completionHandler(false, nil)
            }
        }
    }

    /// Use this function in order to create a new user.
    /// - Parameters:
    ///   - name: the user's givenName
    ///   - surname: the user's familyName
    ///   - username: the user's username
    ///   - score: the user's score
    ///   - groups: the user's groups
    ///   - avatarID: the user's avatarID
    ///   - completionHandler: set all the operations to do inside the completion handler
    func createUser(name: String, surname: String, username: String, score: Int, groups: [GroupData], avatarID: Int, friendList: [UserData], completionHandler: @escaping (UserData, Friends?) -> Void) {
        var groupList: [CKRecord.ID] = []

        for group in groups {
            groupList.append(group.ID)
        }

        createUser(name: name, surname: surname, username: username, score: score, groups: groupList, avatarID: avatarID) { isCreated, recordID in
            if isCreated {
                self.createFriendList(userID: recordID!, friendList: friendList) { friend, isCreatedFriend in
                    if isCreatedFriend {
                        completionHandler(UserData(ID: recordID!, name: name, surname: surname, username: username, score: score, avatarID: avatarID), friend!)
                    } else {
                        debugPrint("Error occurred while creating the user friend list")
                        completionHandler(UserData(ID: recordID!, name: name, surname: surname, username: username, score: score, avatarID: avatarID), nil)
                    }
                }
            } else {
                debugPrint("Error occurred while creating the user")
            }
        }
    }

    func createPrivateUserData(appleID: String, userID: CKRecord.ID, completionHandler: @escaping (Bool) -> Void) {
        let userReference = CKRecord.Reference(recordID: userID, action: .deleteSelf)
        let recordObject = CKRecord(recordType: "UserIdentifier")

        recordObject.setValue(appleID, forKey: "appleID")
        recordObject.setValue(userReference, forKey: "user")

        privateDB.save(recordObject) { _, error in
            if error == nil {
                print("Object saved inside UserIdentifier")
                completionHandler(true)
            } else {
                debugPrint("Error occurred while creating the UserIdentifier")
                completionHandler(false)
            }
        }
    }

    /// This is an helper function.
    private func createGroup(name: String, admins: [CKRecord.ID], members: [CKRecord.ID], picID: Int, events: [CKRecord.ID], completionHandler: @escaping (Bool, CKRecord.ID?) -> Void) {
        var adminList: [CKRecord.Reference] = []
        var memberList: [CKRecord.Reference] = []
        var eventList: [CKRecord.Reference] = []

        for admin in admins {
            adminList.append(CKRecord.Reference(recordID: admin, action: .none))
        }

        for member in members {
            memberList.append(CKRecord.Reference(recordID: member, action: .none))
        }

        for event in events {
            eventList.append(CKRecord.Reference(recordID: event, action: .none))
        }

        let recordObject = CKRecord(recordType: "Group")

        recordObject.setValue(name, forKey: "name")
        recordObject.setValue(adminList, forKey: "admins")
        recordObject.setValue(memberList, forKey: "participants")
        recordObject.setValue(eventList, forKey: "events")
        recordObject.setValue(picID, forKey: "picID")

        publicDB.save(recordObject) { record, error in
            if error == nil {
                print("Group Saved")
                completionHandler(true, record!.recordID)
            } else {
                print(error!.localizedDescription as String)
                completionHandler(false, nil)
            }
        }
    }

    /// Use this function in order to create a new group.
    /// - Parameters:
    ///   - name: the group's name
    ///   - admins: the group's admins
    ///   - members: the group's members
    ///   - picID: the group's picID
    ///   - events: the group's event list
    ///   - completionHandler: set all the operations to do inside the completion handler
    func createGroup(name: String, admins: [UserData], members: [UserData], picID: Int, events: [EventData], completionHandler: @escaping (GroupData) -> Void) {
        var adminList: [CKRecord.ID] = []
        var memberList: [CKRecord.ID] = []
        var eventList: [CKRecord.ID] = []
        var count = 0
        var countTrue = 0
        for admin in admins {
            adminList.append(admin.ID)
        }

        for member in members {
            memberList.append(member.ID)
        }

        for event in events {
            eventList.append(event.ID)
        }

        createGroup(name: name, admins: adminList, members: memberList, picID: picID, events: eventList) { isCreated, recordID in
            if isCreated == true {
                let completeList = admins + members
                let countDef = completeList.count
                for user in completeList {
                    self.addGroupReferenceToUser(user: user, groupID: recordID!) { completed in
                        count += 1
                        if completed == true {
                            countTrue += 1
                            if countTrue == countDef && count == countDef {
                                completionHandler(GroupData(ID: recordID!, name: name, picID: picID, admins: admins, members: members, events: []))
                            } else {
                                if countTrue != countDef && count == countDef {
                                    print("Error in create group query")
                                }
                            }
                        }
                    }
                }
            } else {
                debugPrint("Error occurred while creating the group")
            }
        }
    }

    /// This is an helper function.
    private func createEvent(name: String, place: CLLocation, dateTime: NSDate, admins: [CKRecord.ID], penaltyID: Int, completionHandler: @escaping (Bool, CKRecord.ID?) -> Void) {
        var adminList: [CKRecord.Reference] = []

        let participantList: [CKRecord.Reference] = []

        for admin in admins {
            adminList.append(CKRecord.Reference(recordID: admin, action: .none))
        }

        let recordObject = CKRecord(recordType: "Event")

        recordObject.setValue(name, forKey: "name")
        recordObject.setValue(adminList, forKey: "admins")
        recordObject.setValue(participantList, forKey: "participants")
        recordObject.setValue(penaltyID, forKey: "penaltyID")
        recordObject.setValue(place, forKey: "place")
        recordObject.setValue(dateTime, forKey: "dateTime")

        publicDB.save(recordObject) { record, error in
            if error == nil {
                print("Event Saved")
                completionHandler(true, record?.recordID)
            } else {
                print(error!.localizedDescription as String)
                completionHandler(false, nil)
            }
        }
    }

    /// Use this function in order to create a new event.
    /// - Parameters:
    ///   - name: the event's name
    ///   - place: the event's place
    ///   - dateTime: the event's date and time
    ///   - admins: the event's admins
    ///   - participants: the event's participants
    ///   - penaltyID: the event's penalty ID
    ///   - completionHandler: set all the operations to do inside the completion handler
    func createEvent(name: String, place: CLLocation, dateTime: NSDate, admins: [UserData], penaltyID: Int, group: GroupData, completionHandler: @escaping (EventData) -> Void) {
        var adminList: [CKRecord.ID] = []

        var participantList: [UserData] = []

        for admin in admins {
            adminList.append(admin.ID)
        }

        readMembersAdminsInGroup(groupID: group.ID) { membersData, adminsData in
            participantList = adminsData + membersData
            
//            var prova = participantList.count
//            for i in 0 ..< admins.count {
//                for j in 0 ..< participantList.count {
//
//                    if admins[i].ID.recordName == participantList[j].ID.recordName {
//                        participantList.remove(at: j)
//                        prova -= 1
//                        if prova == participantList.count{
//                            break
//                        }
//                    }
//                }
//            }
            

            self.createEvent(name: name, place: place, dateTime: dateTime, admins: adminList, penaltyID: penaltyID) { isCreated, recordID in
                
                var accepted : ParticipationType = .notSeen

                if isCreated == true {
                    let event = EventData(ID: recordID!, name: name, penaltyID: penaltyID, place: place, dateTime: dateTime, admins: admins, participants: [])
                    
                    self.updateGroup(group: group, event: event) { (isFinished) in
                        if isFinished {
                            for participant in participantList {
                                if participant.ID.recordName == UserManager.shared.userInfo.ID.recordName{
                                    accepted = .confirmed
                                }
                                else{
                                    accepted = .notSeen
                                }
                                
                                self.createParticipation(user: participant, event: event, delay: 0, accepted: accepted) { participation, isCreated2 in
                                    if isCreated2 {
                                        if participant.ID.recordName == participantList.last?.ID.recordName {
                                            completionHandler(event)
                                        }
                                    } else {
                                        debugPrint("Error occurred while creating event")
                                    }
                                }
                            }
                        }
                    }

                    
                } else {
                    debugPrint("Error occurred while creating the event")
                }
            }
        }
    }

    private func createParticipation(user: UserData, event: EventData, delay: Int, accepted: ParticipationType, completionHandler: @escaping (Participation?, Bool) -> Void) {
        let userReference = CKRecord.Reference(recordID: user.ID, action: .deleteSelf)
        let eventReference = CKRecord.Reference(recordID: event.ID, action: .deleteSelf)

        let recordObject = CKRecord(recordType: "Participation")
        var acceptInt = 0
        recordObject.setValue(userReference, forKey: "user")
        recordObject.setValue(eventReference, forKey: "event")
        
        switch accepted {
        case .notSeen:
            acceptInt = 0
            break
        case .confirmed:
            acceptInt = 1
            break
        case .denied:
            acceptInt = 2
            break
        }
        
        recordObject.setValue(acceptInt, forKey: "accepted")
        recordObject.setValue(delay, forKey: "delay")

        publicDB.save(recordObject) { record, error in
            if error == nil {
                completionHandler(Participation(ID: record!.recordID, accepted: accepted, delay: delay, event: event, user: user), true)
            } else {
                print("Error occurred while creating participation")
                print(error?.localizedDescription as Any)
                completionHandler(nil, false)
            }
        }
    }

    private func createFriendList(userID: CKRecord.ID, friendList: [UserData], completionHandler: @escaping (Friends?, Bool) -> Void) {
        let recordObject = CKRecord(recordType: "Friends")
        var friendReference = [CKRecord.Reference]()
        let userReference = CKRecord.Reference(recordID: userID, action: .deleteSelf)

        for friend in friendList {
            friendReference.append(CKRecord.Reference(recordID: friend.ID, action: .none))
        }

        recordObject.setValue(userReference, forKey: "user")
        recordObject.setValue(friendReference, forKey: "contacts")

        publicDB.save(recordObject) { record, error in
            if error == nil {
                completionHandler(Friends(ID: record!.recordID, contacts: friendList), true)
            } else {
                print("Error occurred while creating friendlist")
                print(error?.localizedDescription as Any)
                completionHandler(nil, false)
            }
        }
    }

    // MARK: - READ

    func readPrivateUserData(ID: String, completionHandler: @escaping (CKRecord.Reference?, Bool) -> Void) {
        var found = false

        let predicate = NSPredicate(format: "appleID = %@", ID)

        let query = CKQuery(recordType: "UserIdentifier", predicate: predicate)

        privateDB.perform(query, inZoneWith: nil) { results, error in

            if error == nil {
                if !(results?.isEmpty ?? true) {
                    found = true
                    let userReference = results?.first!["user"] as! CKRecord.Reference
                    completionHandler(userReference, found)
                } else {
                    print("Database does not contain this appleID")
                    completionHandler(nil, found)
                }
            }
        }
    }

    func readUserData(userReference: CKRecord.Reference, completionHandler: @escaping (UserData) -> Void) {
        let predicate = NSPredicate(format: "recordID = %@", userReference.recordID)

        let query = CKQuery(recordType: "User", predicate: predicate)
        
        var groups : [CKRecord.Reference] = []

        var userData = UserData(ID: CKRecord.ID(recordName: "test"), name: "", surname: "", username: "", score: 0, avatarID: 0)

        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error == nil {
                if !(results?.isEmpty ?? true) {
                    let ID = results?.first?.recordID
                    let name = results?.first!["name"] as! String
                    let surname = results?.first!["surname"] as! String
                    let username = results?.first!["username"] as! String
                    let score = results?.first!["score"] as! Int
                    let avatarID = results?.first!["avatarID"] as! Int
                    
                    if results?.first?["groups"] != nil{
                        groups = results?.first!["groups"] as! [CKRecord.Reference]
                    }
                    else{
                        groups  = []
                    }
                    
//                    let groups = results?.first!["groups"] as! [CKRecord.Reference]

                    userData.ID = ID!
                    userData.name = name
                    userData.surname = surname
                    userData.username = username
                    userData.score = score
                    userData.avatarID = avatarID
                    userData.groupList = groups
                } else {
                    print("User not found")
                }
            } else {
                print("Error occurred while reading user")
                print(error?.localizedDescription as Any)
            }

            completionHandler(userData)
        }
    }

    private func readUserDataWithGroupsReference(userReference: CKRecord.Reference, completionHandler: @escaping (UserData) -> Void) {
        let predicate = NSPredicate(format: "recordID = %@", userReference.recordID)

        let query = CKQuery(recordType: "User", predicate: predicate)
        
        var groupReference : [CKRecord.Reference] = []

        var userData = UserData(ID: CKRecord.ID(recordName: "test"), name: "", surname: "", username: "", score: 0, avatarID: 0)

        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error == nil {
                if !(results?.isEmpty ?? true) {
                    let ID = results?.first?.recordID
                    let name = results?.first!["name"] as! String
                    let surname = results?.first!["surname"] as! String
                    let username = results?.first!["username"] as! String
                    let score = results?.first!["score"] as! Int
                    let avatarID = results?.first!["avatarID"] as! Int
                    
                    if results?.first!["groups"] != nil{
                         groupReference = results?.first!["groups"] as! [CKRecord.Reference]
                    }
                    

                    userData.ID = ID!
                    userData.name = name
                    userData.surname = surname
                    userData.username = username
                    userData.score = score
                    userData.avatarID = avatarID
                    userData.groupList = groupReference
                } else {
                    print("User not found")
                }
            } else {
                print("Error occurred while reading user")
                print(error?.localizedDescription as Any)
            }

            completionHandler(userData)
        }
    }

    private func fillList(with users: [CKRecord.Reference], completionHandler: @escaping ([UserData]) -> Void) {
        var userList = [UserData]()
        var count = 0
        if users.count == 0{
            completionHandler([])
        }
        for user in users {
            readUserData(userReference: user) { userData in
                count += 1
                userList.append(userData)
                if count == users.count {
                    completionHandler(userList)
                }
            }
        }
        
    }

    func readUserFromUsername(username: String, completionHandler: @escaping ([UserData]) -> Void) {
//        let predicate = NSPredicate(format: "username contains %@", username)
        
        let predicate = NSPredicate(format: "username BEGINSWITH %@", username)

        let query = CKQuery(recordType: "User", predicate: predicate)

        var userList: [UserData] = []

        publicDB.perform(query, inZoneWith: nil) { records, error in
            if error != nil {
                print("error occured during readUserFromUsername query")
                print(error?.localizedDescription as Any)
            } else {
                for record in records! {
                    let user = UserData(ID: record.recordID,
                                        name: record["name"] as! String,
                                        surname: record["surname"] as! String,
                                        username: record["username"] as! String,
                                        score: record["score"] as! Int,
                                        avatarID: record["avatarID"] as! Int)
                    userList.append(user)
                }
                completionHandler(userList)
            }
            completionHandler([])
        }
    }

    func readMembersAdminsInGroup(groupID: CKRecord.ID, completionHandler: @escaping ([UserData], [UserData]) -> Void) {
        let predicate = NSPredicate(format: "recordID = %@", groupID)
        
        let query = CKQuery(recordType: "Group", predicate: predicate)
        
        var members = [CKRecord.Reference]()
        var membersList = [UserData]()
        
        var admins = [CKRecord.Reference]()
        var adminsList = [UserData]()
        
        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error != nil {
                print("Error occurred during readMembersAdminsInGroup query")
                
                print(error?.localizedDescription as Any)
            } else {
                
                if !(results?.isEmpty ?? true) {
                    if results?.first!["participants"] != nil{
                        members = results?.first!["participants"] as! [CKRecord.Reference]
                    }
                    admins = results?.first!["admins"] as! [CKRecord.Reference]
                    
                    self.fillList(with: admins) { userAdmins in
                        adminsList = userAdmins
                        self.fillList(with: members) { userMembers in
                            membersList = userMembers
                            completionHandler(membersList, adminsList)
                        }
                    }
                }
                else{
                    completionHandler(membersList,adminsList)
                }
                
            }
            
        }
    }

    func readMembersAdminsInEvent(eventID: CKRecord.ID, completionHandler: @escaping ([UserData], [UserData]) -> Void) {
        let predicate = NSPredicate(format: "recordID = %@", eventID)

        let query = CKQuery(recordType: "Event", predicate: predicate)

        var members = [CKRecord.Reference]()
        var membersList = [UserData]()

        var admins = [CKRecord.Reference]()
        var adminsList = [UserData]()

        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error != nil {
                print("Error occurred during readMembersAdminsInGroup query")
                
                print(error?.localizedDescription as Any)
            } else {
                
                if !(results?.isEmpty ?? true) {
                    if results?.first!["participants"] != nil{
                        members = results?.first!["participants"] as! [CKRecord.Reference]
                    }
                    admins = results?.first!["admins"] as! [CKRecord.Reference]
                    
                    self.fillList(with: admins) { userAdmins in
                        adminsList = userAdmins
                        self.fillList(with: members) { userMembers in
                            membersList = userMembers
                            completionHandler(membersList, adminsList)
                        }
                    }
                }
                else{
                    completionHandler(membersList,adminsList)
                }
                
            }
            
        }
    }

    private func readEventsReferenceFromGroup(groupID: CKRecord.ID, completionHandler: @escaping ([CKRecord.Reference], Bool) -> Void) {
        
        let predicate = NSPredicate(format: "recordID = %@", groupID)

        var found = false

        var eventsList = [CKRecord.Reference]()

        let queryGroup = CKQuery(recordType: "Group", predicate: predicate)

        publicDB.perform(queryGroup, inZoneWith: nil) { results, error in
            
            if error == nil {
                if !(results?.isEmpty ?? true) {
                    
                        
                        
                        if results?.first!["events"] == nil {
                            found = false
                            completionHandler(eventsList, found)
                            return
                        }
                        else{
                            
                            found = true
                            
                            let reference = results?.first!["events"] as! [CKRecord.Reference]

                            eventsList = reference
                            
                            completionHandler(eventsList, found)
//                            return
                        }
                    
                }
                else {
                    print("Events not found")
                    completionHandler(eventsList, found)
                }
            }
            else {
                print("Error occurred during readEventsReferenceFromGroup Query")
                print(error?.localizedDescription as Any)
                completionHandler(eventsList, found)
            }

//            completionHandler(eventsList, found)
        }
    }
    
    /// Helper function
    private func readAllUserGroups(userID: CKRecord.ID, completionHandler: @escaping ([CKRecord.ID], Bool) -> Void) {
        //        let userReference = CKRecord.Reference(recordID: userID, action: .none)
        
        var found = false
        
        let predicate = NSPredicate(format: "recordID = %@", userID)
        
        var groupList : [CKRecord.ID] = []
        
        let queryGroup = CKQuery(recordType: "User", predicate: predicate)
        
        publicDB.perform(queryGroup, inZoneWith: nil) { results, error in
            
            if error == nil {
                if !(results?.isEmpty ?? true) {
                    
                    if results?.first!["groups"] == nil{
//                        print("ue")
                        completionHandler(groupList, false)
                        return
                    }
                    
                    else{
                        let groupListRef = results?.first!["groups"] as! [CKRecord.Reference]
                        
                        for groupRef in groupListRef{
                            groupList.append(groupRef.recordID)
                        }
                        found = true
                    }
                    
                } else {
                    print("Groups not found")
                }
            }
            else {
                print("Error occurred during readAllUserGroups Query")
                print(error?.localizedDescription as Any)
            }
            completionHandler(groupList, found)
        }
    }

    /// Use this function in order to get a list of events in a group.
    /// - Parameters:
    ///   - groupID: groupID parameter
    ///   - completionHandler: set all the operations to do inside the completion handler
    func readEventsFromGroup(groupID: CKRecord.ID, completionHandler: @escaping ([EventData]) -> Void) {

        var eventList = [EventData]()

        readEventsReferenceFromGroup(groupID: groupID) { eventsList, found in

            if found {
                
                if eventsList.count == 0{
                    completionHandler(eventList)
                    return
                }
                
                for event in eventsList {
                    
                    let predicate = NSPredicate(format: "recordID = %@", event.recordID)
                    
                    let queryEvents = CKQuery(recordType: "Event", predicate: predicate)
                    
                    self.publicDB.perform(queryEvents, inZoneWith: nil) { results, error in
                        if error == nil {
                            if !(results?.isEmpty ?? true) {
                                for record in results! {
                                    
                                    self.readMembersAdminsInEvent(eventID: record.recordID) { (members, admins) in
                                        eventList.append(
                                            EventData(ID: record.recordID,
                                                      name: record["name"] as! String,
                                                      penaltyID: record["penaltyID"] as! Int,
                                                      place: record["place"] as! CLLocation,
                                                      dateTime: record["dateTime"] as! NSDate,
                                                      admins: admins,
                                                      participants: members)
                                        )
                                        
                                        if eventsList.count == eventList.count{
                                            completionHandler(eventList)
                                            return
                                        }
                                    }
                                    
                                }
                                 
                            } else {
                                print("Events not found")
                                completionHandler(eventList)
                                return
                            }
                        } else {
                            print("Error occurred during readEventsFromGroup Query")
                            print(error?.localizedDescription as Any)
                            completionHandler(eventList)
                            return
                        }
                    }
                }
                
            }
            else{
                completionHandler(eventList)
            }

        }
    }
    
    private func readEventsFromGroupWithDate(groupID: CKRecord.ID, dateTime: NSDate, completionHandler: @escaping ([EventData]) -> Void) {

            var eventList = [EventData]()

            readEventsReferenceFromGroup(groupID: groupID) { eventsList, found in

                if found {
                    for event in eventsList {
                        
                        let predicate = NSPredicate(format: "recordID = %@ AND dateTime >= %@", event.recordID, dateTime)
                        
                        let queryEvents = CKQuery(recordType: "Event", predicate: predicate)
                        
                        self.publicDB.perform(queryEvents, inZoneWith: nil) { results, error in
                            if error == nil {
                                if !(results?.isEmpty ?? true) {
                                    for record in results! {
                                        eventList.append(
                                            EventData(
                                                ID: record.recordID,
                                                name: record["name"] as! String,
                                                penaltyID: record["penaltyID"] as! Int,
                                                place: record["place"] as! CLLocation,
                                                dateTime: record["dateTime"] as! NSDate))
                                    }
                                    
                                    if eventsList.count == eventList.count{
                                        completionHandler(eventList)
    //                                    return
                                    }
                                    
                                } else {
                                    print("Events not found")
                                }
                            } else {
                                print("Error occurred during readEventsFromGroup Query")
                                print(error?.localizedDescription as Any)
                            }
                        }
                    }
                    
                }
                else{
                    completionHandler(eventList)
                }

            }
        }
    
    

    /// Call this function in order to get all the events
    /// - Parameters:
    ///   - userID: insert here the userID
    ///   - completionHandler: set all the operations to do inside the completion handler
    func readEventsFromAllGroups(userID: CKRecord.ID, completionHandler: @escaping ([EventData]) -> Void) {
        readAllUserGroups(userID: userID) { listGroupID, found in

            var eventList : [EventData] = []

            if found == true {
                if listGroupID.count == 0{
                    completionHandler(eventList)
                }
                else{
                    for groupID in listGroupID {
                        self.readEventsFromGroup(groupID: groupID) { tempList in
                            eventList.append(contentsOf: tempList)
                            if groupID.recordName == listGroupID.last?.recordName{
                                completionHandler(eventList)
                            }
                        }
                    }
                }
                
                
            }
            else{
                completionHandler(eventList)
            }
            
            
        }
    }

    /// Call this function in order to get all friends for an user
    /// - Parameters:
    ///   - userIdentifier: insert here the userID
    ///   - completionHandler: set all the operations to do inside the completion handler
    func readFriendsList(user: UserData, completionHandler: @escaping (Friends?) -> Void) {
        let userReference = CKRecord.Reference(recordID: user.ID, action: .deleteSelf)

        let predicate = NSPredicate(format: "user = %@", userReference)

        var friendsList = [UserData]()

        var referenceList = [CKRecord.Reference]()

        let queryReference = CKQuery(recordType: "Friends", predicate: predicate)

        var found = false

        publicDB.perform(queryReference, inZoneWith: nil) { results, errorReferences in
            if errorReferences != nil {
                print("Error occurred during readFriendslist query")
                print(errorReferences?.localizedDescription as Any)
                completionHandler(nil)
            } else {
                if !(((results?.first!["contacts"])! as [CKRecord.Reference]).isEmpty) {
                    referenceList = results?.first!["contacts"] as! [CKRecord.Reference]
                    found = true
                }

                if found {
                    for reference in referenceList {
                        let predicate2 = NSPredicate(format: "recordID = %@", reference.recordID)
                        let queryFriendsList = CKQuery(recordType: "User", predicate: predicate2)

                        self.publicDB.perform(queryFriendsList, inZoneWith: nil) { friends, errorFriends in
                            if errorFriends != nil {
                                print("Error occurred during readFriendslist query")
                                print(errorFriends?.localizedDescription as Any)

                                completionHandler(nil)

                            } else {
                                if !(results?.isEmpty ?? true) {
                                    let friend = UserData(ID: (friends?.first!.recordID)!,
                                                          name: friends?.first!["name"] as! String,
                                                          surname: friends?.first!["surname"] as! String,
                                                          username: friends?.first!["username"] as! String,
                                                          score: friends?.first!["score"] as! Int,
                                                          avatarID: friends?.first!["avatarID"] as! Int)

                                    friendsList.append(friend)
                                }
                                if friendsList.count == referenceList.count {
                                    completionHandler(Friends(ID: (results?.first!.recordID)!, contacts: friendsList))
                                }
                            }
                        }
                    }
                }
                else {
                    completionHandler(Friends(ID: (results?.first!.recordID)!, contacts: []))
                }
            }
        }
    }

    func readParticipations(event: EventData, completionHandler: @escaping ([Participation]) -> Void) {
        let reference = CKRecord.Reference(recordID: event.ID, action: .deleteSelf)
        
        let predicateParticipation = NSPredicate(format: "event = %@", reference)

        let query = CKQuery(recordType: "Participation", predicate: predicateParticipation)

        var participationList = [Participation]()

        var participationID = CKRecord.ID(recordName: "temp")

        var participationAccepted = 0

        var participationDelay = 0

        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error == nil {
                if !(results?.isEmpty ?? true) {
                    for record in results! {
                        let userReference = record["user"] as! CKRecord.Reference

                        participationID = record.recordID
                        participationAccepted = (record["accepted"] as! Int)
                        participationDelay = record["delay"] as! Int

                        let predicateUser = NSPredicate(format: "recordID = %@", userReference.recordID)
                        let queryUser = CKQuery(recordType: "User", predicate: predicateUser)

                        self.publicDB.perform(queryUser, inZoneWith: nil) { results, error in
                            if error == nil {
                                participationList.append(
                                    Participation(
                                        ID: participationID,
                                        accepted: ParticipationType(rawValue: participationAccepted)!,
                                        delay: participationDelay,
                                        event: event,
                                        user: UserData(ID: (results?.first!.recordID)!,
                                                       name: results?.first!["name"] as! String,
                                                       surname: results?.first!["surname"] as! String,
                                                       username: results?.first!["username"] as! String,
                                                       score: results?.first!["score"] as! Int,
                                                       avatarID: results?.first!["avatarID"] as! Int))
                                )
                                
                                if participationList.count == results?.count{
                                    completionHandler(participationList)
                                }
                                
                            } else {
                                print("Error occurred while fetching user in Participation query")
                                print(error?.localizedDescription as Any)
                                completionHandler(participationList)
                            }
                            
                        }
                    }
                } else {
                    print("Event not found")
                    completionHandler(participationList)
                }
            } else {
                print("Error occurred during readParticipations query")
                print(error?.localizedDescription as Any)
                completionHandler(participationList)
            }
        }
    }
    
    func readParticipation(event: EventData, user: UserData = UserManager.shared.userInfo, completionHandler: @escaping (Participation) -> Void){
        let eventReference = CKRecord.Reference(recordID: event.ID, action: .deleteSelf)
        
        let userReference = CKRecord.Reference(recordID: user.ID, action: .deleteSelf)
        
        let eventPredicate = NSPredicate(format: "event = %@", eventReference)
        
        let userPredicate = NSPredicate(format: "user = %@", userReference)
        
        let predicateParticipation = NSCompoundPredicate(andPredicateWithSubpredicates: [eventPredicate, userPredicate])

        let query = CKQuery(recordType: "Participation", predicate: predicateParticipation)

        publicDB.perform(query, inZoneWith: nil) { results, error in
            if error == nil {
                if !(results?.isEmpty ?? true) {
                    let record =  results!.first!

                    if user.ID.recordName == UserManager.shared.userInfo.ID.recordName{
                        let participation = Participation(ID: record.recordID, accepted: ParticipationType(rawValue: record["accepted"] as! Int)!, delay: record["delay"] as! Int, event: event, user: UserManager.shared.userInfo)
                        
                        completionHandler(participation)
                    }
                    else{
                        self.readUserData(userReference: userReference) { (userData) in
                            let participation = Participation(ID: record.recordID, accepted: ParticipationType(rawValue: record["accepted"] as! Int)!, delay: record["delay"] as! Int, event: event, user: userData)
                            
                            completionHandler(participation)
                        }
                    }
                } else {
                    print("Participation not found")
                }
            } else {
                print("Error occurred during readParticipation query")
                print(error?.localizedDescription as Any)
            }
        }
    }

    func readEvent(eventID: CKRecord.ID, completionHandler: @escaping (EventData) -> Void) {
        let predicate = NSPredicate(format: "recordID = %@", eventID)

        let query = CKQuery(recordType: "Event", predicate: predicate)

        publicDB.perform(query, inZoneWith: nil) { records, error in
            if error != nil {
                print(error?.localizedDescription as Any)
                
                let event = EventData(ID: CKRecord.ID(), name: "", penaltyID: 0, place: CLLocation(latitude: 0, longitude: 0), dateTime: NSDate(), admins: [], participants: [])
                completionHandler(event)
            } else {
                self.readMembersAdminsInEvent(eventID: eventID) { members, admins in

                    let event = EventData(ID: (records?.first!.recordID)!,
                                      name: records?.first!["name"] as! String,
                                      penaltyID: records?.first!["penaltyID"] as! Int,
                                      place: records?.first!["place"] as! CLLocation,
                                      dateTime: records?.first!["dateTime"] as! NSDate,
                                      admins: admins,
                                      participants: members)

                    completionHandler(event)
                }
            }
        }
    }
    
    func readGroup(group: CKRecord.Reference, completionHandler: @escaping (GroupData) -> Void){
        let predicate = NSPredicate(format: "recordID = %@", group.recordID)
        
        let query = CKQuery(recordType: "Group", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                let record = records?.first!
                self.readMembersAdminsInGroup(groupID: record!.recordID) { (members, admins) in
                    var group = GroupData(ID: record!.recordID,
                                          name: record!["name"] as! String,
                                          picID: record!["picID"] as! Int,
                                          admins: admins,
                                          members: members,
                                          events: [])
                    self.readEventsFromGroup(groupID: record!.recordID) { (events) in
                        group.events = events
                        completionHandler(group)
                    }
                }
//                var group = GroupData(ID: record!.recordID,
//                                      name: record!["name"] as! String,
//                                      picID: record!["picID"] as! Int,
//                                      admins: record!["admins"] as! [UserData],
//                                      members: record!["members"] as! [UserData], events: [])
//                self.readEventsFromGroup(groupID: record!.recordID) { (events) in
//                    group.events = events
//                    completionHandler(group)
//                }
            }
        }
    }
    
    func readAllGroups(completionHandler: @escaping ([GroupData]) -> Void){
        var groupList: [GroupData] = []
//        print(UserManager.shared.userInfo.groupList)
//        if UserManager.shared.userInfo.groupList?.count == 0{
//            completionHandler(groupList)
//        }
//
//        for group in UserManager.shared.userInfo.groupList! {
//            self.readGroup(group: group) { (group2) in
//                groupList.append(group2)
//                if groupList.count == UserManager.shared.userInfo.groupList!.count {
//                    completionHandler(groupList)
//                }
//            }
//        }
        
        readAllUserGroups(userID: UserManager.shared.userInfo.ID) { (groupListID, success) in
            if groupListID.count == 0{
                completionHandler(groupList)
            }
            
            for groupID in groupListID{
                let predicate = NSPredicate(format: "recordID = %@", groupID)
                
                let query = CKQuery(recordType: "Group", predicate: predicate)
                
                self.publicDB.perform(query, inZoneWith: nil) { (results, error) in
                    if error == nil{
                        if !(results?.isEmpty ?? true) {
                            let id = results?.first?.recordID
                            self.readMembersAdminsInGroup(groupID: id!) { (member, admin) in
                                self.readEventsFromGroup(groupID: id!) { (event) in
                                    groupList.append(GroupData(ID: id!,
                                    name: results?.first!["name"] as! String,
                                    picID: results?.first!["picID"] as! Int,
                                    admins: admin,
                                    members: member,
                                    events: event))
                                    if groupList.count == groupListID.count{
                                        completionHandler(groupList)
                                    }
                                }
                            }
                        }
                    }
                    else{
                        print("Error occurred while reading groups")
                        print(error?.localizedDescription as Any)
                        completionHandler(groupList)
                    }
                }
            }
            
        }
        

        
    }
    
    func readFutureEvents(ID: CKRecord.ID, completionHandler: @escaping ([EventData]) -> Void){
        
        readEventsFromGroupWithDate(groupID: ID, dateTime: NSDate()) { (events) in
            completionHandler(events)
        }
    }
    


    // MARK: - UPDATE

    private func addGroupReferenceToUser(user: UserData, groupID: CKRecord.ID, completionHandler: @escaping (Bool) -> Void) {
        let recordUser = CKRecord(recordType: "User", recordID: user.ID)
        let userReference = CKRecord.Reference(recordID: user.ID, action: .none)
        let groupReference = CKRecord.Reference(recordID: groupID, action: .none)

        readUserDataWithGroupsReference(userReference: userReference) { user in

            var groupList = user.groupList
            groupList?.append(groupReference)
            
            recordUser.setValue(groupList, forKey: "groups")

            let operation = CKModifyRecordsOperation(recordsToSave: [recordUser])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                completionHandler(true)
            }

            self.publicDB.add(operation)
        }
    }
    
    

    func addMemberToGroup(member: UserData, group: GroupData, completionHandler: @escaping (Bool) -> Void) {
        let recordGroup = CKRecord(recordType: "Group", recordID: group.ID)
        
        let userReference = CKRecord.Reference(recordID: member.ID, action: .none)

        updateUser(user: member, group: group, completionHandler: { (success) in
            

            self.readMembersAdminsInGroup(groupID: group.ID) { members, _ in
                var userListReference = [CKRecord.Reference]()

                for memberF in members {
                    userListReference.append(CKRecord.Reference(recordID: memberF.ID, action: .none))
                }

                userListReference.append(userReference)

                recordGroup.setValue(userListReference, forKey: "participants")

                let operation = CKModifyRecordsOperation(recordsToSave: [recordGroup])


                operation.savePolicy = .changedKeys


                operation.isAtomic = true

                operation.completionBlock = {
                    if !operation.isCancelled {
                        print("è andato bene")
                        self.readEventsFromGroup(groupID: group.ID) { (events) in
                            print(events.count)
//                            var eventList: [EventData] = []
                            let calendar = Calendar.current
                            for event in events {
                                let timeToEvent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: event.dateTime as Date).second
                                if timeToEvent! > 0 {
                                    print("PRINT ")
                                    
                                    self.createParticipation(user: member, event: event, delay: 0, accepted: .notSeen) { (participation, success) in
                                        if success {
                                            print("participation created")
                                        } else {
                                            print("creating participation failed")
                                        }
                                    }
                                }
                                if event.name == events.last?.name {
                                    completionHandler(true)
                                }
                            }
                            
                            if events.isEmpty {
                                completionHandler(true)
                            }
                        }

                    } else {
                        completionHandler(false)
                    }
                }

                self.publicDB.add(operation)
                
            }
            
            
        })

            
        
    }

    func replyEventInvitation(participation: Participation, value: ParticipationType, completionHandler: @escaping (Bool) -> Void) {
        let recordObject = CKRecord(recordType: "Participation", recordID: participation.ID)

        var valueInt = 0
        
        switch value {
        case .notSeen: valueInt = 0
            break
        case .denied: valueInt = 2
            break
        case .confirmed: valueInt = 1
            break
        }
        recordObject.setValue(valueInt, forKey: "accepted")

        let recordEvent = CKRecord(recordType: "Event", recordID: participation.event.ID)

        if value == .confirmed {
            readEvent(eventID: participation.event.ID) { event in
                var participantList = [CKRecord.Reference]()

                for member in event.participants! {
                    participantList.append(CKRecord.Reference(recordID: member.ID, action: .none))
                }
                participantList.append(CKRecord.Reference(recordID: participation.user!.ID, action: .none))
                recordEvent.setValue(participantList, forKey: "participants")

                let operation = CKModifyRecordsOperation(recordsToSave: [recordObject, recordEvent])
                operation.isAtomic = true
                operation.completionBlock = {
                    if !operation.isCancelled {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                }

                operation.savePolicy = .changedKeys

                self.publicDB.add(operation)
            }
        } else {
            let operation = CKModifyRecordsOperation(recordsToSave: [recordObject])
            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }

            operation.savePolicy = .changedKeys

            publicDB.add(operation)
        }
    }
    
    func removeMemberFromGroup(user: UserData, group: GroupData, completionHandler: @escaping (Bool) -> Void) {
        let recordGroup = CKRecord(recordType: "Group", recordID: group.ID)
        
        let recordUser = CKRecord(recordType: "User", recordID: user.ID)
        
        readMembersAdminsInGroup(groupID: group.ID) { members, admins in
            var memberListReference = [CKRecord.Reference]()
            var adminListReference = [CKRecord.Reference]()
            
            for member in members {
                if member.ID != user.ID {
                    memberListReference.append(CKRecord.Reference(recordID: member.ID, action: .none))
                } else {
                    self.removeUserFromAllEvents(user: user, group: group){ success in
//                        if success{
//                            completionHandler(true)
//                        }else{
//                            completionHandler(false)
//                        }
                    }
                }
            }
            
            recordGroup.setValue(memberListReference, forKey: "participants")
            
            for admin in admins {
                if admin.ID != user.ID {
                    adminListReference.append(CKRecord.Reference(recordID: admin.ID, action: .none))
                } else {
                    self.removeUserFromAllEvents(user: user, group: group){ success in
//                        if success{
//                            completionHandler(true)
//                        }else{
//                            completionHandler(false)
//                        }
                    }
                }
            }
            
            recordGroup.setValue(adminListReference, forKey: "admins")
            
            self.readAllUserGroups(userID: user.ID) { groupIDList, _ in
                var referenceList = [CKRecord.Reference]()
                
                for groupID in groupIDList {
                    if groupID != group.ID {
                        referenceList.append(CKRecord.Reference(recordID: groupID, action: .none))
                    }
                }
                
                recordUser.setValue(referenceList, forKey: "groups")
                
                let operation = CKModifyRecordsOperation(recordsToSave: [recordGroup, recordUser])
                
                operation.isAtomic = true
                operation.savePolicy = .changedKeys
                
                
                operation.completionBlock = {
                    
                    if !operation.isCancelled {
                        self.readEventsFromGroup(groupID: group.ID) { (events) in
                            let calendar = Calendar.current
                            var eventsList: [EventData] = []
                            for event in events {
                                let timeToEvent = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date(), to: event.dateTime as Date).second
                                if timeToEvent! > 0 {
                                    eventsList.append(event)
                                    
                                }
                            }
                            if eventsList.isEmpty {
                                completionHandler(true)
                            }
                            for event in eventsList {
                                self.readParticipation(event: event, user: user) { (participation) in
                                    self.publicDB.delete(withRecordID: participation.ID) { (record, error) in
                                        if error != nil {
                                            print(error?.localizedDescription as Any)
                                            completionHandler(false)
                                        }
                                        
                                        if event.ID.recordName == eventsList.last!.ID.recordName {
                                            completionHandler(true)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        completionHandler(false)
                    }
                }
                
                
                self.publicDB.add(operation)
            }
        }
    }

    func editEvent(event: EventData, newPlace: CLLocation? = nil, newDate: NSDate? = nil, newName: String? = nil, completionHandler: @escaping (Bool) -> Void) {
        let recordObject = CKRecord(recordType: "Event", recordID: event.ID)

        if newPlace != nil {
            recordObject.setValue(newPlace, forKey: "place")
        }

        if newDate != nil {
            recordObject.setValue(newDate, forKey: "dateTime")
        }

        if newName != nil {
            recordObject.setValue(newName, forKey: "name")
        }

        let operation = CKModifyRecordsOperation(recordsToSave: [recordObject])

        operation.completionBlock = {
            if !operation.isCancelled {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }

        operation.savePolicy = .changedKeys

        publicDB.add(operation)
    }

    func removeUserFromAllEvents(user: UserData, group: GroupData, completionHandler: @escaping (Bool) -> Void) {
        readEventsFromGroup(groupID: group.ID) { eventList in
            var recordsToModify = [CKRecord]()
            for event in eventList {
                let recordEvent = CKRecord(recordType: "Event", recordID: event.ID)
                var participantListReference = [CKRecord.Reference]()
                var eventAdminListReference = [CKRecord.Reference]()

                for participant in event.participants ?? [] {
                    if participant.ID != user.ID {
                        participantListReference.append(CKRecord.Reference(recordID: participant.ID, action: .none))
                    }
                }

                recordEvent.setValue(participantListReference, forKey: "participants")

                for eventAdmin in event.admins ?? [] {
                    if eventAdmin.ID != user.ID {
                        print("diocane")
                        eventAdminListReference.append(CKRecord.Reference(recordID: eventAdmin.ID, action: .none))
                    }
                }

                recordEvent.setValue(eventAdminListReference, forKey: "admins")

                recordsToModify.append(recordEvent)
                
                let operation = CKModifyRecordsOperation(recordsToSave: recordsToModify)
                    
                    operation.isAtomic = true
                    operation.savePolicy = .changedKeys
                    operation.completionBlock = {
                        if !operation.isCancelled {
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    }

                    self.publicDB.add(operation)
                }
                
            }
            
    }

    func promoteMemberToAdmin(user: UserData, group: GroupData, completionHandler: @escaping (Bool) -> Void) {
        let recordGroup = CKRecord(recordType: "Group", recordID: group.ID)
        let userReference = CKRecord.Reference(recordID: user.ID, action: .none)

        readMembersAdminsInGroup(groupID: group.ID) { members, admins in
            var memberListReference = [CKRecord.Reference]()
            var adminListReference = [CKRecord.Reference]()

            for member in members {
                if member.ID != user.ID {
                    memberListReference.append(CKRecord.Reference(recordID: member.ID, action: .none))
                }
            }

            recordGroup.setValue(memberListReference, forKey: "participants")

            for admin in admins {
                adminListReference.append(CKRecord.Reference(recordID: admin.ID, action: .none))
            }

            adminListReference.append(userReference)
            recordGroup.setValue(adminListReference, forKey: "admins")

            let operation = CKModifyRecordsOperation(recordsToSave: [recordGroup])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            
            self.publicDB.add(operation)
        }
    }

    func degradeAdminToMember(user: UserData, group: GroupData, completionHandler: @escaping (Bool) -> Void) {
        let recordGroup = CKRecord(recordType: "Group", recordID: group.ID)
        let userReference = CKRecord.Reference(recordID: user.ID, action: .none)

        readMembersAdminsInGroup(groupID: group.ID) { members, admins in
            var memberListReference = [CKRecord.Reference]()
            var adminListReference = [CKRecord.Reference]()

            for admin in admins {
                if admin.ID != user.ID {
                    adminListReference.append(CKRecord.Reference(recordID: admin.ID, action: .none))
                }
            }

            recordGroup.setValue(adminListReference, forKey: "admins")

            for member in members {
                memberListReference.append(CKRecord.Reference(recordID: member.ID, action: .none))
            }

            memberListReference.append(userReference)
            recordGroup.setValue(memberListReference, forKey: "participants")

            let operation = CKModifyRecordsOperation(recordsToSave: [recordGroup])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            
            self.publicDB.add(operation)
        }
    }

    func promoteMemberToAdmin(user: UserData, event: EventData, completionHandler: @escaping (Bool) -> Void) {
        let recordEvent = CKRecord(recordType: "Event", recordID: event.ID)
        let userReference = CKRecord.Reference(recordID: user.ID, action: .none)

        readMembersAdminsInEvent(eventID: event.ID) { members, admins in
            var memberListReference = [CKRecord.Reference]()
            var adminListReference = [CKRecord.Reference]()

            for member in members {
                if member.ID != user.ID {
                    memberListReference.append(CKRecord.Reference(recordID: member.ID, action: .none))
                }
            }

            recordEvent.setValue(memberListReference, forKey: "participants")

            for admin in admins {
                adminListReference.append(CKRecord.Reference(recordID: admin.ID, action: .none))
            }

            adminListReference.append(userReference)
            recordEvent.setValue(adminListReference, forKey: "admins")

            let operation = CKModifyRecordsOperation(recordsToSave: [recordEvent])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            
            self.publicDB.add(operation)
        }
    }

    func degradeAdminToMember(user: UserData, event: EventData, completionHandler: @escaping (Bool) -> Void) {
        let recordEvent = CKRecord(recordType: "Event", recordID: event.ID)
        let userReference = CKRecord.Reference(recordID: user.ID, action: .none)

        readMembersAdminsInEvent(eventID: event.ID) { members, admins in
            var memberListReference = [CKRecord.Reference]()
            var adminListReference = [CKRecord.Reference]()

            for admin in admins {
                if admin.ID != user.ID {
                    adminListReference.append(CKRecord.Reference(recordID: admin.ID, action: .none))
                }
            }

            recordEvent.setValue(adminListReference, forKey: "admins")

            for member in members {
                memberListReference.append(CKRecord.Reference(recordID: member.ID, action: .none))
            }

            memberListReference.append(userReference)
            recordEvent.setValue(memberListReference, forKey: "participants")

            let operation = CKModifyRecordsOperation(recordsToSave: [recordEvent])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            
            self.publicDB.add(operation)
        }
    }

    func addFriend(friend: UserData, completionHandler: @escaping (Bool) -> Void) {
        CloudDBController.shared.readFriendsList(user: UserManager.shared.userInfo) { friends in
            let record = CKRecord(recordType: "Friends", recordID: friends!.ID)
//            record.setValue(UserManager.shared.userInfo.ID, forKey: "user")
            var temp: [CKRecord.Reference] = []
            for contact in friends!.contacts {
                temp.append(CKRecord.Reference(recordID: contact.ID, action: .none))
            }
            temp.append(CKRecord.Reference(recordID: friend.ID, action: .none))
            record.setValue(temp, forKey: "contacts")

            let operation = CKModifyRecordsOperation(recordsToSave: [record])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            self.publicDB.add(operation)
        }
    }

    func removeFriend(friend: UserData, completionHandler: @escaping (Bool) -> Void) {
        CloudDBController.shared.readFriendsList(user: UserManager.shared.userInfo) { friends in
            let record = CKRecord(recordType: "Friends", recordID: friends!.ID)
//            record.setValue(UserManager.shared.userInfo.ID, forKey: "user")
            var temp: [CKRecord.Reference] = []
            for contact in friends!.contacts {
                if contact.ID != friend.ID {
                    temp.append(CKRecord.Reference(recordID: contact.ID, action: .none))
                }
            }
            record.setValue(temp, forKey: "contacts")

            let operation = CKModifyRecordsOperation(recordsToSave: [record])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            
            self.publicDB.add(operation)
        }
    }

    func updateUser(user: UserData, username: String? = nil, score: Int? = nil, avatarID: Int? = nil, group: GroupData? = nil, completionHandler: @escaping (Bool) -> Void) {
        
        let record = CKRecord(recordType: "User", recordID: user.ID)
        record.setValue(avatarID ?? user.avatarID, forKey: "avatarID")
        record.setValue(score ?? user.score, forKey: "score")
        record.setValue(username ?? user.username, forKey: "username")
        record.setValue(user.name, forKey: "name")
        record.setValue(user.surname, forKey: "surname")

        CloudDBController.shared.readAllUserGroups(userID: user.ID) { groups, _ in
            var temp: [CKRecord.Reference] = []
            for group in groups {
                temp.append(CKRecord.Reference(recordID: group, action: .none))
            }
            if group != nil {
                temp.append(CKRecord.Reference(recordID: group!.ID, action: .none))
            }
            record.setValue(temp, forKey: "groups")

            let operation = CKModifyRecordsOperation(recordsToSave: [record])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                if !operation.isCancelled {
                    NSLog("finito")
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
            
            self.publicDB.add(operation)
        }
    }

    func updateGroup(name: String? = nil, picID: Int? = nil, group: GroupData, event: EventData? = nil, completionHandler: @escaping (Bool) -> Void) {
        var list = [CKRecord.Reference]()
        let record = CKRecord(recordType: "Group", recordID: group.ID)

        record.setValue(name ?? group.name, forKey: "name")

        record.setValue(picID ?? group.picID, forKey: "picID")

        if event != nil {
            let eventReference = CKRecord.Reference(recordID: event!.ID, action: .none)
            readEventsReferenceFromGroup(groupID: group.ID) { eventlist, isFinished in
                if isFinished == true {
                    list = eventlist
                    list.append(eventReference)
                    record.setValue(list, forKey: "events")
                    let operation = CKModifyRecordsOperation(recordsToSave: [record])

                    operation.savePolicy = .changedKeys

                    operation.completionBlock = {
                        completionHandler(true)
                    }

                    self.publicDB.add(operation)
                }
            }
        } else {
            let operation = CKModifyRecordsOperation(recordsToSave: [record])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                completionHandler(true)
            }

            publicDB.add(operation)
        }
    }
    
    func updateParticipation(event: EventData, completionHandler: @escaping (Bool) -> Void){
        CloudDBController.shared.readParticipation(event: event) { (participation) in
            let record = CKRecord(recordType: "Participation", recordID: participation.ID)
            
            let calendar = Calendar.current
            let eventDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: event.dateTime as Date)
            let nowDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: NSDate() as Date)
            
            var delay = calendar.dateComponents([.minute], from: eventDateComponents, to: nowDateComponents).minute!
            if delay < 0 {
                delay = 0
            }
            record.setValue(delay, forKey: "delay")
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record])

            operation.savePolicy = .changedKeys

            operation.completionBlock = {
                completionHandler(true)
            }

            self.publicDB.add(operation)
        }
    }

    // MARK: - DELETE

//    func deleteMemberAdminFromGroup(userID: CKRecord.ID, groupID: CKRecord.ID, completionHandler: @escaping (Bool) -> Void) {
//    }
    
    func testSubscription(completionHandler: @escaping () -> Void){
        let predicateY = NSPredicate(format: "recordID = %@", UserManager.shared.userInfo.ID)
        
        let subID = String(NSUUID().uuidString)
        
        let info = CKSubscription.NotificationInfo()
        
        info.shouldSendContentAvailable = true
        
        
        
        info.alertBody = "Alert"
        
        
        let option1 = CKQuerySubscription.Options.firesOnRecordUpdate
        
        let option2 = CKQuerySubscription.Options.firesOnRecordDeletion
        
        
        let sub2 = CKQuerySubscription(recordType: "User", predicate: predicateY, subscriptionID: subID, options: [option1, option2])
        
        sub2.notificationInfo = info
        
        publicDB.save(sub2) { (ckSUb, error) in
            if error == nil{
                print("Subscription saved successfully")
            }
            else{
                print("An error occurred while saving subscription")
                print(error?.localizedDescription as Any)
            }
            completionHandler()
        }
    
    }
    
    
//    func removeSubscription(completionHandler: @escaping () -> Void){
//        
//        let operation = CKModifySubscriptionsOperation(subscriptionIDsToDelete: <#T##[CKSubscription.ID]?#>)
//    }
    
    
}

protocol CloudControllerDelegate {
    func errorUpdating(error: NSError)
    func modelUpdated()
}

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}

extension Int {
    var boolValue: Bool {
        return self != 0
    }
}
