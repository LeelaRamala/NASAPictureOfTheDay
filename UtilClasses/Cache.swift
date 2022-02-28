//
//  Cache.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 27/02/22.
//

import Foundation

/*
 Cache class to store the data in memory for persistent storage
 which can be retained across multiple launches.
 
 */
final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let tracker = KeyTracker()
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(key: key, value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        tracker.keys.insert(key)
    }
    
    func remove(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    func valueForKey(_ key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }
    
    subscript(key: Key) -> Value? {
        get { return valueForKey(key) }
        set {
            guard let value = newValue else {
                remove(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}

extension Cache {
    final class WrappedKey: NSObject {
        var key: Key
        init(_ key: Key) {
            self.key = key
        }
        
        override var hash: Int {
            return key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let anotherObject = object as? WrappedKey else {
                return false
            }
            
            return anotherObject.key == key
        }
    }
}

extension Cache {
    final class Entry {
        let value: Value
        let key: Key

        
        init(key: Key, value: Value) {
            self.value = value
            self.key = key
        }
    }
    
    func entry(forKey key: Key) -> Entry? {
            guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
                return nil
            }

            return entry
    }

        func insert(_ entry: Entry) {
            tracker.keys.insert(entry.key)
            wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        }
}

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
extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(tracker.keys.compactMap(entry))
    }
    
    func isDataCached(forFileName name: String) -> Bool {
        let filePaths = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        guard let fileURL = filePaths.first?.appendingPathComponent(name + ".cache").path else {
            return false
        }
        
       return FileManager.default.fileExists(atPath: fileURL)
    }
    
    func saveToDisk(
            withName name: String,
            using fileManager: FileManager = .default
        ) throws {
            let filePaths = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            )

            do {
                let data = try JSONEncoder().encode(self)
                if let fileURL = filePaths.first?.appendingPathComponent(name + ".cache") {
                    try data.write(to: fileURL)
                }
            } catch {
                print(error)
            }
        }
    
    func fetchData(withName name: String) throws -> Cache? {
        let filePaths = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        
        if let fileURL = filePaths.first?.appendingPathComponent(name + ".cache") {
            guard let data = FileManager.default.contents(atPath: fileURL.path) else {
                return nil
            }
            
            let cacheData = try JSONDecoder().decode(Cache.self, from: data)
            return cacheData
        }
        
        return nil
    }
}

