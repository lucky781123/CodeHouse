//
//  SafeDictionary.swift
//  
//
//  Created by hui liu on 2019/3/6.
//  Copyright © 2019 lh. All rights reserved.
//

import Foundation


//MARK: dictionary that allows thread-safe concurrent access
final class SafeDictionary<KeyType:Hashable,ValueType> : NSObject, ExpressibleByDictionaryLiteral { //, Sequence
    private var internalDictionary : [KeyType:ValueType]
    
    //MARK: queue modfications using a barrier and allow concurrent read operations
    private let queue = DispatchQueue(label: "Com.Edison.SafeDictionary", attributes: .concurrent)
    
    //MARK: count of key-value pairs in this dicitionary
    var count : Int {
        var count = 0
        self.queue.sync() { () -> Void in
            count = self.internalDictionary.count
        }
        return count
    }
    
    //MARK: safely get or set a copy of the internal dictionary value
    var dictionary : [KeyType:ValueType] {
        get {
            var dictionaryCopy : [KeyType:ValueType]?
            self.queue.sync() { () -> Void in
                dictionaryCopy = self.internalDictionary
            }
            return dictionaryCopy ?? [:]
        }
        
        set {
            let dictionaryCopy = newValue // create a local copy on the current thread
            self.queue.async() { () -> Void in
                self.internalDictionary = dictionaryCopy
            }
        }
    }
    
    //MARK: initialize an empty dictionary
    override convenience init() {
        self.init( [KeyType:ValueType]() )
    }
    
    //MARK: allow a concurrent dictionary to be initialized using a dictionary literal of form: [key1:value1, key2:value2, ...]
    convenience required init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        var dictionary = Dictionary<KeyType,ValueType>()
        
        for (key,value) in elements {
            dictionary[key] = value
        }
        
        self.init(dictionary)
    }
    
    //MARK: initialize a thread-safe dictionary from a copy of a standard dictionary
    init( _ dictionary: [KeyType:ValueType] ) {
        self.internalDictionary = dictionary
    }
    
    //MARK: subscript accessors
    subscript(key: KeyType) -> ValueType? {
        get {
            var value : ValueType?
            self.queue.sync() { () -> Void in
                value = self.internalDictionary[key]
            }
            return value
        }
        
        set {
            self.setValue(value:newValue, forKey: key  )
        }
    }

    //MARK: get the dictionary keys
    func  getAllKeys() -> Dictionary<Key, Value>.Keys?{
        var keys: Dictionary<Key, Value>.Keys? = nil
        self.queue.sync() { () -> Void in
            keys = self.internalDictionary.keys
        }
        return keys
    }
    
    //MARK: get the dictionary keys
    func  getAllValues() -> Dictionary<Key, Value>.Values?{
        var values: Dictionary<Key, Value>.Values? = nil
        self.queue.sync() { () -> Void in
            values = self.internalDictionary.values
        }
        return values
    }

    //MARK: assign the specified value to the specified key
    func setValue(value: ValueType?, forKey key: KeyType) {
        self.queue.async(flags: .barrier){
            self.internalDictionary[key] = value
        }
    }
    
    //MARK: remove the value associated with the specified key and return its value if any
    @discardableResult
    func removeValue(forKey key: KeyType) -> ValueType? {
        var oldValue : ValueType? = nil
        self.queue.async(flags: .barrier){
            oldValue = self.internalDictionary.removeValue(forKey:key)
        }
        return oldValue
    }
    
    //MARK: remove all values and keys
    func removeAll(){
        self.queue.async(flags: .barrier){
            self.internalDictionary.removeAll()
        }
    }

}

/// surport `for in`
extension SafeDictionary: Sequence {
    public struct Iterator: IteratorProtocol {
        private var interDic : SafeDictionary<KeyType,ValueType>
        var iterator:Dictionary<KeyType,ValueType>.Iterator
        fileprivate init(_ dic: SafeDictionary<KeyType,ValueType>) {
            self.interDic = dic
            self.iterator = self.interDic.internalDictionary.makeIterator()
        }
                
        public mutating func next() -> (key: KeyType ,value: ValueType)? {
            var result:(key: KeyType ,value: ValueType)?
            self.interDic.queue.sync() { () -> Void in
                result = self.iterator.next()
            }
            return result
        }
    }
    
    public func makeIterator() -> SafeDictionary<KeyType,ValueType>.Iterator {
        return Iterator(self)
    }
}
