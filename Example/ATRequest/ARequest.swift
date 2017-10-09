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

class ARequest : BaseRequest<TestModel> {

    override var requestUrl: String {
        return "https://p.webdev.hui10.com/api/app/list"
    }
    
    override var requestParameters: [String : Any]? {
        return ["platform":"android"]
    }
    
    override var requestMethod: ATRequestMethod {
        return .post
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
