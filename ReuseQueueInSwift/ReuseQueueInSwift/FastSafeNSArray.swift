//
//  FastSafeNSArray.swift
//  SwiftSafeArray
//
//  Created by hui liu on 2020/9/18.
//  Copyright © 2020 lh. All rights reserved.
//

//

import Foundation

// A thread-safe NSMutableArray.
public class FastSafeNSArray {
    fileprivate var array = NSMutableArray()
    private var lock = os_unfair_lock()
    
    public init(){
    }
    public init(_ array: NSMutableArray){
        self.array = array
    }
    
    public init(array: [Any]){
        for item in array {
            self.array.add(item)
        }
    }
//
//    func array2NSMutableArray(_ array: [Any]) -> NSMutableArray {
//        let NSMutableArray: NSMutableArray = []
//        for item in array {
//            NSMutableArray.add(item)
//        }
//        return NSMutableArray
//    }
}

// MARK: - Properties
public extension FastSafeNSArray {
    
    var first: Any? {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.firstObject
    }
    
    var last: Any? {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.lastObject
    }

    var count: Int{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.count
    }

    
    var isEmpty: Bool {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.count == 0
    }
    
    var description: String {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.description
    }
}

// MARK: - Read operation
public extension FastSafeNSArray {
    
    func first(where predicate: (Any) throws -> Bool) rethrows -> Any?{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return try array.first(where: predicate)
    }

    func filtered(using predicate: NSPredicate) -> [Any]{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.filtered(using: predicate)
        
    }
    
    func filter(_ isIncluded: (Any) throws -> Bool) rethrows -> [Any]{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        var results = [Any]()
        do{
            results = try array.filter(isIncluded)
        }catch{
            print(error)
        }
        return results
    }
    
    func getAll() -> NSMutableArray {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return self.array
    }
    
    func index(_ anObject: Any) -> Int {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.index(of: anObject)
    }
    
    func index(of obj: Any, inSortedRange r: NSRange, options opts: NSBinarySearchingOptions = [], usingComparator cmp: (Any, Any) -> ComparisonResult) -> Int{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.index(of:obj , inSortedRange: r, options : opts, usingComparator: cmp)
    }
    
    func sort(options opts: NSSortOptions = [], usingComparator cmptr: (Any, Any) -> ComparisonResult) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return array.sort(options: opts, usingComparator: cmptr)
    }
    
    func map<T>(transform: (Any) throws -> T ) rethrows -> [T]{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        var results = [T]()
        do{
            results = try self.array.map(transform)
        }catch{
            print(error)
        }
        return results
    }

    func compactMap<T>(_ transform: (Any) throws -> T?) rethrows -> [T]{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }

        var results = [T]()
        do{
            results = try self.array.compactMap(transform)
        }catch{
            print(error)
        }
        return results
    }
    
    func forEach(_ body: (Any) throws -> Void) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        do{
            try self.array.forEach(body)
        }catch{
            print(error)
        }
    }
    
    func contains(where predicate: (Any) throws -> Bool) rethrows -> Bool{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        
        var result = false
        do{
            result = try array.contains(where: predicate)
        }catch{
            print(error)
        }
        return result
    }

}

// MARK: - Write operation
public extension FastSafeNSArray {
    
    func append(_ anObject: Any){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.add(anObject)
    }
    
    func append(_ otherArray: [Any]){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.addObjects(from: otherArray)
    }
    
    func insert(_ anObject: Any, at index: Int) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.insert(anObject, at: index)
    }
    
    func remove(_ index: Int) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.removeObject(at: index)
    }
    
    func remove(_ anObject: Any){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.remove(anObject)
    }
    
    func remove(_ anObject: Any, in range: NSRange){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.remove(anObject, in: range)
    }
    
    func remove(identicalTo anObject: Any, in range: NSRange){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.removeObject(identicalTo: anObject, in: range)
    }
    
    func removeLast() {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.removeLastObject()
    }
    
    func removeAll() {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        array.removeAllObjects()
    }

    static func += (left: FastSafeNSArray, right: Any) {
        left.array.add(right)
    }
    
}

// MARK: - Subscript
public extension FastSafeNSArray {
    
    subscript(index: Int) -> Any? {
        get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return self.array[index]
        }
        set {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            if let newValue = newValue{
                self.array[index] = newValue
            }
        }
    }
}

// MARK: - Equatable
public extension FastSafeNSArray {

    func contains(_ element: Any) -> Bool {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return self.array.contains(element)
    }

    static func == (lhs: FastSafeNSArray, rhs: FastSafeNSArray ) -> Bool {
        os_unfair_lock_lock(&lhs.lock)
        defer { os_unfair_lock_unlock(&lhs.lock) }
        return lhs.array == rhs.array
    }

}

/// surport `for in`
extension FastSafeNSArray: Sequence {
    public struct Iterator: IteratorProtocol {
        private var interArray: FastSafeNSArray
        var index : Int
        
        fileprivate init(_ array: FastSafeNSArray) {
            self.interArray = array
            index = 0
        }
                
        public mutating func next() -> Any? {
            os_unfair_lock_lock(&interArray.lock)
            defer { os_unfair_lock_unlock(&interArray.lock) }

            var result: Any?
            if index < interArray.array.count{
                result = interArray.array[index]
                index += 1
            }
            return result
        }
    }
    
    public func makeIterator() -> FastSafeNSArray.Iterator {
        return Iterator(self)
    }
}
