//
//  Model.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/19.
//
//

import UIKit
import ObjectMapper

public typealias M = Map

public typealias EnableMap = BaseMappable

open class Model: Mappable {
    
    required public init() {
        
    }
    
    open func valueMap(_ map:M) {
        
    }
    
    public func mapping(map: Map) {
        self.valueMap(map)
    }
    
    required public init?(map: Map) {
        
    }
}
