//
//  Config.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

/// 网络环境
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

/// 请求配置类
public final class RequestConfig {
    
    /// 当前环境
    public class var environment : RequestEnvironment {
        get { return _defaultConfig.environment }
        set { _defaultConfig.environment = newValue }
    }
    
    /// 超时时间
    public class var timeoutInterval : TimeInterval {
        get { return _defaultConfig.timeoutInterval}
        set { _defaultConfig.timeoutInterval = newValue }
    }
    
    /// 默认缓存时间
    public class var cacheTimeInterval : TimeInterval {
        get { return _defaultConfig.cacheTimeInterval}
        set { _defaultConfig.cacheTimeInterval = newValue }
    }
    
    /// 基地址，只读
    public class var baseUrls : [String]? {
        return _defaultConfig.baseUrls[_defaultConfig.environment.rawValue]
    }
    
    /// 设置不同环境下的请求地址
    ///
    /// - Parameters:
    ///   - urls: 地址列表
    ///   - envir: 环境
    public class func setBaseUrls(_ urls : [String],forEnvironment envir:RequestEnvironment) {
        _defaultConfig.baseUrls[envir.rawValue] = urls
    }
    
    /// 设置默认头信息
    ///
    /// - Parameter headers: 头信息闭包
    public class func headers(_ headers:@escaping (inout [String:String]) -> Void) {
        _defaultConfig.headerAction = headers
    }
    
    public class func parameters(_ parameters:@escaping (inout [String:Any]) -> Void) {
        _defaultConfig.parameterAction = parameters
    }
    
    /// 当前环境描述
    public class var environmentDesc : String {
        return _defaultConfig.environment.desc
    }

    /// 网络请求公共部分处理，必须配置
    public class func bindResponseHandler(_ handler:@escaping (String,URLResponse?,Bool,Any?) -> (error:NSError?,cache:Bool,data:Any?)) {
        _defaultConfig.responseHandler = handler
    }
    
    public class func bindErrorHandler(_ handler:@escaping (NSError) -> (Bool)) {
        _defaultConfig.errorHandler = handler
    }

    // MARK: - private
    var environment : RequestEnvironment = .develop
    var baseUrls : [[String]] = [[],[],[],[]]
    var headerAction : (inout [String:String]) -> Void = { (d) in }
    var parameterAction : (inout [String:Any]) -> Void = { (d) in }
    var responseHandler : ((String,URLResponse?,Bool,Any?) -> (error:NSError?,cache:Bool,data:Any?))?
    var errorHandler : (NSError) -> (Bool) = { _ in return true}
    var timeoutInterval : TimeInterval = 60.0
    var cacheTimeInterval : TimeInterval = 3600
    lazy var requestManager : ATRequestManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = RequestConfig.timeoutInterval
        return ATRequestManager.init(configuration: config)
    }()
    
    class func headers(_ addTo: inout [String:String]) {
        _defaultConfig.headerAction(&addTo)
    }
    
    class func parameters(_ addTo: inout [String:Any]) {
        _defaultConfig.parameterAction(&addTo)
    }
    
    class var requestManager : ATRequestManager {
        return _defaultConfig.requestManager
    }
    
    class var responseHandler : (String,URLResponse?,Bool,Any?) -> (error:NSError?,cache:Bool,data:Any?) {
        return _defaultConfig.responseHandler ?? {(_,_,_,_) in return (NSError.noHandleError(),false,[:] as [String:Any])}
    }
    
    class var errorHandler : (NSError) -> (Bool) {
        return _defaultConfig.errorHandler
    }
}
