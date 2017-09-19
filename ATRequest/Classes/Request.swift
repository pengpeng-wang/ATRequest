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

public typealias ATRequestManager = SessionManager

open class BaseRequest<T:EnableMap>: ATRequest {
    
    open class Default {}
    
    open var requestUrl: String {return "" }
    
    open var requestMethod: ATRequestMethod { return .post }
    
    open var requestParameters: [String : Any]? { return nil }
    
    open var requestHeaders: [String : String]? { return nil }
    
    open var requestUseDefaultParameters : Bool { return true }
    
    open var requestUseDefaultHeaders : Bool { return true }
    
    open var requestBaseUrlIndex : Int { return 0 }
    
    public init() { }
    
    open var requestDelegate: RequestDelegate?
    
    public func request() {
        let header = getHeaders()
        let parameter = getParameters()
        
        let url = self.getUrl()!
        let manager = RequestConfig.requestManager
        manager.request(url, method: self.requestMethod.convert(), parameters: parameter, encoding: JSONEncoding.default, headers: header).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            print(response)
            if response.response != nil {
                let result = RequestConfig.responseHandler(url,response.response,false,response.result.value)
                if result.error == nil {
                    let data = result.data
                    let resultObj = self.convertClass(data: data)
                    
                    self.requestDelegate?.request(self, didFinishRequestWithObject:resultObj, fromCache: result.cache)
                } else {
                    self.requestDelegate?.request(self, didFailedRequestWithError: result.error!)
                }
            } else {
                self.requestDelegate?.request(self, didFailedRequestWithError: NSError.noResponseError())
            }
        }
    }
    
    // MARK : - private
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
