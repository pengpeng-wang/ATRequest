//
//  ARequest.swift
//  ATRequest
//
//  Created by 凯文马 on 2017/9/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import ATRequest
import ObjectMapper

class ARequest : BaseRequest<Default> {

    override var requestUrl: String {
//        return "https://p.webdev.hui10.com/api/app/list"
                return "http://172.16.3.155:3000/record/list"
    }
    
    override var requestParameters: [String : Any]? {
//        return ["platform":"android"]
                return ["duration" : "week"]
    }
    
    override var requestMethod: ATRequestMethod {
        return .get
    }
    
    override var cacheMode: CacheMode {
        return .noneCache
//        return .cacheNoRequest(cacheInterval: 3600 * 24)
    }
    
    
    func callback(response : Any) {
        print("\(response)")
        let result = response as! [String:Any]
        
        let rData = result["result"]
        
        print(rData!)
//        let resul = Mapper<TestModel>().mapArray(JSONObject: rData)
//        for obj in rData as! Array<Any> {
//            let m = TestModel(map: obj as! Map)
//            debugPrint(m)
//            
//        }
//        print(resul!)
//        rData.map { (obj) in
//        }
        
//        let r = NSArray.yy_modelArray(with: TestModel.self, json: rData!)
//        debugPrint("\(r)")
        
    }
}
