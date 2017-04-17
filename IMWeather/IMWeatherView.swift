//
//  IMWeatherView.swift
//  IMWeather
//
//  Created by imwallet on 17/4/14.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import SnapKit

let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

class IMWeatherView: UIView {

    var changeCityBlock: ((_ sender: UIButton) -> Void)?
    
    var weatherModel: IMWeatherModel? {
        didSet{
            let location = weatherModel?.location
            cityButton.setTitle(location?.name, for: .normal)
            
            self.weatherInfos = weatherModel?.daily
            self.weatherInfo = weatherModel?.daily.first
        }
    }
    
    fileprivate var weatherInfo: IMWeatherInfo?{
        didSet{
            weatherIcon.image = UIImage(named:(weatherInfo?.code_day)!)
            temperatureLabel.text = (weatherInfo?.high)! + "℃/" + (weatherInfo?.low)! + "℃"
            weatherLabel.text = weatherInfo?.text_day
        }
    }
    
    fileprivate var weatherInfos: [IMWeatherInfo]? {
        didSet{
            self.updateWeekWeatherInfo()
        }
    }
    
    fileprivate lazy var cityButton: UIButton = {
        let cityBtn = UIButton()
        cityBtn.titleLabel?.textAlignment = .center
        cityBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        cityBtn.addTarget(self, action: #selector(changeCity(_:)), for: .touchUpInside)
        return cityBtn
    }()
    
    fileprivate lazy var weatherIcon: UIImageView = {
        let weatherImage = UIImageView()
        return weatherImage
    }()
    
    fileprivate lazy var weatherLabel: UILabel = {
        let weather = UILabel()
        weather.font = UIFont.boldSystemFont(ofSize: 30)
        weather.textColor = UIColor.white
        weather.textAlignment = .center
        return weather
    }()
    
    fileprivate lazy var temperatureLabel: UILabel = {
        let tempLabel = UILabel()
        tempLabel.font = UIFont.boldSystemFont(ofSize: 28)
        tempLabel.textColor = UIColor.white
        tempLabel.textAlignment = .center
        return tempLabel
    }()

    fileprivate lazy var scrollewView: UIScrollView = {
        let scrollew = UIScrollView()
        scrollew.showsVerticalScrollIndicator = false
        scrollew.showsHorizontalScrollIndicator = false
        scrollew.isPagingEnabled = true
        return scrollew
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        
        self.addSubview(cityButton)
        cityButton.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.snp.right).offset(-60)
            make.left.equalTo(self.snp.left).offset(60)
            make.top.equalTo(self.snp.top).offset(40)
            make.height.equalTo(40)
        }
        
        self.addSubview(weatherIcon)
        weatherIcon.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(cityButton.snp.bottom).offset(20)
            make.width.height.equalTo(130)
            make.centerX.equalTo(self.snp.centerX)
        }
        
        self.addSubview(weatherLabel)
        weatherLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.snp.right)
            make.left.equalTo(self.snp.left)
            make.height.equalTo(30)
            make.top.equalTo(weatherIcon.snp.bottom)
        }

        self.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.snp.right)
            make.left.equalTo(self.snp.left)
            make.height.equalTo(28)
            make.top.equalTo(weatherLabel.snp.bottom).offset(10)
        }
        
        self.addSubview(scrollewView)
        scrollewView.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.snp.right)
            make.left.equalTo(self.snp.left)
            make.height.equalTo(160)
            make.top.equalTo(temperatureLabel.snp.bottom).offset(30)
        }
    }
}

extension IMWeatherView {
    @objc fileprivate func changeCity(_ sender: UIButton) {
        guard let changeCityBlock = changeCityBlock else { return }
        changeCityBlock(sender)
    }
    
    fileprivate func updateWeekWeatherInfo() {
        guard let count = self.weatherInfos?.count else { return }
        
        /// 移除所有子控件
        _ = scrollewView.subviews.map {
            $0.removeFromSuperview()
        }
        
        for index in 0..<count {
            let infoW = kScreenW * 0.5
            let infoX = CGFloat(index) * infoW
            
            let weatherInfoView = IMWeatherInfoView()
            weatherInfoView.weatherInfo = self.weatherInfos?[index]
            weatherInfoView.tag = index
            scrollewView.addSubview(weatherInfoView)
            
            weatherInfoView.snp.makeConstraints({ (make) -> Void in
                make.top.equalTo(scrollewView.snp.top)
                make.width.equalTo(infoW)
                make.left.equalTo(scrollewView.snp.left).offset(infoX)
                make.height.equalTo(scrollewView)
            })
            scrollewView.contentSize = CGSize(width: infoW * CGFloat(self.weatherInfos!.count), height: 0)
        }
    }
}










