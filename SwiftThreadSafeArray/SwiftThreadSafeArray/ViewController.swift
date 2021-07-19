//
//  ViewController.swift
//  SwiftThreadSafeArray
//
//  Created by 刘辉 on 2021/7/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        safeArrayTest()
    }

    func safeArrayTest(){
        let array = SafeArray<Int>()
        for i in 0..<10000{
            array.append(i)
        }
        DispatchQueue(label:"asyncQueueAdd").async {
            for i in 0..<10000{
                array.append(i)
                print("asyncQueueAdd:\(i)")
            }
        }
        DispatchQueue(label:"asyncQueueRemove").async {
            for j in (0..<100000) {
                array.removeLast()
                print("asyncQueueRemove:\(j)")
            }
        }
    }

}

