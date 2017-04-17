//
//  IMCitysViewController.swift
//  IMWeather
//
//  Created by imwallet on 17/4/17.
//  Copyright © 2017年 imWallet. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol IMCitysViewControllerDelegate: NSObjectProtocol{
    
    func changeCityName(city: String)
}

class IMCitysViewController: UITableViewController {

    var cityGroups = Array<IMCityGroup>()
    
    var cityDelegate: IMCitysViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "城市列表"
        let dismissBtn = UIBarButtonItem(title: "返回", style: .done, target: self, action: #selector(clickBackItem))
        self.navigationItem.leftBarButtonItem = dismissBtn
        
        setupDataSource()
    }
    
    func setupDataSource() {
        guard let plistPath = Bundle.main.path(forResource: "Citys", ofType: "plist"),
            let cityArray = NSArray(contentsOfFile: plistPath) else { return }
        
        for cityDict in cityArray {
            let cityGroup = IMCityGroup(fromJson:JSON(cityDict))
            cityGroups.append(cityGroup)
        }
    }
    
    @objc fileprivate func clickBackItem() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cityGroups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityGroups[section].citys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        cell?.textLabel?.text = cityGroups[indexPath.section].citys[indexPath.row]
        return cell!
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cityGroups[section].title
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = [String]()
        for cityGroup in cityGroups {
            titles.append(cityGroup.title)
        }
        return titles
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cityName = cityGroups[indexPath.section].citys[indexPath.row]
        cityDelegate?.changeCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
    }
}
