//
//  KeyTracker.swift
//  SlothParty
//
//  Created by Yuri Spaziani on 14/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation

extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            keys.remove(entry.key)
        }
    }
}
