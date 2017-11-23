//
//  Request.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/15.
//
//

import UIKit
import Alamofire
import YYCache
import HandyJSON

public typealias ATRequestManager = SessionManager

open class BaseRequest<T:ResponseModel>: ATRequest {
    
    public init() { }
    
    open var requestUrl: String {return "" }
    
    open var requestMethod: ATRequestMethod { return .post }
    
    open var requestParameters: [String : Any]? { return nil }
    
    open var requestHeaders: [String : String]? { return nil }
    
    open var requestUseDefaultParameters : Bool { return true }
    
    open var requestUseDefaultHeaders : Bool { return true }
    
    open var requestBaseUrlIndex : Int { return 0 }
    
    open var requestDelegate: RequestDelegate?
    
    open var cachePolicy: CachePolicy { return .unuse }
    
    open var contentType : [String] { return ["application/json","text/json"] }
    
    open var formData: [FormData]? { return nil }
    
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
        
        let hasFormData = (self.formData != nil)
        
        if !hasFormData {
            var useCache = false
            var stop = false
            var forceStop = false
            switch self.cachePolicy {
            case .unuse: break
            case .cacheAndLoad(cacheInterval: _):
                useCache = true
                stop = false
                break
            case .cacheElseLoad(cacheInterval: _):
                useCache = true
                stop = true
                break
            case .cacheDontLoad(cacheInterval: _):
                useCache = true
                forceStop = true
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
                if forceStop {return}
                if stop && data != nil { return }
            }
        }
        let manager = RequestConfig.requestManager
        
        if !hasFormData {
            let method = self.requestMethod.convert()
            manager.request(url, method: method, parameters: parameter, encoding: URLEncoding.default, headers: header).validate(contentType: self.contentType).responseJSON { [unowned self] (response) in
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
        } else {
            manager.upload(multipartFormData: { [weak self] (multipartFormData) in
                for fd in (self?.formData!)! {
                    let url = fd.url
                    
                    if url != nil {
                        let mimeType = fd.mimeType
                        let fileName = fd.filename
                        if mimeType != nil && fileName != nil {
                            multipartFormData.append(url!, withName: fd.name, fileName: fileName!, mimeType: mimeType!)
                        } else {
                            multipartFormData.append(url!, withName: fd.name)
                        }
                    } else {
                        let data = fd.data
                        if data != nil {
                            let mimeType = fd.mimeType
                            if mimeType != nil {
                                let fileName = fd.filename
                                if fileName != nil {
                                    multipartFormData.append(data!, withName: fd.name, fileName: fileName!, mimeType: fd.mimeType!)
                                } else {
                                    multipartFormData.append(data!, withName: fd.name, mimeType: mimeType!)
                                }
                            } else {
                                multipartFormData.append(data!, withName: fd.name)
                            }
                        }
                    }
                }
                for (key,value) in parameter ?? [:] {
                    let v = "\(value)"
                    let data = v.data(using: String.Encoding.utf8)
                    if (data != nil) {
                        multipartFormData.append(data!, withName: key)
                    }
                }
            }, to: url, encodingCompletion: { (encodingResult) in
                switch encodingResult {
                    
                case .success(let request, _, _):
                    request.responseJSON(completionHandler: { (response) in
                        print(response)
                        if response.response != nil {
                            let result = RequestConfig.responseHandler(url,response.response,false,response.result.value)
                            if result.error == nil {
                                let data = result.data
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
                    })
                    break
                case .failure(let error):
                    self.failure?(error as NSError)
                    self.requestDelegate?.request(self, didFailedRequestWithError: error)
                }
            })
        }
        
        
    }
    
    // MARK : - private
    private var success : ((Any?,Bool) -> Void)?
    
    private var failure : ((NSError) -> Void)?
    
    private func convertClass(data:Any?) -> Any? {
        if data == nil { return nil }
        if T.self ==  RawResponseData.self {return data}
        if data is [Any] {
            let datas = data as! [Any]
            let result = datas.map({ (dict) -> T? in
                return T.deserialize(from: dict as? [String : Any])
            })
            return result
        } else if data is [String : Any] {
            return T.deserialize(from: (data as? [String : Any]))
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
        switch self.cachePolicy {
        case .unuse: break
        case .cacheAndLoad(cacheInterval: let time):
            cacheTime = time ?? RequestConfig.cacheTimeInterval
            useCache = true
            break
        case .cacheElseLoad(cacheInterval: let time):
            cacheTime = time ?? RequestConfig.cacheTimeInterval
            useCache = true
            break
        case .cacheDontLoad(cacheInterval: _):
            break
        }
        
        if useCache {
            let cacheModel = CacheModel.init(key: self.cacheKey, finishTime: NSDate().timeIntervalSince1970 + cacheTime, data: data!)
            let cache = YYCache.init(name: "ATRequest")
            cache?.setObject(cacheModel, forKey: self.cacheKey)
        }
    }
}

