//
//  ViewController.swift
//  ATRequest
//
//  Created by makw@hui10.com on 09/14/2017.
//  Copyright (c) 2017 makw@hui10.com. All rights reserved.
//

import UIKit
import ATRequest

class ViewController: UIViewController {

    var request = ARequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        RequestConfig.handleResponse(withAction: { (url, response, cache, result) -> (Error?, Bool, Any) in
//            return (nil,false,[])
//        })
        RequestConfig.timeoutInterval = 5.0
        RequestConfig.bindResponseHandler { (url, response, cache, result) -> (NSError?, Bool, Any?) in
            guard let dict = result as? [String:Any],
                let code : Int = dict["ec"] as? Int,
                let message : String = dict["em"] as? String else {
                    return (NSError.formatError(),false,nil)
            }
            if code != 200 || message != "success" {
                return (NSError.serverError(code: code, message: message),false,nil)
            }
            return (nil,cache,dict["result"])
        }
        
        RequestConfig.parameters { (dict) in
            dict.updateValue("kevin", forKey: "name")
        }
        self.request.requestDelegate = self
        self.request.request()
        
     
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : RequestDelegate {
    func request(_ request: ATRequest, didFinishRequestWithObject object: Any?, fromCache: Bool) {
        print(object!)
        let o = object! as! Array<TestModel>
        let a = o.first
        print(o)
    }
    
    func request(_ request: ATRequest, didFailedRequestWithError error: Error) {
        print(error)
    }
}

