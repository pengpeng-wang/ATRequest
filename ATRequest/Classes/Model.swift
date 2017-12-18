//
//  Model.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/19.
//
//

import UIKit
import HandyJSON

public protocol ResponseModelType {
    static func convert(datas : Any) -> ResponseModelType?
}

extension Array : ResponseModelType {
    public static func convert(datas: Any) -> ResponseModelType? {
        print(Element.Type.self)
        print(ResponseModel.Type.self)
        guard let data = datas as? [Any],
            Element.self is ResponseModel.Type else {
            return nil
        }
        let elementType = Element.self as! ResponseModel.Type
        let result = data.flatMap { (dict) -> ResponseModel? in
            return elementType.deserialize(from: dict as? [String : Any])
        }
        return result
    }
}

public protocol ResponseModel : HandyJSON,ResponseModelType{
    
}

public extension ResponseModel {
    public static func convert(datas: Any) -> ResponseModelType? {
        guard let data = datas as? [String : Any] else {
            return nil
        }
        return self.deserialize(from: data)
    }
}

public protocol ResponseEnum  : HandyJSONEnum {
    
}

postfix operator ^
public struct RawResponseData : ResponseModel {
    public init() {
        _rawData = nil
    }
    
    public var rawData : Any? {
        return _rawData
    }
    
    private let _rawData : Any?
    
    public init(_ raw : Any?) {
        _rawData = raw
    }
    
    public static postfix func ^(data : RawResponseData) -> Any? {
        return data.rawData
    }
}

public protocol FormDataType {
    var data : Data? {get}
    var url : URL? {get}
    var name : String {get}
    var filename : String? {get}
    var mimeType : String? {get}
}

public class FormData : FormDataType {
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
