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

    @IBOutlet weak var backgroudView: UIImageView!
    
    fileprivate var weatherView: IMWeatherView!
    
    fileprivate var birdImageView: UIImageView = {//鸟
        let birdView = UIImageView(frame: CGRect(x: 0, y: kScreenH * 0.25, width: 70, height: 52))
        return birdView
    }()
    fileprivate var invertedBirdView: UIImageView = {//倒影的鸟
        let birdView = UIImageView(frame: CGRect(x: 0, y: kScreenH * 0.75, width: 70, height: 52))
        return birdView
    }()
//
    fileprivate var cloudImageView: UIImageView = {// 云
        let cloudView = UIImageView(frame: CGRect(x: -kScreenW, y: kScreenH * 0.6, width: kScreenW, height: kScreenW * 0.5))
        cloudView.image = UIImage(named: "ele_sunnyCloud2")
        return cloudView
    }()
    fileprivate var invertedCloudView: UIImageView = {// 倒影的云
        let cloudRefView = UIImageView(frame: CGRect(x: -kScreenW, y: kScreenH * 0.6, width: kScreenW, height: kScreenW * 0.5))
        cloudRefView.image = UIImage(named: "ele_sunnyCloud1")
        return cloudRefView
    }()
//
    fileprivate var sunImageView: UIImageView = {// 太阳
        let sunView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        sunView.center = CGPoint(x: kScreenW * 0.2, y: kScreenH * 0.1)
        sunView.image = UIImage(named: "ele_sunnySun")
        return sunView
    }()// 太阳
    fileprivate var sunshineImageView: UIImageView = {//太阳光
        let shineView = UIImageView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        shineView.center = CGPoint(x: kScreenW * 0.2, y: kScreenH * 0.1)
        shineView.image = UIImage(named: "ele_sunnySunshine")
        return shineView
    }()
    
    fileprivate var sunCloudImageView: UIImageView = {// 晴天云
        let cloudView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenH * 0.7, height: kScreenW * 0.5))
        cloudView.center = CGPoint(x: kScreenW * 0.25, y: kScreenH * 0.5)
        cloudView.image = UIImage(named: "ele_sunnyCloud2")
        return cloudView
    }()
    fileprivate var rainCloudImageView:UIImageView = {// 乌云
        let rainCloudView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenW * 0.5))
        rainCloudView.center = CGPoint(x: kScreenW * 0.25, y: kScreenH * 0.1)
        rainCloudView.image = UIImage(named: "night_rain_cloud")
        return rainCloudView
    }()
    
    
    /// 鸟动画数组
    fileprivate lazy var birdImages: [UIImage] = {
        var images = [UIImage]()
        for idx in 1..<9 {
            let fileName = "ele_sunnyBird" + String(idx) + ".png"
            guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil),
                let image = UIImage(contentsOfFile: filePath) else { return  images }
            images.append(image)
        }
        return images
    }()
    
    /// 天气动画图数组
    fileprivate lazy var weatherImages: [IMWeatherImageModel] = {
        var images = Array<IMWeatherImageModel>()
        
        guard let filePath = Bundle.main.path(forResource: "rainData.json", ofType: nil),
            let weatherData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
            let weatherJson =  try? JSONSerialization.jsonObject(with: weatherData, options: .mutableContainers) else { return  images }
        
        let weatherDict = JSON(weatherJson)
        let weatherImages = weatherDict["weather"]["image"].arrayValue
        for weather in weatherImages {
            let imageModel = IMWeatherImageModel(fromJson: weather)
            images.append(imageModel)
        }

        return images
    }()
    
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
                
                guard let type = weatherModel.daily.first?.code_day else { return }
                self.startWeatherAnimation(type)
                
                break
            case .failure(let error):
                print("error is: \(error)")

                break
            }
        }
    }
    
}

