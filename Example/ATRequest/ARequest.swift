//
//  ARequest.swift
//  ATRequest
//
//  Created by 凯文马 on 2017/9/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import ATRequest

class ARequest : ATRequest<[TestModel]> {

    override var requestUrl: String {
        return "https://api.douban.com/v2/movie/top250"
    }
    
    override var requestParameters: [String : Any]? {
//        return ["count":11]
        return nil
//                return ["duration" : "week"]
    }
    
    override var requestMethod: ATRequestMethod {
        return .get
    }
    
    override var cachePolicy: CachePolicy {
        return .unuse
//        return .cacheElseLoad(cacheInterval: nil)
//        return .cacheNoRequest(cacheInterval: 3600 * 24)
    }
    
    override var formData: [FormDataType]? {
        let string = "2"
        let data = string.data(using: .utf8)
        return [FormData.init(data: data!, name: "count", filename: nil, mimetype: nil)]
    }
}
