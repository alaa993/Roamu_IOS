//
//  RequestsViewController.swift
//  Taxi
//
//  Created by Bhavin on 07/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire

enum RequestView: String {
    case pending
    case accepted
    case completed
    case cancelled
    case requested
    case waited
    case searchTravel
    case promo
    case all_requests
}

class RequestsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var tableView: UITableView!
    //    @IBOutlet var FromLabel: UILabel!
    //    @IBOutlet var ToLabel: UILabel!
    //    @IBOutlet var DateLabel: UILabel!
    //    @IBOutlet var DriverNameLabel: UILabel!
    @IBOutlet var LabelReq: UILabel!
    @IBOutlet var TextFieldReqType: UITextField!
    
    var requestPage:RequestView?
    var rides = [Ride]()
    var travels = [Travel]()
    var promos = [Promo]()
    var SearchData = [String:String]()
    
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: "All","PENDING","ACCEPTED","COMPLETED","CANCELLED","REQUESTED","WAITED")//["Yes","No"]
    var PlatformString = "All"
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- View Controller Life Cycle
    //------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        if requestPage == RequestView.searchTravel{
            requestPage = RequestView.searchTravel
        }
        else if requestPage == RequestView.promo{
            requestPage = RequestView.promo
        }
        else if requestPage == RequestView.all_requests{
            //            requestPage = RequestView.all_requests
            LabelReq.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            self.TextFieldReqType.cornerRadius(radius: 20.0, andPlaceholderString: "All")
            self.TextFieldReqType.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldReqType.frame.height))
            self.TextFieldReqType.text = PlatformString
            //            loadRequests(with: "All")
        }
        else{
            //            requestPage = RequestView.all_requests
            LabelReq.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            self.TextFieldReqType.cornerRadius(radius: 20.0, andPlaceholderString: "PENDING")
            self.TextFieldReqType.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldReqType.frame.height))
            self.TextFieldReqType.text = PlatformString
            //            loadRequests(with: "All")
        }
        
        if requestPage == RequestView.searchTravel
        {
            let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(RequestsViewController.cancelWasClicked(_:)))
            self.navigationItem.leftBarButtonItem = backButton
        }
        else
        {
            if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                // Here menuViewController is SideDrawer ViewCOntroller
                let sidemenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
                revealViewController().rightViewController = sidemenuViewController
                self.revealViewController().rightViewRevealWidth = self.view.frame.width * 0.8
                let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                                 style: .plain, target: SWRevealViewController(),
                                                 action: #selector(SWRevealViewController.rightRevealToggle(_:)))
                self.navigationItem.leftBarButtonItem = menuButton
            }
            else{
                if let revealController = self.revealViewController() {
                    revealController.panGestureRecognizer()
                    let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                                     style: .plain, target: revealController,
                                                     action: #selector(SWRevealViewController.revealToggle(_:)))
                    self.navigationItem.leftBarButtonItem = menuButton
                    
                }
            }
        }
        PlatformPicker.delegate = self
        createPlatformPicker()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // -- call api according to requests --
        if requestPage == RequestView.all_requests{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCAllTitle", comment: "")
            loadRequests(with: "All")
        }
        if requestPage == RequestView.accepted{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCAcceptTitle", comment: "")
            loadRequests(with: "ACCEPTED")
        } else if requestPage == RequestView.pending{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCPendingTitle", comment: "")
            loadRequests(with: "PENDING")
        } else if requestPage == RequestView.waited{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCPendingTitle", comment: "")
            loadRequests(with: "WAITED")
        }else if requestPage == RequestView.completed{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCCompletedTitle", comment: "")
            loadRequests(with: "COMPLETED")
        } else if requestPage == RequestView.cancelled{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCCancelledTitle", comment: "")
            loadRequests(with: "CANCELLED")
        }
        else if requestPage == RequestView.requested{
            LabelReq.isHidden = false
            TextFieldReqType.isHidden = false
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCWaitedTitle", comment: "")
            loadRequests(with: "REQUESTED")
        }
        else if requestPage == RequestView.searchTravel{
            LabelReq.isHidden = true
            TextFieldReqType.isHidden = true
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCSearchTitle", comment: "")
            loadRequests(with: "searchTravel")
        }
        else if requestPage == RequestView.promo{
            LabelReq.isHidden = true
            TextFieldReqType.isHidden = true
            self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCPromosTitle", comment: "")
            loadRequests(with: "promo")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPlatformPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        TextFieldReqType.inputAccessoryView = toolBar;
        TextFieldReqType.inputView = PlatformPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
    }
    
    @objc func donePlatformButton (){
        self.TextFieldReqType.text = PlatformString//"Yes"
        switch PlatformString {
        case "All":
            self.requestPage = RequestView.all_requests
        case "PENDING":
            self.requestPage = RequestView.pending
        case "ACCEPTED":
            self.requestPage = RequestView.accepted
        case "COMPLETED":
            self.requestPage = RequestView.completed
        case "CANCELLED":
            self.requestPage = RequestView.cancelled
        case "REQUESTED":
            self.requestPage = RequestView.requested
        case "WAITED":
            self.requestPage = RequestView.waited
        default:
            self.requestPage = RequestView.pending
        }
        loadRequests(with: PlatformString)
        self.view.endEditing(true)
        PlatformPicker.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //        return SmokedPickerData.count
        return PlatformPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PlatformString = PlatformPickerData[row]
        self.TextFieldReqType.text = PlatformPickerData[row]
        //        switch PlatformPickerData[row] {
        //        case "All":
        //            self.requestPage = RequestView.all_requests
        //        case "PENDING":
        //        self.requestPage = RequestView.pending
        //        case "ACCEPTED":
        //        self.requestPage = RequestView.accepted
        //        case "COMPLETED":
        //        self.requestPage = RequestView.completed
        //        case "CANCELLED":
        //        self.requestPage = RequestView.cancelled
        //        case "REQUESTED":
        //        self.requestPage = RequestView.requested
        //        default:
        //        self.requestPage = RequestView.pending
        //        }
        //        loadRequests(with: PlatformString)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return PlatformPickerData[row]
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- API
    //------------------------------------------------------------------------------------------------------------------------------------------
    
    func loadRequests(with status:String){
        print(status)
        if status == "searchTravel"
        {
            print("ibrahim")
            print("loadRequests")
            print(SearchData["car_type"])
            let params = ["pickup_address":SearchData["PickupAddress"]! ,
                          "drop_address":SearchData["DropAddress"]! ,
                          //"travel_time":SearchData["travel_time"]!
                "pickup_location": SearchData["pickupLocation"]!,
                "drop_location":SearchData["DropLocation"]!,
                "travel_date":SearchData["travel_date"]! ,
                "booked_set":SearchData["NoPassengers"]! ,
                "car_type":SearchData["car_type"]! ,
                "smoked":SearchData["Smoked"]! ]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            //            print("ttttt",params)
            print("ibrahim")
            print(params)
            Alamofire.request(APIRouters.GetTravels2(params,headers)).responseObject{ (response: DataResponse<Travels>) in
                HUD.hide(to: self.view)
                if response.result.isSuccess{
                    print(response)
                    if response.result.value?.status == true , ((response.result.value?.travels) != nil) {
                        self.travels = (response.result.value?.travels)!
                        print(response)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                    }
                }
            }
        }
        else if status == "promo"
        {
            let params = ["dummyParameter":"1"]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            Alamofire.request(APIRouters.GetPromo(params,headers)).responseObject { (response: DataResponse<Promos>) in
                HUD.hide(to: self.view)
                if response.result.isSuccess{
                    if response.result.value?.status == true , ((response.result.value?.promos) != nil) {
                        self.promos = (response.result.value?.promos)!
                        print(response)
                        //                        print("test test")
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                    }
                }
            }
        }
        else
        {
            let params = ["id":Common.instance.getUserId(),"status":status,"utype":"0"]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            
            HUD.show(to: view)
            _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
                HUD.hide(to: self.view)
                if response.result.isSuccess{
                    if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                        self.rides = (response.result.value?.rides)!
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
    
}

//----------------------------------------------------------------------------------------------------------------------------------------------
// MARK:- Extensions
//----------------------------------------------------------------------------------------------------------------------------------------------
extension RequestsViewController: UITableViewDelegate,UITableViewDataSource {
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- TableView Delegates And Datasources
    //------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestPage == RequestView.searchTravel
        {
            return travels.count
        }
        else if requestPage == RequestView.promo
        {
            return promos.count
        }
        //else
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        
        if requestPage == RequestView.searchTravel
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
            
            cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
            cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
            cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
            cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_DriverNamelbl", comment: "")
            cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            cell.CarTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_CarType", comment: "")
            
            
            // -- get current Rides Object --
            let currentObj = travels[indexPath.row]
            
            // -- set driver name to cell --
            cell.name.text = currentObj.driverName
            cell.CarType.text = currentObj.car_type
            cell.ReqTypeVal.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCSearchlbl", comment: "")
            
            // -- set date and time to cell --
            //            cell.dateLabel.text = currentObj.travel_date
            //            cell.timeLabel.text = currentObj.travel_time
            let currentDate = currentObj.travel_date
            //let date = Common.instance.getFormattedDate(date: currentDate).components(separatedBy: "-")
            let currentTime = currentObj.travel_time
            print("ibrahim was here")
            print(currentObj.travel_time)
            
            let date = Common.instance.getFormattedDateOnly(date: currentDate)
            let time = Common.instance.getFormattedTimeOnly(date: currentTime)
            cell.dateLabel.text = date
            let inFormatter = DateFormatter()
            inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            inFormatter.dateFormat = "HH:mm:ss"
            
            let outFormatter = DateFormatter()
            outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            outFormatter.dateFormat = "HH:mm"
            
            let date_ = inFormatter.date(from: time)!
            let outStr = outFormatter.string(from: date_)
            
            cell.timeLabel.text = outStr
            
            // -- set pickup location --
            let origin = currentObj.pickupAddress.components(separatedBy: ",")
            if origin.count > 1{
                cell.streetFrom.text = origin.first
                var addr = origin.dropFirst().joined(separator: ", ")
                cell.detailAdrsFrom.text = String(addr.dropFirst())
            } else {
                cell.streetFrom.text = origin.first
                cell.detailAdrsFrom.text = ""
            }
            
            // -- set drop location --
            let destination = currentObj.dropAddress.components(separatedBy: ",")
            if destination.count > 1{
                cell.streetTo.text = destination.first
                var addr = destination.dropFirst().joined(separator: ", ")
                cell.detailAdrsTo.text = String(addr.dropFirst())
            } else {
                cell.streetTo.text = destination.first
                cell.detailAdrsTo.text = ""
            }
        }
        else if requestPage == RequestView.promo
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
            
            
            cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
            cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
            cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
            cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_DriverNamelbl", comment: "")
            cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            
            // -- get current Rides Object --
            let currentObj = promos[indexPath.row]
            
            // -- set driver name to cell --
            cell.name.text = currentObj.promo_code
        }
        else
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
            
            cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
            cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
            cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
            cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_DriverNamelbl", comment: "")
            cell.ReqTypelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsVCReqlbl", comment: "")
            
            // -- get current Rides Object --
            let currentObj = rides[indexPath.row]
            
            // -- set driver name to cell --
            cell.name.text = currentObj.driverName
            cell.ReqTypeVal.text = currentObj.status
            
            // -- set date and time to cell --
            ///************************************
            let currentDate = currentObj.date
            let currentTime = currentObj.time
            ///************************************
            //let date = Common.instance.getFormattedDate(date: currentDate).components(separatedBy: "-")
            let date = Common.instance.getFormattedDateOnly(date: currentDate)
            let time = Common.instance.getFormattedTimeOnly(date: currentTime)
            cell.dateLabel.text = date
            let inFormatter = DateFormatter()
            inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            inFormatter.dateFormat = "HH:mm:ss"
            
            let outFormatter = DateFormatter()
            outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            outFormatter.dateFormat = "HH:mm"
            
            let date_ = inFormatter.date(from: time)!
            let outStr = outFormatter.string(from: date_)
            
            cell.timeLabel.text = outStr
            
            // -- set pickup location --
            let origin = currentObj.pickupAdress.components(separatedBy: ",")
            if origin.count > 1{
                cell.streetFrom.text = origin.first
                var addr = origin.dropFirst().joined(separator: ", ")
                cell.detailAdrsFrom.text = String(addr.dropFirst())
            } else {
                cell.streetFrom.text = origin.first
                cell.detailAdrsFrom.text = ""
            }
            
            // -- set drop location --
            let destination = currentObj.dropAdress.components(separatedBy: ",")
            if destination.count > 1{
                cell.streetTo.text = destination.first
                var addr = destination.dropFirst().joined(separator: ", ")
                cell.detailAdrsTo.text = String(addr.dropFirst())
            } else {
                cell.streetTo.text = destination.first
                cell.detailAdrsTo.text = ""
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if requestPage == RequestView.searchTravel
        {
            // -- move to next view --
            let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
            vcConfirm.confirmRequestPage = confirmRequestView.RequestsViewController
            vcConfirm.rideData = ["pickup": travels[indexPath.row].pickupAddress,
                                  "drop": travels[indexPath.row].dropAddress,
                                  "pickupLocation": travels[indexPath.row].pickLocation,
                                  "dropLocation": travels[indexPath.row].dropLocation,
                                  "driverName": travels[indexPath.row].driverName,
                                  "driverCity": travels[indexPath.row].driverCity,
                                  "driverVehicle": travels[indexPath.row].driverVehicle,
                                  "mobileNum":travels[indexPath.row].driverMobile,
                                  "vehicle":travels[indexPath.row].driverVehicle,
                                  "smoked":travels[indexPath.row].smoked,
                                  "passengers":travels[indexPath.row].available_set,
                                  "empty_set":travels[indexPath.row].empty_set as? String ?? "0",
                                  "driver_id": travels[indexPath.row].driverId,
                                  "travel_id": travels[indexPath.row].travel_id,
                                  "amount" : travels[indexPath.row].amount,
                                  "time" : travels[indexPath.row].travel_time,
                                  "date" : travels[indexPath.row].travel_date,
                                  "model" : travels[indexPath.row].model,
                                  "color" : travels[indexPath.row].color,
                                  "vehicle_no" : travels[indexPath.row].vehicle_no,
                                  "pickup_point" : travels[indexPath.row].pickup_point,
                                  "DriverRate" : travels[indexPath.row].DriverRate,
                                  "FareRate" : travels[indexPath.row].FareRate,
                                  "Travels_Count" : travels[indexPath.row].Travels_Count,
                                  "booked_set": SearchData["NoPassengers"]!]
//                        print(configs.hostUrl + travels[indexPath.row].avatar)
//                        print(configs.hostUrl + travels[indexPath.row].vehicle_info)
//                        vcConfirm.DriverAvatarURL = configs.hostUrlImage + travels[indexPath.row].avatar
//                        vcConfirm.DriverAvatarURL = configs.hostUrlImage + travels[indexPath.row].avatar
//                        vcConfirm.DriverCarURL = configs.hostUrlImage + travels[indexPath.row].vehicle_info
            vcConfirm.DriverAvatarURL = travels[indexPath.row].avatar
            vcConfirm.DriverCarURL = travels[indexPath.row].driverVehicle
            self.navigationController?.pushViewController(vcConfirm, animated: true)
            
        }
        else if requestPage == RequestView.promo
        {
            
        }
        else if requestPage == RequestView.waited
        {
            requestPage = RequestView.waited
            self.TextFieldReqType.text = "WAITED"
            
            let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
            vcConfirm.confirmRequestPage = confirmRequestView.waited
            vcConfirm.rideData = ["pickup": rides[indexPath.row].pickupAdress,
                                  "drop": rides[indexPath.row].dropAdress,
                                  "pickupLocation": rides[indexPath.row].pickLocation,
                                  "dropLocation": rides[indexPath.row].dropLocation,
                                  "driverName": rides[indexPath.row].driverName,
                                  "driverCity": rides[indexPath.row].driverCity,
                                  "driverVehicle": rides[indexPath.row].vehicle_no,
                                  "mobileNum":rides[indexPath.row].driverMobile,
                                  "vehicle":rides[indexPath.row].vehicle_no,
                                  "smoked":rides[indexPath.row].Ridesmoked,
                                  "passengers":rides[indexPath.row].avalableSet,
                                  "empty_set":rides[indexPath.row].emptySet as? String ?? "0",
                                  "driver_id": rides[indexPath.row].driverId,
                                  "travel_id": rides[indexPath.row].travelId,
                                  "ride_id" : rides[indexPath.row].rideId,
                                  "amount" : rides[indexPath.row].amount,
                                  "time" : rides[indexPath.row].time,
                                  "date" : rides[indexPath.row].date,
                                  "model" : rides[indexPath.row].model,
                                  "color" : rides[indexPath.row].color,
                                  "vehicle_no" : rides[indexPath.row].vehicle_no,
                                  "pickup_point" : rides[indexPath.row].pickup_point,
                                  "DriverRate" : rides[indexPath.row].DriverRate,
                                  "FareRate" : rides[indexPath.row].FareRate,
                                  "Travels_Count" : rides[indexPath.row].Travels_Count,
                                  "booked_set": rides[indexPath.row].bookedSeat]
            //            print(configs.hostUrl + travels[indexPath.row].avatar)
            //            print(configs.hostUrl + travels[indexPath.row].vehicle_info)
            //            vcConfirm.DriverAvatarURL = configs.hostUrlImage + travels[indexPath.row].avatar
            //            vcConfirm.DriverAvatarURL = configs.hostUrlImage + travels[indexPath.row].avatar
            //            vcConfirm.DriverCarURL = configs.hostUrlImage + travels[indexPath.row].vehicle_info
            vcConfirm.DriverAvatarURL = rides[indexPath.row].driverAvatar
            vcConfirm.DriverCarURL = rides[indexPath.row].vehicle_info
            self.navigationController?.pushViewController(vcConfirm, animated: true)
        }
        else
        {
            if rides[indexPath.row].status == "WAITED"
            {
                requestPage = RequestView.waited
                self.TextFieldReqType.text = "WAITED"
                
                let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
                vcConfirm.confirmRequestPage = confirmRequestView.waited
                vcConfirm.rideData = ["pickup": rides[indexPath.row].pickupAdress,
                                      "drop": rides[indexPath.row].dropAdress,
                                      "pickupLocation": rides[indexPath.row].pickLocation,
                                      "dropLocation": rides[indexPath.row].dropLocation,
                                      "driverName": rides[indexPath.row].driverName,
                                      "driverCity": rides[indexPath.row].driverCity,
                                      "driverVehicle": rides[indexPath.row].vehicle_no,
                                      "mobileNum":rides[indexPath.row].driverMobile,
                                      "vehicle":rides[indexPath.row].vehicle_no,
                                      "smoked":rides[indexPath.row].Ridesmoked,
                                      "passengers":rides[indexPath.row].avalableSet,
                                      "empty_set":rides[indexPath.row].emptySet as? String ?? "0",
                                      "driver_id": rides[indexPath.row].driverId,
                                      "travel_id": rides[indexPath.row].travelId,
                                      "ride_id" : rides[indexPath.row].rideId,
                                      "amount" : rides[indexPath.row].amount,
                                      "time" : rides[indexPath.row].time,
                                      "date" : rides[indexPath.row].date,
                                      "model" : rides[indexPath.row].model,
                                      "color" : rides[indexPath.row].color,
                                      "vehicle_no" : rides[indexPath.row].vehicle_no,
                                      "pickup_point" : rides[indexPath.row].pickup_point,
                                      "DriverRate" : rides[indexPath.row].DriverRate,
                                      "FareRate" : rides[indexPath.row].FareRate,
                                      "Travels_Count" : rides[indexPath.row].Travels_Count,
                                      "booked_set": rides[indexPath.row].bookedSeat]
                //            print(configs.hostUrl + travels[indexPath.row].avatar)
                //            print(configs.hostUrl + travels[indexPath.row].vehicle_info)
                //            vcConfirm.DriverAvatarURL = configs.hostUrlImage + travels[indexPath.row].avatar
                //            vcConfirm.DriverAvatarURL = configs.hostUrlImage + travels[indexPath.row].avatar
                //            vcConfirm.DriverCarURL = configs.hostUrlImage + travels[indexPath.row].vehicle_info
                vcConfirm.DriverAvatarURL = rides[indexPath.row].driverAvatar
                vcConfirm.DriverCarURL = rides[indexPath.row].vehicle_info
                self.navigationController?.pushViewController(vcConfirm, animated: true)
            }
            else{
                // -- push to detail view with required data --
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
                //            vc.requestPage = requestPage
                vc.rideDetail = rides[indexPath.row]
                
                if rides[indexPath.row].status == "PENDING"
                {
                    requestPage = RequestView.pending
                    self.TextFieldReqType.text = "PENDING"
                }
                if rides[indexPath.row].status == "ACCEPTED"
                {
                    requestPage = RequestView.accepted
                    self.TextFieldReqType.text = "ACCEPTED"
                }
                if rides[indexPath.row].status == "COMPLETED"
                {
                    requestPage = RequestView.completed
                    self.TextFieldReqType.text = "COMPLETED"
                }
                if rides[indexPath.row].status == "CANCELLED"
                {
                    requestPage = RequestView.cancelled
                    self.TextFieldReqType.text = "CANCELLED"
                }
                if rides[indexPath.row].status == "REQUESTED"
                {
                    requestPage = RequestView.requested
                    self.TextFieldReqType.text = "REQUESTED"
                }
                vc.requestPage = requestPage
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
}
