//
//  Friend.swift
//  MacroApp
//
//  Created by Roberto Scarpati on 29/04/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation
import CloudKit

struct Friends {
    var ID: CKRecord.ID
    var contacts: [UserData]
}
