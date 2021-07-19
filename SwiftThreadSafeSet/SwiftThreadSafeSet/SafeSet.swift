//
//  SafeSet.swift
//  Email
//
//  Created by hui liu on 2020/8/10.
//  Copyright © 2020 Easilydo. All rights reserved.
//

import Foundation

final class SafeSet<Element:Hashable>{
    private var internalSet = Set<Element>()
    private var lock = os_unfair_lock()
    
    public init(){
    }
    
    public init( set: Set<Element>) {
        internalSet = set
    }

    var count: Int{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.count
    }
    
    var isEmpty: Bool{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.isEmpty
    }
    
    /// The first element of the collection.
    var first: Element? {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.first
    }
    
    /// Returns a Boolean value that indicates whether the given element exists
    /// in the set.
    public func contains(_ member: Element) -> Bool {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.contains(member)
    }
    
    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    public func forEach(_ body: (Element) -> Void){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.forEach(body)

    }
    
    /// Inserts the given element in the set if it is not already present.
    public func insert(_ member: Element){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        self.internalSet.insert(member)
    }
    
    /// Removes the specified element from the set.
    @discardableResult
    public func remove(_ member: Element) -> Element? {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.remove(member)
    }
    
    /// Removes the first element of the set.
    @discardableResult
    public func removeFirst() -> Element?{
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        if !internalSet.isEmpty{
            return internalSet.removeFirst()
        }
        return nil
    }
    
    /// Removes all members from the set.
    public func removeAll(){
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        internalSet.removeAll()
    }

    /// Returns a Boolean value that indicates whether the set is a subset of the
    /// given sequence.
    public func isSubset<S : Sequence>(of sequence: S) -> Bool where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.isSubset(of: sequence)
    }

    /// Returns a Boolean value that indicates whether the set is a strict subset
    /// of the given sequence.
    public func isStrictSubset<S : Sequence>(of sequence: S) -> Bool where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.isStrictSubset(of: sequence)

    }

    /// Returns a Boolean value that indicates whether the set is a superset of
    /// the given sequence.
    public func isSuperset<S : Sequence>(of sequence: S) -> Bool where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.isSuperset(of: sequence)

    }

    /// Returns a Boolean value that indicates whether the set is a strict
    /// superset of the given sequence.
    public func isStrictSuperset<S : Sequence>(of sequence: S) -> Bool where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.isStrictSuperset(of: sequence)
    }

    /// Returns a Boolean value that indicates whether the set has no members in
    /// common with the given sequence.
    public func isDisjoint<S : Sequence>(with sequence: S) -> Bool where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.isDisjoint(with: sequence)
    }

    /// Returns a new set with the elements of both this set and the given
    /// sequence.
    public func union<S : Sequence>(_ sequence: S) -> Set<Element> where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.union(sequence)
    }
    
    /// Inserts the elements of the given sequence into the set.
    public func formUnion<S : Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.formUnion(sequence)
    }

    /// Returns a new set containing the elements of this set that do not occur
    /// in the given sequence.
    public func subtracting<S : Sequence>(_ sequence: S) -> Set<Element> where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.subtracting(sequence)
    }

    /// Removes the elements of the given sequence from the set.
    public func subtract<S : Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        internalSet.subtract(sequence)
    }
    
    /// Returns a new set with the elements that are common to both this set and
    /// the given sequence.
    public func intersection<S : Sequence>(_ sequence: S) -> Set<Element> where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.intersection(sequence)
    }
    
    /// Removes the elements of the set that aren't also in the given sequence.
    public func formIntersection<S : Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        internalSet.formIntersection(sequence)
    }

    /// Returns a new set with the elements that are either in this set or in the
    /// given sequence, but not in both.
    public func symmetricDifference<S : Sequence>(_ sequence: S) -> Set<Element> where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return internalSet.symmetricDifference(sequence)
    }

    /// Replace this set with the elements contained in this set or the given
    /// set, but not both.
    public func formSymmetricDifference<S : Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        internalSet.formSymmetricDifference(sequence)
    }
    
}

/// surport `for in`
extension SafeSet: Sequence {
    public struct Iterator: IteratorProtocol {
        private var interSet : SafeSet<Element>
        var iterator:Set<Element>.Iterator
        fileprivate init(_ set: SafeSet<Element>) {
            self.interSet = set
            self.iterator = self.interSet.internalSet.makeIterator()
        }
                
        public mutating func next() -> Element? {
            os_unfair_lock_lock(&self.interSet.lock)
            defer { os_unfair_lock_unlock(&self.interSet.lock) }
            return self.iterator.next()
        }
    }
    
    public func makeIterator() -> SafeSet<Element>.Iterator {
        return Iterator(self)
    }
}


