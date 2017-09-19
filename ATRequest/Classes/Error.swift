//
//  Error.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/15.
//
//

import UIKit

let ErrorDemainServerError = "com.atrequest.error.servercode"
let ErrorDemainServerErrorCode = -123

let ErrorDemainNoHandle = "com.atrequest.error.nohandle"
let ErrorDemainNoHandleCode = -425

let ErrorDemainFormatError = "com.atrequest.error.format"
let ErrorDemainFormatErrorCode = -534

extension NSError {
    open class func noHandleError() -> NSError {
        return NSError.init(domain: ErrorDemainNoHandle, code: ErrorDemainNoHandleCode, userInfo: [NSLocalizedDescriptionKey : "没有添加处理方法"])
    }
    open class func serverError(code:Int,message : String) -> NSError {
        return NSError.init(domain: ErrorDemainServerError, code: code, userInfo: [NSLocalizedDescriptionKey : message])
    }
    open class func formatError() -> NSError {
        return NSError.init(domain: ErrorDemainFormatError, code: ErrorDemainFormatErrorCode, userInfo: [NSLocalizedDescriptionKey : "数据解析异常"])
    }
    open var mesage : String? {
        return self.userInfo[NSLocalizedDescriptionKey] as? String
    }
}