// MARK: - IMCitysViewControllerDelegate
extension ViewController: IMCitysViewControllerDelegate{
    func changeCityName(city: String) {
        IMLocationManager.manager.fetchCoordinateInfo(address: city) { (place, error) in
            guard let place = place else { return }
            self.getupWeekWetherInfo((place.location?.coordinate.latitude)!, (place.location?.coordinate.longitude)!)
            }
    }
}


// MARK: - 天气类型
extension ViewController {
    
    fileprivate func removeWeatherAnimationView() {
        _ = backgroudView.subviews.map {
//            $0.layer.removeAllAnimations()
            $0.removeFromSuperview()
        }
        self.backgroudView.layer.removeAllAnimations()
    }
    
    fileprivate func startWeatherAnimation(_ weatherType: String) {
        
        removeWeatherAnimationView()
        
        guard let type = Int(weatherType) else { return }
        
        if type >= 0 && type < 4{ // 晴天
            changeBackgroudImageAnimation("bg_sunny_day.jpg")
            sunAnimation()
        }
        if type >= 4 && type < 10 { // 多云
            changeBackgroudImageAnimation("bg_normal.jpg")
            cloudAnimation()
        }
        if type >= 10 && type < 20 {//雨
            changeBackgroudImageAnimation("bg_rain_day.jpg")
            rainAnimation()
        }
        if type >= 20 && type < 26 {// 雪
            changeBackgroudImageAnimation("bg_snow_day.jpg")
            snowAnimation()
        }
        if type >= 26 && type < 30 {//沙尘暴
            changeBackgroudImageAnimation("bg_sunny_day.jpg")
        }
        if type >= 30 && type < 32 {//雾霾
            changeBackgroudImageAnimation("bg_haze.jpg")
        }
        if type >= 32 && type < 37 {//风
            changeBackgroudImageAnimation("bg_sunny_day.jpg")
        }
        if type == 37 {//冷
            changeBackgroudImageAnimation("bg_fog_night.jpg")
        }
        if type == 38 {//热
            changeBackgroudImageAnimation("bg_sunny_day.jpg")
        }
        if type == 99 {//未知
            
        }
        self.view.bringSubview(toFront: weatherView)
    }
    
    fileprivate func changeBackgroudImageAnimation(_ image: String) {
        let transition = CATransition()
        transition.duration = 10
        transition.type = kCATransitionFade
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.backgroudView.layer.add(transition, forKey: "backgroudViewAnimation")
        self.backgroudView.image = UIImage(named: image)
    }
    
    
    /// 晴天
    fileprivate func sunAnimation() {
        sunImageView.layer.add(viewRotateAnimation(duration: 40), forKey: nil)
        self.backgroudView.addSubview(sunImageView)
        
        sunshineImageView.layer.add(viewRotateAnimation(duration: 40), forKey: "rotationAnimationZ")
        self.backgroudView.addSubview(sunshineImageView)
        
        sunCloudImageView.layer.add(viewTranslationAnimation(toVlaue: kScreenW, duration: 50), forKey: "rotationAnimationX")
        self.backgroudView.addSubview(sunCloudImageView)
        
    }
    
    /// 多云
    fileprivate func cloudAnimation() {
        
        birdImageView.animationImages = self.birdImages
        birdImageView.animationRepeatCount = 0
        birdImageView.animationDuration = 1
        birdImageView.startAnimating()
        birdImageView.layer.add(viewTranslationAnimation(toVlaue: kScreenW, duration: 20), forKey: nil)
        backgroudView.addSubview(birdImageView)
        
        invertedBirdView.animationImages = self.birdImages
        invertedBirdView.animationDuration = 1
        invertedBirdView.animationRepeatCount = 0
        invertedBirdView.alpha = 0.4
        invertedBirdView.startAnimating()
        invertedBirdView.layer.add(viewTranslationAnimation(toVlaue: kScreenW, duration: 20), forKey: nil)
        backgroudView.addSubview(invertedBirdView)
        
        cloudImageView.layer.add(viewTranslationAnimation(toVlaue: kScreenW * 2, duration: 50), forKey: nil)
        backgroudView.addSubview(cloudImageView)
        
        invertedCloudView.layer.add(viewTranslationAnimation(toVlaue: kScreenW * 2, duration: 50), forKey: nil)
        backgroudView.addSubview(invertedCloudView)
    }
    
