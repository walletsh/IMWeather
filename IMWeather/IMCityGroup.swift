//
//  IMCityGroup.swift
//  IMWeather
//
//  Created by imwallet on 17/4/17.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import SwiftyJSON

struct IMCityGroup {

    var title: String
    var citys = [String]()
    
    init(fromJson json: JSON) {
        title = json["title"].stringValue
        
        let citysJson = json["cities"].arrayValue
        for city in citysJson {
            let cityName = city.stringValue
            citys.append(cityName)
        }
    }
    
}
