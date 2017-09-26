//
//  CacheModel.swift
//  Alamofire
//
//  Created by 凯文马 on 2017/9/26.
//

import UIKit

class CacheModel : NSObject,NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.key, forKey: "key")
        aCoder.encode(self.data, forKey: "data")
        aCoder.encode(self.finishTime, forKey: "finish_time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.key = aDecoder.decodeObject(forKey: "key") as! String
        self.data = aDecoder.decodeObject(forKey: "data") as Any
        self.finishTime = aDecoder.decodeDouble(forKey: "finish_time")
    }
    
    init(key : String,finishTime:TimeInterval,data:Any) {
        self.key = key
        self.finishTime = finishTime
        self.data = data
    }
    
    var finishTime : TimeInterval
    
    var key : String
    
    var data : Any
    
    
}
