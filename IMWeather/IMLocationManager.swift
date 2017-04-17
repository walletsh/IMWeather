//
//  IMLocationManager.swift
//  IMWeather
//
//  Created by imwallet on 17/3/31.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import CoreLocation

class IMLocationManager: NSObject {
    
    /// 获取到定位回调
    var locationCoordBlock: ((_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> Void)?
    
    /// 定位失败回调
    var locationFailBlock:((_ error: Error) -> Void)?
    
    static let manager = IMLocationManager()
    
    private override init(){}
    
    
    fileprivate lazy var locationManager: CLLocationManager = {
        let location = CLLocationManager()
        location.distanceFilter = kCLLocationAccuracyKilometer
        location.desiredAccuracy = kCLLocationAccuracyBest
        location.pausesLocationUpdatesAutomatically = true
        location.delegate = self
//        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
//            location.requestWhenInUseAuthorization()
//        }else{
//            location.requestAlwaysAuthorization()
//        }
        
        if location.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            location.requestWhenInUseAuthorization()
        }
//
//        if location.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)){
//            location.requestAlwaysAuthorization()
//        }
        
        return location
    }()
    
    
    /// 判断系统是否开启定位服务
    func locationServicesCanEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    /// 开始定位
    func startUpdateLocationService() {
        guard locationServicesCanEnabled() else { return }
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    /// 停止服务
    func stopUpdateLocationService() {
        locationManager.stopUpdatingLocation()
    }
    
    /// 反地理编码
    func fetchAddressInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees, placeHandler:((_ place: CLPlacemark?, _ error: Error?) -> Void)? = nil) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocedor = CLGeocoder()
        
        geocedor.reverseGeocodeLocation(location) { (placemarks, error) in
            
            let place = placemarks?.last
            guard let placeHandler = placeHandler else { return }
            placeHandler(place, error)
        }
    }
    
    /// 地理编码
    func fetchCoordinateInfo(address: String, placeHandler:((_ place: CLPlacemark?, _ error: Error?) -> Void)? = nil) {
        let geocedor = CLGeocoder()
        geocedor.geocodeAddressString(address) { (placemarks, error) in
            
            let place = placemarks?.last
            guard let placeHandler = placeHandler else { return }
            placeHandler(place, error)
        }
    }
    
}


extension IMLocationManager: CLLocationManagerDelegate {
    
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("CLAuthorizationStatus is \(status.rawValue)")
        switch status {
        case .notDetermined:
            stopUpdateLocationService()
            break
        case .denied:
            stopUpdateLocationService()

            guard let controller = UIApplication.shared.keyWindow?.rootViewController else { return }
            
            IMAlertTool().showAlert(controller, title: "提示", message: "定位服务授权被拒绝，是否前往设置开启？", confirmHandler: { (okAction) -> Void in
                guard let url = URL.init(string: UIApplicationOpenSettingsURLString) else{ return }
                if UIApplication.shared.canOpenURL(url) {
//                    // UIApplicationOpenURLOptionUniversalLinksOnly:如果这个要打开的URL有效，并且在应用中配置它布尔值为true（YES）时才可以打开，否则打不开。
//                    let options = [UIApplicationOpenURLOptionUniversalLinksOnly : true];
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("success is \(success)")
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                }
            })
            break
        case .restricted:
            stopUpdateLocationService()
            break
        case .authorizedAlways:
            startUpdateLocationService()
            break
        case .authorizedWhenInUse:
            startUpdateLocationService()
            break
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        stopUpdateLocationService()
        guard let location = locations.last else { return }
        
        guard let locationCoordBlock = locationCoordBlock else { return  }
        
        locationCoordBlock(location.coordinate.latitude, location.coordinate.longitude)

    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let locationFailBlock = locationFailBlock else { return }
        locationFailBlock(error)
    }
}




class IMAlertTool: NSObject {
    
    func showAlert(_ controller: UIViewController, title: String?, message: String?, confirmHandler:((_ action: UIAlertAction) -> Void)? = nil){
        
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertVC.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { (okAction) in
            if let confirmHandler  = confirmHandler {
                confirmHandler(okAction)
            }
        }
        alertVC.addAction(confirmAction)
        
        controller.present(alertVC, animated: true, completion: nil)
    }
}



