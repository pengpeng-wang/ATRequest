//
//  RequestDelegate.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

public protocol RequestDelegate {
    
    func request<Request : ATRequest>(_ request:Request,didFinishRequestWithObject object:Any?,fromCache:Bool)
    
    func request<Request : ATRequest>(_ request:Request,didFailedRequestWithError error:Error)
}
