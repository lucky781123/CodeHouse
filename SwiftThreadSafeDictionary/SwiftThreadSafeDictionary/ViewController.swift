//
//  ViewController.swift
//  SwiftThreadSafeDictionary
//
//  Created by 刘辉 on 2021/7/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        safeDictionaryTest()
        //unsafeDictionaryTest2()
    }

    func safeDictionaryTest(){
        let safeDic = SafeDictionary<String, String>()

        DispatchQueue(label:"queue1").async{
            for i in 0..<100000{
                safeDic["key\(i)"] = "value\(i)"
                //safeDic.removeValue(forKey:"key\(i)")
                safeDic.removeAll()
                print("setValue:value:\(i)")
            }
        }
        DispatchQueue(label:"queue2").async{
            for i in 0..<100000{
                safeDic["key\(i)"] = "value\(i)"
                //safeDic.removeValue(forKey:"key\(i)")
                safeDic.removeAll()
                print("setValue2:value:\(i)")
            }
        }
        DispatchQueue(label:"queue3").async{
            for i in 0..<100000{
                safeDic["key\(i)"] = "value\(i)"
                //safeDic.removeValue(forKey:"key\(i)")
                safeDic.removeAll()
                print("setValue3:value:\(i)")
            }
        }
    }

    func unsafeDictionaryTest2(){
        var unsafeDic = Dictionary<String, String>()
        
        DispatchQueue(label:"queue1").async{
            for i in 0..<100000{
                unsafeDic["key\(i)"] = "value\(i)"
                unsafeDic.removeValue(forKey:"key\(i)")
                print("setValue:value:\(i)")
            }
        }
        DispatchQueue(label:"queue2").async{
            for i in 0..<100000{
                unsafeDic["key\(i)"] = "value\(i)"
                unsafeDic.removeValue(forKey:"key\(i)")
                print("setValue:value:\(i)")
            }
        }
        
    }
}

