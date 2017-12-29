//
//  ViewController.swift
//  ATRequest
//
//  Created by makw@hui10.com on 09/14/2017.
//  Copyright (c) 2017 makw@hui10.com. All rights reserved.
//

import UIKit
import ATRequest
import Alamofire

class ViewController: UIViewController {

    var request = ARequest()
//    var request = BRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RequestConfig.timeoutInterval = 5.0
        RequestConfig.bindResponseHandler { (url, response, cache, result) -> (NSError?, Bool, Any?) in
            
            guard let dict = result as? [String : Any],
                let objs = dict["subjects"] else {
                    return (nil,cache,nil)
            }
            return (nil,cache,objs)
//            URLCache
        }
        
        RequestConfig.parameters { (dict) in
            dict.updateValue("kevin", forKey: "name")
        }
//        self.request!.requestDelegate = self
        self.request.requestWithSuccess({ (object, cache) in
            for model in object ?? [] {
                print(model.rating?.average ?? "")
            }
        }) { (e) in

        }
    }
}

extension ViewController : RequestDelegate {
    func request<Request>(_ request: Request, didFinishRequestWithObject object: Any?, fromCache: Bool) where Request : ATRequestType {
        self.view.backgroundColor = UIColor.red
    }
    
    func request<Request>(_ request: Request, didFailedRequestWithError error: Error) where Request : ATRequestType {
        self.view.backgroundColor = UIColor.blue
    }
}

