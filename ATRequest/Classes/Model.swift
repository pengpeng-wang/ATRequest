//
//  Model.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/19.
//
//

import UIKit
import HandyJSON

public protocol ResponseModel : HandyJSON{
    
}

public protocol ResponseEnum  : HandyJSONEnum{
    
}

public struct RawResponseData : ResponseModel{
    public init() {}
}

public protocol FormData {
    var data : Data? {get}
    var url : URL? {get}
    var name : String {get}
    var filename : String? {get}
    var mimeType : String? {get}
}

public class FormDataEntity : FormData {
    public init(data:Data,name : String,filename: String?,mimetype:String?) {
        self.data = data
        self.name = name
        self.filename = filename
        self.mimeType = mimetype
    }
    
    public init(url:URL,name : String,filename: String?,mimetype:String?) {
        self.url = url
        self.name = name
        self.filename = filename
        self.mimeType = mimetype
    }
    
    public var data : Data?
    public var url : URL?
    public var name : String = ""
    public var filename : String?
    public var mimeType : String?
}

public extension ResponseModel {
    mutating func mapping(mapper: HelpingMapper) {
        
    }
    
    mutating func didFinishMapping() {
        
    }
}
