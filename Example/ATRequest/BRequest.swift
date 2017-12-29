//
//  BRequest.swift
//  ATRequest_Example
//
//  Created by 凯文马 on 2017/11/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import ATRequest

class BRequest: ATRequest<RawResponseData> {
    override var requestUrl: String {
        return "https://httpbin.org/get"
    }
    
    override var requestParameters: [String : Any]? {
        return nil
    }
    
    override var requestMethod: ATRequestMethod {
        return .post
    }
    
    override var contentType: [String] {
        return ["text/html"]
    }

}
