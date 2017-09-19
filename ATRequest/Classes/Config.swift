//
//  Config.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

public enum RequestEnvironment : Int{
    case develop = 0
    case release = 1
    case test = 2
    case abtest = 3
    
    public var desc : String {
        return ["开发环境","生产环境","测试环境","灰度环境"][self.rawValue]
    }
}

fileprivate let _defaultConfig = RequestConfig()

public class RequestConfig {

    public class var environment : RequestEnvironment {
        get { return _defaultConfig.environment }
        set { _defaultConfig.environment = newValue }
    }
    
    public class var timeoutInterval : TimeInterval {
        get { return _defaultConfig.timeoutInterval}
        set { _defaultConfig.timeoutInterval = newValue }
    }
    
    public class var baseUrls : [String]? {
        return _defaultConfig.baseUrls[_defaultConfig.environment.rawValue]
    }
    
    public class func setBaseUrls(_ urls : [String],forEnvironment envir:RequestEnvironment) {
        _defaultConfig.baseUrls[envir.rawValue] = urls
    }
    
    public class func headers(_ headers:@escaping (inout [String:String]) -> Void) {
        _defaultConfig.headerAction = headers
    }
    
    class func headers(_ addTo: inout [String:String]) {
        _defaultConfig.headerAction(&addTo)
    }
    
    public class func parameters(_ parameters:@escaping (inout [String:Any]) -> Void) {
        _defaultConfig.parameterAction = parameters
    }
    
    class func parameters(_ addTo: inout [String:Any]) {
        _defaultConfig.parameterAction(&addTo)
    }
    
    public class var environmentDesc : String {
        return _defaultConfig.environment.desc
    }
    
    public class var responseHandler : (String,URLResponse?,Bool,Any?) -> (error:NSError?,cache:Bool,data:Any?) {
        return _defaultConfig.responseHandler ?? {(_,_,_,_) in return (NSError.noHandleError(),false,[:] as [String:Any])}
    }
    
    public class func bindResponseHandler(_ handler:@escaping (String,URLResponse?,Bool,Any?) -> (error:NSError?,cache:Bool,data:Any?)) {
        _defaultConfig.responseHandler = handler
    }
    
    public class var requestManager : ATRequestManager {
        return _defaultConfig.requestManager
    }
    
    // MARK : - private
    var environment : RequestEnvironment = .develop
    var baseUrls : [[String]] = [[],[],[],[]]
    var headerAction : (inout [String:String]) -> Void = { (d) in }
    var parameterAction : (inout [String:Any]) -> Void = { (d) in }
    var responseHandler : ((String,URLResponse?,Bool,Any?) -> (error:NSError?,cache:Bool,data:Any?))?
    var timeoutInterval : TimeInterval = 60.0
    lazy var requestManager : ATRequestManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = RequestConfig.timeoutInterval
        return ATRequestManager.init(configuration: config)
    }()
}
