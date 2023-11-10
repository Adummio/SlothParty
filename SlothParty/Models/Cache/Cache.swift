//
//  Cache.swift
//  SlothParty
//
//  Created by Yuri Spaziani on 14/05/2020.
//  Copyright © 2020 Massimo Maddaluno. All rights reserved.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    private var isDirectory: ObjCBool = false

    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 7 * 24 * 60 * 60,
         maximumEntryCount: Int = 2000) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.totalCostLimit = 0
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        return entry.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
        keyTracker.keys.remove(key)
    }
    
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}


extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
    
    func loadCache(withName name: String, using fileManager: FileManager = .default) -> Cache{
        
        let fileURL = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
            )[0].appendingPathComponent(name + ".cache")
        
        var cache = Cache<Key, Value>()
        
        do{
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let decoder: JSONDecoder = JSONDecoder.init()
            cache = try decoder.decode(Cache<Key,Value>.self, from: data)
        }catch{
            checkJsonExists(atPath: fileURL.path)
        }
        return cache
    }
    
    private func checkJsonExists(atPath filePath: String){
        if !FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
        {
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
    }
    
    func getAllValues() -> [Value]{
        
        var values = [Value]()
        
        for key in keyTracker.keys{
            let value = self.value(forKey: key)
            if value != nil{
                values.append(value!)
            }
        }
        return values
    }
    
    func emptyCache(){
        for key in keyTracker.keys{
            self.removeValue(forKey: key)
        }
    }
    
    func saveToDisk(withName name: String, using fileManager: FileManager = .default) throws {
        
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
}
