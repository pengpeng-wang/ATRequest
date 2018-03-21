//
//  ATRequest.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit
import YYCache
import Alamofire

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

public typealias ATContentType = String

public typealias ATRequestManager = SessionManager

public let DefaultContentTypes : [ATContentType] = ["application/json","text/json"]

/// 网络请求协议
public protocol ATRequestType : class {
    
    /// 转换的模型类型，如 [User],User，如需要返回原始数据，请使用RawResponseData
    associatedtype ModelType : ResponseModelType
    
    /// 请求回调代理，可选
    var requestDelegate : RequestDelegate? {get}
    
    /// 请求url，必选
    var requestUrl: String {get}
    
    /// 请求方式，可选，默认POST
    var requestMethod: ATRequestMethod {get}
    
    /// 请求参数，可选，默认为空
    var requestParameters: [String : Any]? {get}
    
    /// 请求头信息，可选，默认为空
    var requestHeaders: [String : String]? {get}
    
    /// 是否拼接默认的全局参数，可选，默认true
    var requestUseDefaultParameters : Bool {get}
    
    /// 是否拼接默认的全局头信息，可选，默认true
    var requestUseDefaultHeaders : Bool {get}
    
    /// 请求baseUrl组中url索引，默认0，可能存在某一种环境有多个域名或IP的情况，以此适配
    var requestBaseUrlIndex : Int {get}
    
    /// 缓存策略，可选，默认不使用缓存
    var cachePolicy : CachePolicy {get}
    
    /// content-type，可选，默认["application/json","text/json"]
    var contentType : [ATContentType] {get}
    
    /// 上传文件时使用的表单数据，可选，默认为空
    var formData : [FormDataType]? {get}
    
    /// 是否打印调试信息，可选，默认false
    var debugLog : Bool {get}
}

public extension ATRequestType {
    var requestMethod: ATRequestMethod { return .post }
    
    var requestParameters: [String : Any]? { return nil }
    
    var requestHeaders: [String : String]? { return nil }
    
    var requestUseDefaultParameters : Bool { return true }
    
    var requestUseDefaultHeaders : Bool { return true }
    
    var requestBaseUrlIndex : Int { return 0 }
    
    var requestDelegate: RequestDelegate? { return nil }
    
    var cachePolicy: CachePolicy { return .unuse }
    
    var contentType : [ATContentType] { return DefaultContentTypes }
    
    var formData: [FormDataType]? { return nil }
    
    var debugLog : Bool { return false }
}

public extension ATRequestType {
    
    /// 通用请求方法，自带回调，只要存在代理，代理方法也会同时触发
    ///
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func requestWithSuccess(_ success:@escaping (ModelType?,Bool) -> Void,failure:@escaping (NSError)->Void) {
        
        DispatchQueue.global().async {
            let header = self.getHeaders()
            let parameter = self.getParameters()
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
                    let data = self.cacheData()
                    if data != nil {
                        let resultObj = self.convertClass(data: data)
                        success(resultObj,true)
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
                    if self.debugLog {
                        print(response)
                    }
                    DispatchQueue.global().async {
                        if response.response != nil {
                            let result = RequestConfig.responseHandler(url,response.response,false,response.result.value)
                            if result.error == nil {
                                let data = result.data
                                self.saveCache(data: data)
                                let resultObj = self.convertClass(data: data)
                                DispatchQueue.main.async {
                                    success(resultObj,result.cache)
                                    self.requestDelegate?.request(self, didFinishRequestWithObject:resultObj, fromCache: result.cache)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    if RequestConfig.errorHandler(result.error!) {
                                        failure(result.error!)
                                        self.requestDelegate?.request(self, didFailedRequestWithError: result.error!)
                                    }
                                }
                            }
                        } else {
                            let e = NSError.noResponseError()
                            DispatchQueue.main.async {
                                if RequestConfig.errorHandler(e) {
                                    failure(e)
                                    self.requestDelegate?.request(self, didFailedRequestWithError: e)
                                }
                            }
                        }
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
                    }, to: url, encodingCompletion: { [unowned self] (encodingResult) in
                        DispatchQueue.global().async {
                            switch encodingResult {
                            case .success(let request, _, _):
                                request.responseJSON(completionHandler: { (response) in
                                    if self.debugLog {
                                        print(response)
                                    }
                                    if response.response != nil {
                                        let result = RequestConfig.responseHandler(url,response.response,false,response.result.value)
                                        if result.error == nil {
                                            let data = result.data
                                            let resultObj = self.convertClass(data: data)
                                            DispatchQueue.main.async {
                                                success(resultObj,result.cache)
                                                self.requestDelegate?.request(self, didFinishRequestWithObject:resultObj, fromCache: result.cache)
                                            }
                                        } else {
                                            DispatchQueue.main.async {
                                                failure(result.error!)
                                                self.requestDelegate?.request(self, didFailedRequestWithError: result.error!)
                                            }
                                        }
                                    } else {
                                        let e = NSError.noResponseError()
                                        DispatchQueue.main.async {
                                            failure(e)
                                            self.requestDelegate?.request(self, didFailedRequestWithError: e)
                                        }
                                    }
                                })
                                break
                            case .failure(let error):
                                if self.debugLog {
                                    print(error)
                                }
                                DispatchQueue.main.async {
                                    failure(error as NSError)
                                    self.requestDelegate?.request(self, didFailedRequestWithError: error)
                                }
                                break
                            }
                        }
                })
            }
        }
    }
    
    /// 网络请求方法，适用于代理的情况下
    public func request() {
        requestWithSuccess({ _,_ in }, failure: { _ in })
    }
    
    // MARK : - private
    
    private func convertClass(data:Any?) -> ModelType? {
        if data == nil { return nil }
        if ModelType.self == RawResponseData.self {
            let result = RawResponseData(data)
            return result as? ModelType
        }
        let result = ModelType.convert(datas: data!)
        return result as? ModelType
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

fileprivate extension ATRequestType {
    func createCacheKey(url:String,param:[String:Any]?,header:[String:String]?) -> String {
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
        return url + ps + hs
    }
    
    var cacheKey : String {
        return createCacheKey(url: getUrl() ?? "", param: getParameters(), header: getHeaders())
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

/// 网络请求基类，不建议使用，推荐使用协议方式
open class ATRequest<Model : ResponseModelType> : ATRequestType {
    
    public init() {}
    
    public convenience init(delegate : RequestDelegate?) {
        self.init()
        self.requestDelegate = delegate
    }
    
    open var requestDelegate: RequestDelegate?
    
    public typealias ModelType = Model
    
    open var requestUrl: String {
        fatalError("please implemente in subclass")
    }
    
    open var requestMethod: ATRequestMethod { return .post }
    
    open var requestParameters: [String : Any]? { return nil }
    
    open var requestHeaders: [String : String]? { return nil }
    
    open var requestUseDefaultParameters : Bool { return true }
    
    open var requestUseDefaultHeaders : Bool { return true }
    
    open var requestBaseUrlIndex : Int { return 0 }
    
    open var cachePolicy: CachePolicy { return .unuse }
    
    open var contentType : [ATContentType] { return DefaultContentTypes }
    
    open var formData: [FormDataType]? { return nil }
    
    open var debugLog : Bool { return false }
    
}
