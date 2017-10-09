//
//  ATRequest.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

public enum CacheMode {
    case noneCache
    case cacheNoRequest(cacheInterval : TimeInterval)
    case alwaysRequest(cacheInterval : TimeInterval)
}

public protocol ATRequest : class {
    
    var requestDelegate : RequestDelegate? {get set}

    var requestUrl: String {get}
    
    var requestMethod: ATRequestMethod {get}
    
    var requestParameters: [String : Any]? {get}
    
    var requestHeaders: [String : String]? {get}
    
    var requestUseDefaultParameters : Bool {get}
    
    var requestUseDefaultHeaders : Bool {get}
    
    var requestBaseUrlIndex : Int {get}
        
    var cacheMode : CacheMode {get}
}

public extension ATRequest {
    
    
}

