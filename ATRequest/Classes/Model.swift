//
//  Model.swift
//  Pods
//
//  Created by 凯文马 on 2017/9/19.
//
//

import UIKit
import HandyJSON

/// 获取的响应模型类型
public protocol ResponseModelType {
    static func convert(datas : Any) -> ResponseModelType?
}

// MARK: - 为数组扩展响应模型类型协议
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

/// 获取的响应模型类型，转换模型
public protocol ResponseModel : HandyJSON,ResponseModelType{
    
}

// MARK: - 为模型扩展响应模型类型协议
public extension ResponseModel {
    public static func convert(datas: Any) -> ResponseModelType? {
        guard let data = datas as? [String : Any] else {
            return nil
        }
        return self.deserialize(from: data)
    }
}

/// 响应类型枚举，必须是遵循这种协议的枚举才可以转换
public protocol ResponseEnum  : HandyJSONEnum {
    
}

postfix operator ^

/// 不进行任何转换的原始响应数据包
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
    
    /// 快速获取原始数据的运算符
    /// let a = RawResponseData("kevin")
    /// let b = a^
    /// print(b)
    ///
    /// - Parameter data: 数据包
    /// - Returns: 原始数据
    public static postfix func ^(data : RawResponseData) -> Any? {
        return data.rawData
    }
}

/// 表单数据协议，上传文件时使用
public protocol FormDataType {
    var data : Data? {get}
    var url : URL? {get}
    var name : String {get}
    var filename : String? {get}
    var mimeType : String? {get}
}

/// 表单数据类
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
