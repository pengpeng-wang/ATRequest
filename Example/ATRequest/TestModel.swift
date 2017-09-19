//
//  TestModel.swift
//  ATRequest
//
//  Created by 凯文马 on 2017/9/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import ATRequest
import ObjectMapper

public enum Status : Int{
    case NOOK = 0
    case OK = 1
    case HAHA = 2
}

class TestModel: Model {

    var build : Int = 0
    
    var icon : String?
    
    var id : Int64 = 0
    
    var name : String?
    
    var status : Status = .OK
    
    var update_time : Int = 0
    
    var version : String?
    
    
    override func valueMap(_ map:M) {
        build <- map["build"]
        icon <- map["icon"]
        id <- map["id"]
        name <- map["name"]
        status <- map["status"]
        update_time <- map["update_time"]
        version <- map["version"]
    }
}
