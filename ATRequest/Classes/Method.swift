//
//  Method.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit
import Alamofire

public enum ATRequestMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
    
    func convert() -> HTTPMethod {
        return HTTPMethod(rawValue: self.rawValue)!
    }
}
