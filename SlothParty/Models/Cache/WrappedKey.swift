//
//  WrappedKey.swift
//  SlothParty
//
//  Created by Yuri Spaziani on 14/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation

extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
    }
}
