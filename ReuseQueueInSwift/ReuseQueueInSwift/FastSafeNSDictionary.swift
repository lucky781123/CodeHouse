//
//  FastSafeNSDictionary.swift
//  SwiftSafeArray
//
//  Created by huiliu on 2020/9/17.
//  Copyright © 2020 lh. All rights reserved.
//

import Foundation


//MARK: dictionary that allows thread-safe concurrent access
final class FastSafeNSDictionary : NSObject, ExpressibleByDictionaryLiteral {
    private var internalDictionary : NSMutableDictionary
    private var lock = os_unfair_lock()

    //MARK: count of key-value pairs in this dicitionary
    var count: Int{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalDictionary.count
    }
    
    //MARK: safely get or set a copy of the internal dictionary value
    var dictionary : NSMutableDictionary {
        get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return self.internalDictionary
        }

        set {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            self.internalDictionary = newValue
        }
    }

    //MARK: initialize an empty dictionary
    override convenience init() {
        self.init( NSMutableDictionary() )
    }
    
    //MARK: allow a concurrent dictionary to be initialized using a dictionary literal of form: [key1:value1, key2:value2, ...]
    convenience required init(dictionaryLiteral elements: (Any, Any)...) {
        let dictionary = NSMutableDictionary()
        
        for (key,value) in elements {
            dictionary[key] = value
        }
        
        self.init(dictionary)
    }
    
    //MARK: initialize a thread-safe dictionary from a copy of a standard dictionary
    init(_ dictionary: NSMutableDictionary ) {
        self.internalDictionary = dictionary
    }
    
    //MARK: subscript accessors
    subscript(key: Any) -> Any? {
        get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return self.internalDictionary[key]
        }
        
        set {
            self.setValue(value:newValue, forKey: key  )
        }
    }

    //MARK: get the dictionary keys
    func  getAllKeys() -> Any{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return self.internalDictionary.allKeys
    }

    //MARK: get the dictionary keys
    func  getAllValues() -> Any{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return self.internalDictionary.allValues
    }
    //MARK: assign the specified value to the specified key
    func setValue(value: Any?, forKey key: Any) {
        if value == nil { return }
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        self.internalDictionary[key] = value
    }

    //MARK: remove the value associated with the specified key and return its value if any
    @discardableResult
    func removeValue(forKey key: Any) -> Any? {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return self.internalDictionary.removeObject(forKey: key)
    }
    
    //MARK: remove all values and keys
    public func removeAll(){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        self.internalDictionary.removeAllObjects()
    }
    
}

/// surport `for in`
extension FastSafeNSDictionary: Sequence {
    public struct Iterator: IteratorProtocol {
        private var interDic : FastSafeNSDictionary
        var iterator:NSMutableDictionary.Iterator
        fileprivate init(_ dic: FastSafeNSDictionary) {
            self.interDic = dic
            self.iterator = self.interDic.internalDictionary.makeIterator()
        }
                
        public mutating func next() -> (key: Any, value: Any)? {
            os_unfair_lock_lock(&self.interDic.lock)
            defer { os_unfair_lock_unlock(&self.interDic.lock) }
            return self.iterator.next()
        }
    }
    
    public func makeIterator() -> FastSafeNSDictionary.Iterator {
        return Iterator(self)
    }
}

