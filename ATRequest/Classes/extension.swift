//
//  extension.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/14.
//
//

import UIKit

infix operator <-

extension Dictionary {
    
    static public func <- (a:inout Dictionary,b:Dictionary)
    {
        for (k,v) in b {
            a.updateValue(v, forKey: k)
        }
    }
    
}


