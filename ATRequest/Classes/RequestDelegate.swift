//
//  RequestDelegate.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

public protocol RequestDelegate : class {
    
    func request<Request : ATRequestType>(_ request:Request,didFinishRequestWithObject object:Any?,fromCache:Bool)
    
    func request<Request : ATRequestType>(_ request:Request,didFailedRequestWithError error:Error)
}
