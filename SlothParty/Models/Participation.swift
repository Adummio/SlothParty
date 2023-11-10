//
//  Participation.swift
//  MacroApp
//
//  Created by Massimo Maddaluno on 01/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation
import CloudKit

enum ParticipationType: Int{
    case notSeen = 0
    case confirmed = 1
    case denied = 2
}

struct Participation{
    var ID: CKRecord.ID
    var accepted: ParticipationType
    var delay: Int = 1000
    var event: EventData
    var user: UserData?
}
