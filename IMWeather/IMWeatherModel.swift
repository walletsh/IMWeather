//
//  IMWeatherModel.swift
//  IMWeather
//
//  Created by imwallet on 17/4/14.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import SwiftyJSON

struct IMWeatherInfo {
    var date: String  //日期
    var text_day: String //白天天气现象文字
    var code_day: String //白天天气现象代码
    var text_night: String //晚间天气现象文字
    var code_night: String //晚间天气现象代码
    var high: String //当天最高温度
    var low: String //当天最低温度
    var precip: String  //降水概率，范围0~100，单位百分比
    var wind_direction: String //风向文字
    var wind_direction_degree: String //风向角度，范围0~360
    var wind_speed: String //风速，单位km/h（当unit=c时）、mph（当unit=f时）
    var wind_scale: String //风力等级
    
//    init() {}
    
    init(fromJson json: JSON) {
        date = json["date"].stringValue
        text_day = json["text_day"].stringValue
        code_day = json["code_day"].stringValue
        text_night = json["text_night"].stringValue
        code_night = json["code_night"].stringValue
        high = json["high"].stringValue
        low = json["low"].stringValue
        precip = json["precip"].stringValue
        wind_direction = json["wind_direction"].stringValue
        wind_direction_degree = json["wind_direction_degree"].stringValue
        wind_speed = json["wind_speed"].stringValue
        wind_scale = json["wind_scale"].stringValue
    }
}

struct IMLocationModel {
    var path: String
    var id: String
    var country: String
    var timezone:String
    var name: String
    var timezone_offset: String
    
    
    init(fromJson json: JSON) {
        path = json["path"].stringValue
        id = json["id"].stringValue
        country = json["country"].stringValue
        timezone = json["timezone"].stringValue
        name = json["name"].stringValue
        timezone_offset = json["timezone_offset"].stringValue
    }

}

struct IMWeatherModel {
    var last_update: String
    var location: IMLocationModel
    var daily: [IMWeatherInfo]
    
    init(fromJson json: JSON) {
        last_update = json["last_update"].stringValue
        
        let locationDict = json["location"]
        location = IMLocationModel(fromJson: locationDict)
        
        daily = [IMWeatherInfo]()
        let weathers = json["daily"].arrayValue
        for weather in weathers {
            let weatherInfo = IMWeatherInfo(fromJson: weather)
            daily.append(weatherInfo)
        }
    }
}
