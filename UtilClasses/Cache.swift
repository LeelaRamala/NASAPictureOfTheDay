//
//  Cache.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 27/02/22.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(key: key, value: value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
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
            wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        }
}



