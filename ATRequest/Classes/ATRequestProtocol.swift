//
//  ATRequest.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit
import Alamofire
import ObjectMapper

public typealias ATRequestManager = SessionManager

public protocol ATRequest : class {

    var requestDelegate : RequestDelegate? {get set}

    var requestUrl: String {get}
    
    var requestMethod: ATRequestMethod {get}
    
    var requestParameters: [String : Any]? {get}
    
    var requestHeaders: [String : String]? {get}
    
    var requestUseDefaultParameters : Bool {get}
    
    var requestUseDefaultHeaders : Bool {get}
    
    var requestBaseUrlIndex : Int {get}
    
    var responseClass : Model.Type? {get}
    
    func request()

}

public extension ATRequest {
    
    var requestMethod: ATRequestMethod { return .post }
    
    var requestParameters: [String : Any]? { return nil }
    
    var requestHeaders: [String : String]? { return nil }
    
    var requestUseDefaultParameters : Bool { return true }
    
    var requestUseDefaultHeaders : Bool { return true }
    
    var requestBaseUrlIndex : Int { return 0 }
    
    var responseClass : Model.Type? {return nil}
    
    func request() {
        let header = getHeaders()
        let parameter = getParameters()

        let url = self.getUrl()!
        let manager = RequestConfig.requestManager
        manager.request(url, method: self.requestMethod.convert(), parameters: parameter, encoding: JSONEncoding.default, headers: header).validate(contentType: ["application/json"]).responseJSON { [unowned self] (response) in
            let result = RequestConfig.responseHandler(url,response.response,false,response.result.value)
            if result.error == nil {
                let data = result.data
                let cls = self.responseClass
                let resultObj = self.convertClass(data: data, cls: cls)
                
                self.requestDelegate?.request(self, didFinishRequestWithObject:resultObj, fromCache: result.cache)
            } else {
                self.requestDelegate?.request(self, didFailedRequestWithError: result.error!)
            }
        }
    }
    
    // MARK : - private
    private func convertClass(data:Any?,cls :Model.Type?) -> Any? {
        guard data != nil,cls != nil else {
            return nil
        }
//        let a = String.self
//        let b = Model.self
//        String.type 
        if data is [Any] {
            let datas = data as! [Any]
            return datas.flatMap({ (item) -> AnyObject? in
                
                return cls!.init(JSONString:item)
            })
//            return mapper!.mapArray(JSONObject: data!)
        } else if data is [String : Any] {
//            return mapper!.map(JSONObject: data!)
            return nil
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

