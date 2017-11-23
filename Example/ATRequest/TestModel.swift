//
//  TestModel.swift
//  ATRequest
//
//  Created by 凯文马 on 2017/9/14.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import UIKit
import ATRequest
//import ObjectMapper
//import HandyJSON

public enum Status : Int,ResponseEnum{
    case NOOK = 0
    case OK = 1
    case HAHA = 2
}

class TestModel: ResponseModel {

    required init() {}
    
    var title : String?
    var rating : RatingModel?
//    var genres
    var casts : [PersonModel]?
    var collect_count : Int?
    var original_title : String?
    var subtype : String?
    var directors : [PersonModel]?
    var images : [AvatarModel]?
    var year : String?
    var alt : String?
    var id : String?
    var cellHeight : Double?

    func didFinishMapping() {
        print("解析完成")
    }
}

class AvatarModel: ResponseModel {
    required init() {}

    var small : String?
    var large : String?
    var medium : String?
}

class PersonModel: ResponseModel {
    required init() {}

    var alt : String?
    var name : String?
    var id : String?
    var avatars : AvatarModel?
}

class RatingModel: ResponseModel {
    required init() {}

    var average : String?
    var stars : String?
}
