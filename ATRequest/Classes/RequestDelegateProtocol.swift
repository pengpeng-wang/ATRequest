//
//  RequestProtocols.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

public protocol RequestDelegate {
    
    func request(_ request:ATRequest,didFinishRequestWithObject object:Any?,fromCache:Bool)
    
    func request(_ request:ATRequest,didFailedRequestWithError error:Error)
}
