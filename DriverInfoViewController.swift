//
//  DriverInfoViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 8/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

class DriverInfoViewController: UIViewController {
    
    var DriverData = [String:Any]()
    var drivers = [Driver]()
    
    @IBOutlet var driverName: UILabel!
    @IBOutlet var Mobile_Num: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var vehicle: UILabel!
    @IBOutlet var model: UILabel!
    @IBOutlet var color: UILabel!
    @IBOutlet var OnlineStatus: UILabel!
    
    
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var MobileNlbl: UILabel!
    @IBOutlet var emaillbl: UILabel!
    @IBOutlet var countrylbl: UILabel!
    @IBOutlet var citylbl: UILabel!
    @IBOutlet var vehiclelbl: UILabel!
    @IBOutlet var modellbl: UILabel!
    @IBOutlet var colorlbl: UILabel!
    @IBOutlet var onLineStatuslbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(DriverInfoViewController.cancelWasClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_title", comment: "")
        driverName.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_driverName", comment: "")
        Mobile_Num.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Mobile_Num", comment: "")
        email.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_email", comment: "")
        country.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_country", comment: "")
        city.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_city", comment: "")
        vehicle.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_vehicle", comment: "")
        model.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_model", comment: "")
        color.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_color", comment: "")
        OnlineStatus.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_OnlineStatus", comment: "")
        
        loadDriverInfo()

        // Do any additional setup after loading the view.
    }
    
    @objc func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func loadDriverInfo(){
        
        let params = ["driver_id" : DriverData["driver_id"]!]
        let headers = ["X-API-KEY" : Common.instance.getAPIKey()]
        
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getDriverInfo(params,headers)).responseObject { (response: DataResponse<Drivers>) in
            HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.drivers) != nil) {
                    self.drivers = (response.result.value?.drivers)!
                    self.Namelbl.text = self.drivers[0].name
                    self.MobileNlbl.text = self.drivers[0].mobile
                    self.emaillbl.text = self.drivers[0].email
                    self.countrylbl.text = self.drivers[0].country
                    self.citylbl.text = self.drivers[0].city
                    self.vehiclelbl.text = self.drivers[0].vehicle
                    self.modellbl.text = self.drivers[0].model
                    self.colorlbl.text = self.drivers[0].color
                    
                    if self.drivers[0].onlineStatus == "1"{
                        self.onLineStatuslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Online", comment: "")
                        self.onLineStatuslbl.textColor = .green
                    }
                    else{
                        self.onLineStatuslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DriverInfoVC_Offline", comment: "")
                        self.onLineStatuslbl.textColor = .red
                    }
                    DispatchQueue.main.async {
                    }
                } else {
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }


}
