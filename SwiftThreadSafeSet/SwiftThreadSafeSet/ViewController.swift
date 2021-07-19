//
//  ViewController.swift
//  SwiftThreadSafeSet
//
//  Created by 刘辉 on 2021/7/19.
//

import UIKit

class ViewController: UIViewController {
    var safeSet = SafeSet<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        safeSetTest()
    }

    func safeSetTest(){
        for i in 1...10000{
            DispatchQueue(label: "111").async{
                self.safeSet.insert("value-\(i)")
                print(self.safeSet.first ?? "" )
            }
        }

        for j in 1...10000{
            DispatchQueue(label: "222").async{
                self.safeSet.removeFirst()
                let contained = self.safeSet.contains("value-\(j)")
                print("\(contained)")
            }
        }

    }

}

