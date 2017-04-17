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
import NVActivityIndicatorView

fileprivate let url = "https://api.thinkpage.cn/v3/weather/daily.json?"
fileprivate let authkey = "osoydf7ademn8ybv"
fileprivate let language = "zh-Hans"


class ViewController: UIViewController, NVActivityIndicatorViewable {

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
        weatherView.changeCityBlock = {
            (sender) -> Void in
            
            let cityVC = IMCitysViewController()
            cityVC.cityDelegate = self
            self.present(UINavigationController(rootViewController: cityVC), animated: true, completion: {
            })
        }
        self.view.addSubview(weatherView)
    }
    
    fileprivate func startLocation() {
        
        IMLocationManager.manager.startUpdateLocationService()
        
        IMLocationManager.manager.locationCoordBlock = {
            (latitude, longitude) ->Void in
            self.getupWeekWetherInfo(latitude, longitude)
        }
        
        IMLocationManager.manager.locationFailBlock = {
            (error) -> Void in
            print("locationFailBlock is \(error)")
        }
    }
    
    /// 获取一周的天气数据
    fileprivate func getupWeekWetherInfo(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        
        /// 提示HUB
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: UIFont.systemFont(ofSize: 15), type: .ballBeat, color: .orange, padding: 0, backgroundColor: UIColor.red.withAlphaComponent(0.1), textColor: .purple)
        
        
        let parameters: [String : Any] = ["key" : authkey, "location" : String(latitude) + ":" + String(longitude), "language" : language, "unit": "c", "start": 0, "days": 7]
        
        let weekReq = Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: ["Content-Type":"application/json"])

        weekReq.responseJSON { (response) in
            
            self.stopAnimating()
            
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

extension ViewController: IMCitysViewControllerDelegate{
    func changeCityName(city: String) {
        IMLocationManager.manager.fetchCoordinateInfo(address: city) { (place, error) in
            guard let place = place else { return }
            self.getupWeekWetherInfo((place.location?.coordinate.latitude)!, (place.location?.coordinate.longitude)!)
            }
    }
}

