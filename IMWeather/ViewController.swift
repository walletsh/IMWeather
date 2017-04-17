//
//  ViewController.swift
//  IMWeather
//
//  Created by imwallet on 17/4/14.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


fileprivate let url = "https://api.thinkpage.cn/v3/weather/daily.json?"
fileprivate let authkey = "osoydf7ademn8ybv"
fileprivate let language = "zh-Hans"


class ViewController: UIViewController {

    var weatherView: IMWeatherView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStatusBar()
        setupSubviews()
        
        startLocation()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !IMLocationManager.manager.locationServicesCanEnabled() {
            IMAlertTool().showAlert(self, title: "提示", message: "系统定位服务未打开", confirmHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ViewController {
    
    fileprivate func setupStatusBar() {
        let view = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        
        let statusBarView = view.value(forKey: "statusBar") as! UIView
        
        if statusBarView.responds(to: #selector(getter: UIView.backgroundColor)) {
            statusBarView.backgroundColor = UIColor.clear
        }
        
    }
    
    fileprivate func setupSubviews() {
        weatherView = IMWeatherView(frame: self.view.bounds)
        self.view.addSubview(weatherView)
    }
    
    fileprivate func startLocation() {
        
        IMLocationManager.manager.startUpdateLocationService()
        
        IMLocationManager.manager.locationCoordBlock = {
            (latitude, longitude) ->Void in
            print("locationCoordBlock: latitude is \(latitude) longitude is \(longitude)")
            
            IMLocationManager.manager.fetchAddressInfo(latitude: latitude, longitude: longitude) { (place, error) in
                guard let place = place else { return }
                print("fetchAddressInfo place is \(place) error is \(error)")
            }
            
//            self.getupWeatherInfo(latitude, longitude)
            
            self.getupWeekWetherInfo(latitude, longitude)
        }
        
        IMLocationManager.manager.fetchCoordinateInfo(address: "灵宝") { (place, error) in
            guard let place = place else { return }
            print("fetchCoordinateInfo place is \(place) error is \(error)")
        }
        
        IMLocationManager.manager.locationFailBlock = {
            (error) -> Void in
            print("locationFailBlock is \(error)")
        }
    }
    
    
    fileprivate func getupWeatherInfo(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
//        let parameters: [String : Any] = ["lat" : latitude, "lng" : longitude, "authkey" : authkey]
//        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
//        }
    }
    
    
    /// 获取一周的天气数据
    fileprivate func getupWeekWetherInfo(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        
        let parameters: [String : Any] = ["key" : authkey, "location" : String(latitude) + ":" + String(longitude), "language" : language, "unit": "c", "start": 0, "days": 7]
        
        let weekReq = Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: ["Content-Type":"application/json"])

        weekReq.responseJSON { (response) in
            guard let req = response.request,
                let res = response.response,
                let data = response.data,
                let jsonResult = response.result.value else {return}
            
            print("response.request is \(req)")  // original URL request
            print("response.response is \(res)") // HTTP URL response
            print("response.data is \(data)")     // server data
            print("response.result is \(response.result)")   // result of response serialization
            print("jsonResult: \(jsonResult)")
            
            switch response.result{
            case .success(let value):
                let jsonValue = JSON(value)
                let weatherResults = jsonValue["results"][0]
                
                let weatherModel = IMWeatherModel(fromJson: weatherResults)
                self.weatherView.weatherModel = weatherModel
                
                break
            case .failure(let error):
                print("error is: \(error)")
                break
            }
        }
    }
}

