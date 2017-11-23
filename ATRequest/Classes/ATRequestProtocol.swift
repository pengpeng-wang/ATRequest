//
//  ATRequest.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

/// 缓存策略
///
/// - unuse: 不使用缓存，不会读取缓存也不会写入缓存
/// - cacheElseLoad: 优先使用缓存数据，如果没有缓存或缓存过期则重新请求
/// - cacheAndLoad: 先返回缓存数据，同时也会请求网络更新数据
/// - cacheDontLoad: 只使用缓存数据，无论是否有缓存数据都不会请求网络
public enum CachePolicy {
    case unuse
    case cacheElseLoad(cacheInterval : TimeInterval?)
    case cacheAndLoad(cacheInterval : TimeInterval?)
    case cacheDontLoad(cacheInterval : TimeInterval?)

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
        
    var cachePolicy : CachePolicy {get}
    
    var contentType : [String] {get}
    
    var formData : [FormData]? {get}
    
    func requestWithSuccess(_ success:@escaping (Any?,Bool) -> Void,failure:@escaping (NSError)->Void)
    
    func request()
}

public extension ATRequest {
    
    
}

