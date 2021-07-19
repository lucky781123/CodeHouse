//
//  SafeArray.swift
//  SwiftSafeArray
//
//  Created by hui liu on 2019/3/6.
//  Copyright © 2019 lh. All rights reserved.
//

import Foundation

// A thread-safe array.
public class SafeArray<Element>  {
    fileprivate let queue = DispatchQueue(label: "Com.Edison.SafeArray", attributes: .concurrent)
    fileprivate var array = [Element]()

    public init(){
    }
    public init(_ array:[Element]){
        self.array = array
    }
}

// MARK: - Properties
public extension SafeArray {
    
    var first: Element? {
        var result: Element?
        queue.sync { result = self.array.first }
        return result
    }
    
    var last: Element? {
        var result: Element?
        queue.sync { result = self.array.last }
        return result
    }
    
    var startIndex: Int {
        var index: Int = 0
        queue.sync { index = self.array.startIndex }
        return index
    }
    
    var endIndex: Int {
        var index: Int = 0
        queue.sync { index = self.array.endIndex }
        return index
    }
    
    var count: Int {
        var result = 0
        queue.sync { result = self.array.count }
        return result
    }
    
    var isEmpty: Bool {
        var result = false
        queue.sync { result = self.array.isEmpty }
        return result
    }
    
    var description: String {
        var result = ""
        queue.sync { result = self.array.description }
        return result
    }
}

// MARK: - Read operation
public extension SafeArray {
    func first(where predicate: (Element) -> Bool) -> Element? {
        var result: Element?
        queue.sync { result = self.array.first(where: predicate) }
        return result
    }
        
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array.filter(isIncluded) }
        return result
    }
    
    func getAll() -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array }
        return result
    }
    
    func index(where predicate: (Element) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.firstIndex(where: predicate) }
        return result
    }
    
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        var result = [Element]()
        queue.sync { result = self.array.sorted(by: areInIncreasingOrder) }
        return result
    }
        
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T]{
        var results = [T]()
        try queue.sync {
            results = try self.array.map(transform)
        }
        return results
    }
    
    func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult]{
        var result = [ElementOfResult]()
        try queue.sync { result = try self.array.compactMap(transform) }
        return result
    }
    
    func forEach(_ body: (Element) -> Void) {
        queue.sync { self.array.forEach(body) }
    }
    
    func contains(where predicate: (Element) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(where: predicate) }
        return result
    }
}

// MARK: - Write operation
public extension SafeArray {
    
    func append( _ element: Element) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    func append( _ elements: [Element]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    func insert( _ element: Element, at index: Int) {
        queue.async(flags: .barrier) {
            self.array.insert(element, at: index)
        }
    }
    
    func remove(at index: Int, completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    func remove(where predicate: @escaping (Element) -> Bool, completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            guard let index = self.array.firstIndex(where: predicate) else { return }
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    func removeAll(completion: (([Element]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            
            DispatchQueue.main.async {
                completion?(elements)
            }
        }
    }
    
    func removeFirst(completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: 0)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    func removeLast(completion: ((Element) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let element = self.array.remove(at: self.array.count-1)
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }

    static func += (left: inout SafeArray, right: Element) {
        left.append(right)
    }
    
}

// MARK: - Subscript
public extension SafeArray {
    
    subscript(index: Int) -> Element? {
        get {
            var result: Element?
            
            queue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                result = self.array[index]
            }
            
            return result
        }
        set {
            guard let newValue = newValue else { return }
            
            queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
}

// MARK: - Equatable
public extension SafeArray where Element: Equatable {
    
    func contains(_ element: Element) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(element) }
        return result
    }
    
    static func == (lhs: SafeArray<Element>, rhs: SafeArray<Element>) -> Bool {
        var result = false
        lhs.queue.sync { result = lhs.array == rhs.array }
        return result
    }
    
    func firstIndex(of element: Element) -> Int? {
        var index:Int?
        queue.sync { index = self.array.firstIndex(of: element ) }
        return index
    }

}

/// surport `for in`
extension SafeArray: Sequence {
    public struct Iterator: IteratorProtocol {
        private var interArray: SafeArray<Element>
        var index : Int
        fileprivate init(_ array: SafeArray<Element>) {
            self.interArray = array
            index = 0
        }
                
        public mutating func next() -> Element? {
            var result: Element?
            interArray.queue.sync {
                if index < interArray.array.count{
                    result = interArray.array[index]
                    index += 1
                }
            }
            return result
        }
/*
        public mutating func next() -> Element? {
            if index >= interArray.count { return nil }
            defer{index += 1}
            return interArray[index]
        }
*/
    }
    public func makeIterator() -> SafeArray<Element>.Iterator {
        return Iterator(self)
    }
}
