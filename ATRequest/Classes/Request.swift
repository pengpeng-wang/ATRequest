//
//  Request.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/15.
//
//

import UIKit
import Alamofire
import ObjectMapper
import YYCache

public typealias ATRequestManager = SessionManager
open class Default {}

open class Default : BaseMappable {
    public func mapping(map: Map) {
        
    }
}

open class BaseRequest<T:EnableMap>: ATRequest {

    public init() { }

    open var requestUrl: String {return "" }
    
    open var requestMethod: ATRequestMethod { return .post }
    
    open var requestParameters: [String : Any]? { return nil }
    
    open var requestHeaders: [String : String]? { return nil }
    
    open var requestUseDefaultParameters : Bool { return true }
    
    open var requestUseDefaultHeaders : Bool { return true }
    
    open var requestBaseUrlIndex : Int { return 0 }
    
    open var requestDelegate: RequestDelegate?
    
    open var cacheMode: CacheMode { return .noneCache }
    
    fileprivate var cacheKey : String = ""
    
    public func requestWithSuccess(_ success:@escaping (Any?,Bool) -> Void,failure:@escaping (NSError)->Void) {
        self.success = success
        self.failure = failure
        self.request()
    }
    
    public func request() {
        let header = getHeaders()
        let parameter = getParameters()
        let url = self.getUrl()!
        
        var useCache = false
        var stop = false
        switch self.cacheMode {
        case .noneCache: break
        case .alwaysRequest(cacheInterval:  _):
            useCache = true
            stop = false
            break
        case .cacheNoRequest(cacheInterval:  _):
            useCache = true
            stop = true
            break
        }
        
        if useCache {
            self.createCacheKey(url: url, param: parameter, header: header)
            let data = self.cacheData()
            if data != nil {
                let resultObj = self.convertClass(data: data)
                self.success?(resultObj as Any,true)
                self.requestDelegate?.request(self, didFinishRequestWithObject:resultObj, fromCache: true)
            }
            if stop { return }
        }
        
        let manager = RequestConfig.requestManager
        manager.request(url, method: self.requestMethod.convert(), parameters: parameter, encoding: JSONEncoding.default, headers: header).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            print(response)
            if response.response != nil {
                let result = RequestConfig.responseHandler(url,response.response,false,response.result.value)
                if result.error == nil {
                    let data = result.data
                    self.saveCache(data: data)
                    let resultObj = self.convertClass(data: data)
                    self.success?(resultObj as Any,result.cache)
                    self.requestDelegate?.request(self, didFinishRequestWithObject:resultObj, fromCache: result.cache)
                } else {
                    self.failure?(result.error!)
                    self.requestDelegate?.request(self, didFailedRequestWithError: result.error!)
                }
            } else {
                let e = NSError.noResponseError()
                self.failure?(e)
                self.requestDelegate?.request(self, didFailedRequestWithError: e)
            }
        }
    }
    
    // MARK : - private
    private var success : ((Any?,Bool) -> Void)?
    
    private var failure : ((NSError) -> Void)?
    
    private func convertClass(data:Any?) -> Any? {
        if data == nil { return nil }
        if T.self ==  Default.self {return data}
        if data is [Any] {
            let datas = data as! [Any]
            return Mapper<T>().mapArray(JSONObject: datas)
        } else if data is [String : Any] {
            return Mapper<T>().map(JSONObject: data!)
        }
        return nil
    }
    
    private func getParameters() -> [String:Any]? {
        if self.requestUseDefaultParameters {
            var dict : [String:Any] = [:]
            RequestConfig.parameters(&dict)
            if self.requestParameters != nil {
                dict <- self.requestParameters!
            }
            return dict
        }
        return self.requestParameters
    }
    
    private func getHeaders() -> [String:String]? {
        if self.requestUseDefaultHeaders {
            var dict : [String:String] = [:]
            RequestConfig.headers(&dict)
            if self.requestHeaders != nil {
                dict <- self.requestHeaders!
            }
            return dict
        }
        return self.requestHeaders
    }
    
    private func getUrl() -> String? {
        let url = self.requestUrl
        if url.hasPrefix("http://") || url.hasPrefix("https://") { return url }
        guard let urls = RequestConfig.baseUrls,
            self.requestBaseUrlIndex < urls.count else {
                return url
        }
        return urls[self.requestBaseUrlIndex] + url
    }
}

extension BaseRequest {
    func createCacheKey(url:String,param:[String:Any]?,header:[String:String]?) {
        var p = param?.sorted { (a, b) -> Bool in
            return a.key > b.key
        }
        var h = header?.sorted { (a, b) -> Bool in
            return a.key > b.key
        }
        p = p ?? [("","")]
        h = h ?? [("","")]
        
        var ps = "|"
        for (k,y) in p! {
            ps += "\(k):\(y)"
        }
        var hs = "|"
        for (k,y) in h! {
            hs += "\(k):\(y)"
        }
        self.cacheKey = url + ps + hs
    }
    
    func cacheData() -> Any? {
        let cache = YYCache.init(name: "ATRequest")
        guard let cacheModel = cache?.object(forKey: self.cacheKey) as? CacheModel,
        cacheModel.finishTime > NSDate().timeIntervalSince1970 else {
            return nil
        }
        return cacheModel.data
    }
    
    func saveCache(data : Any?) -> Void {
        if data == nil { return }

        var cacheTime = 0.0
        var useCache = false
        switch self.cacheMode {
        case .noneCache: break
        case .alwaysRequest(cacheInterval: let time):
            cacheTime = time
            useCache = true
            break
        case .cacheNoRequest(cacheInterval: let time):
            cacheTime = time
            useCache = true
            break
        }
        
        if useCache {
            let cacheModel = CacheModel.init(key: self.cacheKey, finishTime: NSDate().timeIntervalSince1970 + cacheTime, data: data!)
            let cache = YYCache.init(name: "ATRequest")
            cache?.setObject(cacheModel, forKey: self.cacheKey)
        }
    }
}
