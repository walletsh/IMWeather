//
//  IMWeatherInfoView.swift
//  IMWeather
//
//  Created by imwallet on 17/4/14.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import SnapKit

class IMWeatherInfoView: UIView {

    var weatherInfo: IMWeatherInfo?{
        didSet{
            dateLabel.text = weatherInfo?.date
            weatherIcon.image = UIImage(named:(weatherInfo?.code_day)!)
            temperatureLabel.text = (weatherInfo?.high)! + "℃/" + (weatherInfo?.low)! + "℃"
            windLabel.text = (weatherInfo?.wind_direction)! + " " + (weatherInfo?.wind_scale)! + "级"
            weatherLabel.text = weatherInfo?.text_day
        }
    }
    
    
    fileprivate lazy var dateLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.boldSystemFont(ofSize: 15)
        timeLabel.textColor = UIColor.white
        timeLabel.textAlignment = .center
        return timeLabel
    }()
    
    fileprivate lazy var weatherIcon: UIImageView = {
        let weatherImage = UIImageView()
        weatherImage.contentMode = .scaleAspectFit
        return weatherImage
    }()
    
    fileprivate lazy var weatherLabel: UILabel = {
        let weather = UILabel()
        weather.font = UIFont.boldSystemFont(ofSize: 15)
        weather.textColor = UIColor.white
        weather.textAlignment = .center
        return weather
    }()
    
    fileprivate lazy var temperatureLabel: UILabel = {
        let tempLabel = UILabel()
        tempLabel.font = UIFont.boldSystemFont(ofSize: 15)
        tempLabel.textColor = UIColor.white
        tempLabel.textAlignment = .center
        return tempLabel
    }()
    
    fileprivate lazy var windLabel: UILabel = {
        let windLevelLabel = UILabel()
        windLevelLabel.font = UIFont.boldSystemFont(ofSize: 15)
        windLevelLabel.textColor = UIColor.white
        windLevelLabel.textAlignment = .center
        return windLevelLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
//    convenience init() {
//        self.init(frame: CGRect.zero)
//    }
    
//    override var frame: CGRect{
//        didSet{
//            var newFrame = frame
//            newFrame.size.height = 180
//            super.frame = newFrame
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupUI() {
        
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.top.equalTo(self.snp.top)
        }
        
        self.addSubview(windLabel)
        windLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        self.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(windLabel.snp.top)
        }
        
        self.addSubview(weatherLabel)
        weatherLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(temperatureLabel.snp.top)
        }
        
        self.addSubview(weatherIcon)
        weatherIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.bottom.equalTo(weatherLabel.snp.top)
            make.top.equalTo(dateLabel.snp.bottom)
        }
    }
}