    /// 下雨
    fileprivate func rainAnimation() {
        
        for (idx, weatherImage) in self.weatherImages.enumerated() {
            let raniView = UIImageView(frame: CGRect(x: weatherImage.origin.x, y: weatherImage.origin.y, width: weatherImage.size.width, height: weatherImage.size.height))
            raniView.image = UIImage(named: weatherImage.imageName)
            raniView.layer.add(viewRainAnimation(duration: CFTimeInterval(2 + idx % 5)), forKey: nil)
            raniView.layer.add(viewAlphaAnimation(duration: CFTimeInterval(2 + idx % 5)), forKey: nil)
            backgroudView.addSubview(raniView)
        }
        
        rainCloudImageView.layer.add(viewTranslationAnimation(toVlaue: kScreenW, duration: 30), forKey: nil)
        backgroudView.addSubview(rainCloudImageView)
    }
    
    /// 下雪
    fileprivate func snowAnimation() {
        for (idx, weatherImage) in self.weatherImages.enumerated() {
            let width: CGFloat = CGFloat(arc4random() % 7 + 3)
            let snowView = UIImageView(frame: CGRect(x: weatherImage.origin.x, y: weatherImage.origin.y, width: width, height: width))
            snowView.image = UIImage(named: "snow.png")
            snowView.layer.add(viewRainAnimation(duration: CFTimeInterval(5 + idx % 5)), forKey: nil)
            snowView.layer.add(viewAlphaAnimation(duration: CFTimeInterval(5 + idx % 5)), forKey: nil)
            snowView.layer.add(viewRotateAnimation(duration: 5), forKey: nil)
            backgroudView.addSubview(snowView)
        }

    }
}


// MARK: - 动画处理
extension ViewController{
    
    /// 旋转动画
    fileprivate func viewRotateAnimation(duration: CFTimeInterval) -> CABasicAnimation{
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = duration
        rotationAnimation.toValue = CGFloat.pi * 2.0
        rotationAnimation.repeatCount = MAXFLOAT
        rotationAnimation.isRemovedOnCompletion = false;
        rotationAnimation.fillMode = kCAFillModeForwards
        rotationAnimation.isCumulative = false
        return rotationAnimation
    }
    
    /// 平移动画
    fileprivate func viewTranslationAnimation(toVlaue: Any, duration: CFTimeInterval) -> CABasicAnimation {
        let tranAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        tranAnimation.duration = duration
        tranAnimation.toValue = toVlaue
        tranAnimation.repeatCount = MAXFLOAT
        tranAnimation.isRemovedOnCompletion = false;
        tranAnimation.fillMode = kCAFillModeForwards
        return tranAnimation
    }
    
    /// 下雨动画
    fileprivate func viewRainAnimation(duration: CFTimeInterval) -> CABasicAnimation {
        let rainAnimation = CABasicAnimation(keyPath: "transform")
        rainAnimation.duration = duration
        rainAnimation.fromValue = CATransform3DMakeTranslation(-170, -kScreenH, 0)
        rainAnimation.toValue = CATransform3DMakeTranslation(kScreenH * 0.5 * 34.0 / 124.0, kScreenH * 0.5, 0)
        rainAnimation.repeatCount = MAXFLOAT
        rainAnimation.isRemovedOnCompletion = false;
        rainAnimation.fillMode = kCAFillModeForwards
        return rainAnimation
    }
    
    /// 透明度动画
    fileprivate func viewAlphaAnimation(duration: CFTimeInterval) -> CABasicAnimation {
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.duration = duration
        alphaAnimation.fromValue = 1.0
        alphaAnimation.toValue = 0.1
        alphaAnimation.repeatCount = MAXFLOAT
        alphaAnimation.isRemovedOnCompletion = false;
        alphaAnimation.fillMode = kCAFillModeForwards
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        return alphaAnimation
    }

}
