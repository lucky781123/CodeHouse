//
//  EdoReusableQueue.swift
//  Email
//
//  Created by hui liu on 2021/3/9.
//  Copyright © 2021 Easilydo. All rights reserved.
//

import Foundation
import UIKit

class WrapperData : Equatable{
    var identifier = ""
    var groupId = ""
    var data:AnyObject
    init(_ data:AnyObject , identifier:String? = nil, groupId:String) {
        self.data = data
        self.identifier = getIdentifier(identifier)
        self.groupId = groupId
    }
    
    func getIdentifier(_ identifier:String? = nil) -> String{
        if let identifier = identifier {
            return identifier
        }
        return "\(type(of: data))"
    }
    
    public static func ==(lhs: WrapperData, rhs: WrapperData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    private func identifierFromClass(_ classType: AnyObject.Type) -> String {
        return  "\(classType)"
    }
    
    static func getIdentifier(_ identifier:String? = nil, data:AnyObject) -> String{
        if let identifier = identifier {
            return identifier
        }
        return "\(type(of: data))"
    }
    
}

class EdoReuseQueue {
    static let sharedInst = EdoReuseQueue()
    var reuseQueue = FastSafeNSDictionary() //key is identifier, value is a FastSafeNSArray
    
    private init () {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func dequeueReusable(_ identifier:String) -> AnyObject? {
        var reuseCell:WrapperData?
        if let reusableCells = self.reuseQueue[identifier] as? FastSafeNSArray {
            for cell in reusableCells.reversed() {
                if let cell = cell as? WrapperData{
                    reuseCell = cell
                    reusableCells.remove(cell)
                    break
                }
            }
        }
        return reuseCell?.data
    }

    func addReusableQueue(_ data:AnyObject, identifier:String, groupId:String) {
        let newCell = WrapperData(data, identifier: identifier, groupId: groupId)
        addReusableQueueBy(newCell)
    }

    func emptyQueue() {
        for ( _, reuseCells) in reuseQueue {
            if let reuseCells = reuseCells as? FastSafeNSArray {
                reuseCells.removeAll()
            }
        }
        reuseQueue.removeAll()
    }
    
    @objc func didReceiveMemoryWarning() -> Void {
        emptyQueue()
    }
    
    private func addReusableQueueBy(_ cell:WrapperData) {
        if let reusableCells = self.reuseQueue[cell.identifier] as? FastSafeNSArray {
            reusableCells.append(cell)
        } else {
            let reusableCells = FastSafeNSArray()
            reusableCells.append(cell)
            self.reuseQueue[cell.identifier] = reusableCells
        }
    }

}
