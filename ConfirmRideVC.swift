//
//  ConfirmRideVC.swift
//  Taxi
//
//  Created by Bhavin on 14/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import Alamofire
import MapKit
import GooglePlaces

enum confirmRequestView: Int {
    case RequestsViewController
    case MapViewController
    case PlatformViewController
    case waited
}

class ConfirmRideVC: UIViewController, isAbleToReceiveData {
    var confirmRequestPage:confirmRequestView?
    @IBOutlet var DriverAvatar: UIImageView!
    @IBOutlet var DriverCar: UIImageView!
    @IBOutlet var driverName: UILabel!
    @IBOutlet var driverCity: UILabel!
    @IBOutlet var vehicle: UILabel!
    @IBOutlet var pickupLocation: UILabel!
    @IBOutlet var dropLocation: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var fare: UILabel!
    @IBOutlet var VechileColor: UILabel!
    @IBOutlet var DriverRate: UILabel!
    @IBOutlet var empty_Set_var: UILabel!
    @IBOutlet var Travels_Count: UILabel!
    @IBOutlet var PickUpPoint: UILabel!
    @IBOutlet var VechileNo: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var FareRate: UILabel!
    
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var Citylbl: UILabel!
    @IBOutlet var PickupAddlbl: UILabel!
    @IBOutlet var DropAddlbl: UILabel!
    @IBOutlet var Farelbl: UILabel!
    @IBOutlet var Vehiclelbl: UILabel!
    @IBOutlet var VehicleColorlbl: UILabel!
    @IBOutlet var DriverRatelbl: UILabel!
    @IBOutlet var EmptySetlbl: UILabel!
    @IBOutlet var Timelbl: UILabel!
    @IBOutlet var travelsCountlbl: UILabel!
    @IBOutlet var PickupPointlbl: UILabel!
    @IBOutlet var VechileNolbl: UILabel!
    @IBOutlet var datelbl: UILabel!
    @IBOutlet var FareRatelbl: UILabel!
    @IBOutlet var Commentslbl: UILabel!
    @IBOutlet var Noteslbl: UILabel!
    
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var ShowDriverInfoButton: UIButton!
    
    @IBOutlet var mapView: GMSMapView!
    
    // -- Instance Variables --
    var mapTasks = MapTasks()
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var rideData = [String:String]()
    var DriverAvatarURL:String = ""
    var DriverCarURL:String = ""
    var rideFare:Fare?
    var ride:NearBy?
    var totalDistance:Double = 0.0
    var TextFieldPlatform2: UITextField!
    var enteredText = "1"
    var bagsNotes = ""
    var travel_id_var:String = "0"
    var travels = [Travel]()
    var rides = [Ride]()
    
    var isPickupPoint = Bool()
    var pickupPointLocation = ""
    var pickUpPoint = ""
    var TextFieldPickupPoint: UITextField!
    var TextFieldPickupPoint_location: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Request Ride",comment: "")
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backWasPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTitle", comment: "")
        
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        Citylbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCCitylbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        Farelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCFarelbl", comment: "")
        Timelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTimelbl", comment: "")//
        Vehiclelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_Vehiclelbl", comment: "")
        VehicleColorlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_VColorlbl", comment: "")
        DriverRatelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDriverRatelbl", comment: "")
        EmptySetlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCEmptySetlbl", comment: "")
        travelsCountlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTravelsCountlbl", comment: "")
        PickupPointlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupPointlbl", comment: "")
        
        VechileNolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCVechileNolbl", comment: "")
        datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCdatelbl", comment: "")
        FareRatelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCFareRatelbl", comment: "")
        Commentslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCCommentslbl", comment: "")
        Noteslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "notes", comment: "")
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCCommentslbl", comment: ""), attributes: underlineAttribute)
        Commentslbl.attributedText = underlineAttributedString
        self.setupLabelTap()
        
        let underlineAttribute1 = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString1 = NSAttributedString(string: LocalizationSystem.sharedInstance.localizedStringForKey(key: "notes", comment: ""), attributes: underlineAttribute1)
        Noteslbl.attributedText = underlineAttributedString1
        self.setupLabelTap1()
        
        confirmButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_reserveButton", comment: ""), for: .normal)
        cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
        ShowDriverInfoButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_ShowDriverInfoButton", comment: ""), for: .normal)
        
        if confirmRequestPage == confirmRequestView.RequestsViewController || confirmRequestPage == confirmRequestView.PlatformViewController
        {
            
            ShowDriverInfoButton.isHidden = false
        }
        else if confirmRequestPage == confirmRequestView.waited
        {
            ShowDriverInfoButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if confirmRequestPage == confirmRequestView.RequestsViewController
        {
            driverName.text = rideData["driverName"] as? String//ride?.userId
            driverCity.text = rideData["driverCity"] as? String
            pickupLocation.text = rideData["pickup"] as? String
            dropLocation.text = rideData["drop"] as? String
            //            vehicle.text = rideData["driverVehicle"] as? String
            //            vehicle.text = rideData["vehicle"] as? String
            empty_Set_var.text = rideData["empty_set"] as? String
            let inFormatter = DateFormatter()
            inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            inFormatter.dateFormat = "HH:mm:ss"
            
            let outFormatter = DateFormatter()
            outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            outFormatter.dateFormat = "HH:mm"
            
            let date_ = inFormatter.date(from: (rideData["time"] as? String)!)!
            let outStr = outFormatter.string(from: date_)
            
            time.text = outStr
            VechileColor.text = rideData["color"] as? String
            vehicle.text = rideData["model"] as? String
            PickUpPoint.text = rideData["pickup_point"] as? String
            DriverRate.text = rideData["DriverRate"] as? String
            Travels_Count.text = rideData["Travels_Count"] as? String//driver_id
            
            VechileNo.text = rideData["vehicle_no"] as? String
            date.text = rideData["date"] as? String
            FareRate.text = rideData["FareRate"] as? String
            fare.text = rideData["amount"] as? String
            
            print("ibrahim_DriverAvatarURL")
            print(DriverAvatarURL)
            print("ibrahim_DriverCarURL")
            print(DriverCarURL)
            // by ibrahim
            if let urlString = URL(string: (DriverAvatarURL)){
                DriverAvatar.kf.setImage(with: urlString)
            }
            if let urlString1 = URL(string: (DriverCarURL)){
                DriverCar.kf.setImage(with: urlString1)
            }
        }
        else if confirmRequestPage == confirmRequestView.waited
        {
            confirmButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_confirmButton", comment: ""), for: .normal)
            driverName.text = rideData["driverName"] as? String//ride?.userId
            driverCity.text = rideData["driverCity"] as? String
            pickupLocation.text = rideData["pickup"] as? String
            dropLocation.text = rideData["drop"] as? String
            //            vehicle.text = rideData["driverVehicle"] as? String
            //            vehicle.text = rideData["vehicle"] as? String
            empty_Set_var.text = rideData["empty_set"] as? String
            let inFormatter = DateFormatter()
            inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            inFormatter.dateFormat = "HH:mm:ss"
            
            let outFormatter = DateFormatter()
            outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            outFormatter.dateFormat = "HH:mm"
            
            let date_ = inFormatter.date(from: (rideData["time"] as? String)!)!
            let outStr = outFormatter.string(from: date_)
            
            time.text = outStr
            VechileColor.text = rideData["color"] as? String
            vehicle.text = rideData["model"] as? String
            PickUpPoint.text = rideData["pickup_point"] as? String
            DriverRate.text = rideData["DriverRate"] as? String
            Travels_Count.text = rideData["Travels_Count"] as? String//driver_id
            
            VechileNo.text = rideData["vehicle_no"] as? String
            date.text = rideData["date"] as? String
            FareRate.text = rideData["FareRate"] as? String
            fare.text = rideData["amount"] as? String
            
            // by ibrahim
            if let urlString = URL(string: (DriverAvatarURL)){
                print("ibrahim")
                print(DriverAvatarURL)
                DriverAvatar.kf.setImage(with: urlString)
            }
            if let urlString1 = URL(string: (DriverCarURL)){
                DriverCar.kf.setImage(with: urlString1)
                print("ibrahim")
                print(DriverCarURL)
            }
        }
        else if confirmRequestPage == confirmRequestView.MapViewController
        {
            if let rideDetail = rideData["rideInfo"] as? NearBy {
                ride = rideDetail
                driverName.text = rideDetail.name
                vehicle.text = rideDetail.vehicle
                //                distance.text = rideDetail.distance + " km"
            }
            if let ridefare = rideData["fare"] as? Fare {
                rideFare = ridefare
                self.fare.text =   String(format: "%.2f", (self.totalDistance * Double((self.rideFare?.cost)!)!)) + " " + ridefare.unit
            }
            
            pickupLocation.text = rideData["pickup"] as? String
            dropLocation.text = rideData["drop"] as? String
        }
        else if confirmRequestPage == confirmRequestView.PlatformViewController
        {
            print("ibrahim travel_id")
            print(travel_id_var)
            let params = ["travel_id": travel_id_var]
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            //            print("ttttt",params)
            print("ibrahim")
            Alamofire.request(APIRouters.travels3_get(params,headers)).responseObject{ (response: DataResponse<Travels>) in
                HUD.hide(to: self.view)
                if response.result.isSuccess{
                    print(response)
                    if (response.result.value?.status == true && (response.result.value?.travels) != nil) {
                        self.travels = (response.result.value?.travels)!
                        // self.rides = (response.result.value?.rides)!
                        if( self.travels.isEmpty)
                        {
                            print("ibrahim123")
                            //                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
                            //                            self.navigationController?.pushViewController(vc, animated: true)
                            _ = self.navigationController?.popViewController(animated: true)
                            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                            
                        }else{
                            self.driverName.text = self.travels[0].driverName
                            self.driverCity.text = self.travels[0].driverCity
                            self.pickupLocation.text = self.travels[0].pickupAddress
                            self.dropLocation.text = self.travels[0].dropAddress
                            self.empty_Set_var.text = self.travels[0].empty_set
                            
                            let inFormatter = DateFormatter()
                            inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                            inFormatter.dateFormat = "HH:mm:ss"
                            
                            let outFormatter = DateFormatter()
                            outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
                            outFormatter.dateFormat = "HH:mm"
                            
                            let date_ = inFormatter.date(from: (self.travels[0].travel_time))
                            let outStr = outFormatter.string(from: date_!)
                            
                            self.time.text = outStr
                            self.VechileColor.text = self.travels[0].color
                            self.vehicle.text = self.travels[0].model
                            self.PickUpPoint.text = self.travels[0].pickup_point
                            self.DriverRate.text = self.travels[0].DriverRate
                            self.Travels_Count.text = self.travels[0].Travels_Count
                            self.VechileNo.text = self.travels[0].vehicle_no
                            self.date.text = self.travels[0].travel_date
                            self.FareRate.text = self.travels[0].FareRate
                            self.fare.text = self.travels[0].amount
                            self.rideData["empty_set"] = self.travels[0].empty_set
                            // by ibrahim
                            if let urlString = URL(string: (self.travels[0].avatar)){
                                print("ibrahim")
                                print(urlString)
                                self.DriverAvatar.kf.setImage(with: urlString)
                            }
                            if let urlString1 = URL(string: (self.travels[0].vehicle_info)){
                                self.DriverCar.kf.setImage(with: urlString1)
                                print("ibrahim")
                                print(urlString1)
                            }
                            print(response)
                        }} else {
                        _ = self.navigationController?.popViewController(animated: true)
                        Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: "No data found.", for: self)
                        print("ibrahim456")
                        //                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
                        //                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        //        getDirections()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeWasClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupLabelTap() {
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.Commentslbl.isUserInteractionEnabled = true
        self.Commentslbl.addGestureRecognizer(labelTap)
        
    }
    
    func setupLabelTap1() {
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped1(_:)))
        self.Noteslbl.isUserInteractionEnabled = true
        self.Noteslbl.addGestureRecognizer(labelTap)
        
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        print("labelTapped")
        if #available(iOS 11.0, *) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserCommentsViewController") as! UserCommentsViewController
            vc.postid = rideData["driver_id"] as? String//
            //vc.post.append(posts[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func labelTapped1(_ sender: UITapGestureRecognizer) {
        print("labelTapped")
        if #available(iOS 11.0, *) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TravelsNotesReqViewController") as! TravelsNotesReqViewController
            vc.travel_id = (rideData["travel_id"] as? String)!//
            //vc.post.append(posts[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func confirmWasClicked(_ sender: UIButton) {
        if confirmRequestPage == confirmRequestView.waited
        {
            sendRequests(with: "ACCEPTED")
            self.deletePost(with:self.rideData["ride_id"]! as! String)
        }
        else
        {
            openAlert()
        }
    }
    
    func openAlert() -> Bool{
        var alertController:UIAlertController?
        alertController = UIAlertController(title:
            NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Enter number of passengers", comment: ""),comment: ""),
                                            message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Enter number of passengers", comment: ""),comment: ""),
                                            preferredStyle: .alert)
        
        //0 pickup point
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                self.TextFieldPickupPoint = textField
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PickUpPoint", comment: ""),comment: "")
                textField.keyboardType = UIKeyboardType.default
                self.TextFieldPickupPoint.addTarget(self, action: #selector(self.pickupPointFunction), for: .touchDown)
        })
        
        //1 pickup location on map
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                self.TextFieldPickupPoint_location = textField
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "PickUpPoint_location", comment: ""),comment: "")
                textField.keyboardType = UIKeyboardType.default
                self.TextFieldPickupPoint_location.addTarget(self, action: #selector(self.pickupPoint_locationFunction), for: .touchDown)
        })
        
        //2 passengers number
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "number of passengers 1", comment: ""),comment: "")
                //                    textField.keyboardType = UIKeyboardType.numberPad
                //                    textField.keyboardType = UIKeyboardType.decimalPad
                textField.keyboardType = .asciiCapableNumberPad
        })
        
        //3 notes
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "notes_bags_weights", comment: ""),comment: "")
                //                textField.keyboardType = UIKeyboardType.numberPad
                textField.keyboardType = .default
                
        })
        
        let action = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Submit", comment: ""),comment: ""),
                                   style: UIAlertAction.Style.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        print(self!.rideData["empty_set"]!)
                                        let empty_set = self!.rideData["empty_set"]!
                                        let theTextFields = textFields as [UITextField]
                                        //
                                        if theTextFields[0].text!.count == 0
                                        {
                                            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self!)
                                            return
                                            
                                        }else{
                                            self?.pickUpPoint = theTextFields[0].text!
                                        }
                                        if theTextFields[2].text!.count == 0
                                        {
                                            print("ibrahim 1")
                                            self?.enteredText = "1"
                                        }
                                        else if Int(theTextFields[2].text!)! > Int(empty_set)!
                                        {
                                            print("ibrahim 2")
                                            Common.showAlert(with: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_Alert", comment: ""), comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_AlertDetail", comment: ""), comment: ""), for: self!)
                                        }
                                        else
                                        {
                                            print("ibrahim 3")
                                            self?.enteredText = theTextFields[2].text!
                                            self?.bagsNotes = theTextFields[3].text!
                                            self?.confirmRequest()
                                        }
                                        //
                                    }
        })
        let action2 = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""),comment: ""),
                                    style: UIAlertAction.Style.default,
                                    handler: {[weak self]
                                        (paramAction:UIAlertAction!) in
                                        
        })
        
        alertController?.addAction(action)
        alertController?.addAction(action2)
        self.present(alertController!,
                     animated: true,
                     completion: nil)
        return true
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        if confirmRequestPage == confirmRequestView.waited
        {
            sendRequests(with: "CANCELLED")
        }
        else
        {
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func pickupPointFunction(textField: UITextField) {
        isPickupPoint = true
        dismiss(animated: true, completion: nil)
        print("ibrahim auto complete")
        autocompleteClicked()
    }
    
    @objc func pickupPoint_locationFunction(textField: UITextField) {
        isPickupPoint = true
        dismiss(animated: true, completion: nil)
        GoogleSearchClicked()
        
    }
    
    @objc func backWasPressed(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func autocompleteClicked() {
        /* let SearchViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as!
         SearchViewController
         SearchViewController_.delegate = self
         SearchViewController_.modalPresentationStyle = .fullScreen
         self.present(SearchViewController_, animated: true, completion: nil)*/
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    func GoogleSearchClicked() {
        let GoogleSearchViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "GoogleSearchViewController") as! GoogleSearchViewController
        GoogleSearchViewController_.delegate = self
        GoogleSearchViewController_.modalPresentationStyle = .fullScreen
        self.present(GoogleSearchViewController_, animated: true, completion: nil)
    }
    
    func pass(ResultSearchDictionary: [String:Any]!) {
        
        if isPickupPoint{
            if openAlert(){
                self.TextFieldPickupPoint.text = (ResultSearchDictionary["title"] as! String)
                let pickupLat = ResultSearchDictionary["latitude"]!
                let pickupLog = ResultSearchDictionary["longitude"]!
                self.pickupPointLocation = "\(pickupLat),\(pickupLog)"
                self.TextFieldPickupPoint_location.text = "\(pickupLat),\(pickupLog)"
                isPickupPoint = false
                //                self.TextFieldTripPrice.text = self.TextFieldTripPrice.text
                //                self.TextFieldPassengersNum.text = self.TextFieldPassengersNum.text
                //                self.TextFieldPlatform2.text = self.TextFieldPlatform2.text
            }
        }
        
    }
    
    func getDirections(){
        mapTasks.getDirections(pickupLocation.text, destination: dropLocation.text, waypoints: nil, travelMode: nil) { (status, result, success) in
            if success {
                if let response = result {
                    self.configureMapAndMarkersForRoute(results: response)
                    self.totalDistance = response["distance"] as! Double
                    //                    self.distance.text = String(format: "%.2f", self.totalDistance) + " km"
                    if let polylines = response["polylines"] as? [String:Any],
                        let pts = polylines["points"] as? String{
                        self.drawRoute(points: pts)
                    }
                    self.fare.text =   String(format: "%.2f", (self.totalDistance * Double((self.rideFare?.cost)!)!)) + " " + (self.rideFare?.unit)!
                }
            } else {
                //print(status)
                //print(result?.description)
            }
        }
    }
    
    func confirmRequest(){
        if confirmRequestPage == confirmRequestView.RequestsViewController
        {
            // -- manage parameters --
            var parameters = [String:Any]()
            parameters["user_id"] = Common.instance.getUserId()
            parameters["travel_id"] = rideData["travel_id"]
            parameters["driver_id"] = rideData["driver_id"]//ride?.userId
            parameters["pickup_address"] = pickupLocation.text
            parameters["drop_address"] = dropLocation.text
            parameters["pickup_location"] = rideData["pickupLocation"]
            parameters["drop_location"] = rideData["dropLocation"]
            parameters["booked_set"] = enteredText
            parameters["ride_notes"] = self.bagsNotes
            
            parameters["distance"] = "0"
            parameters["amount"] = rideData["amount"]
            parameters["Ride_smoked"] = rideData["smoked"]
            //parameters["booked_set"] = rideData["booked_set"]
            parameters["time"] = rideData["time"]
            parameters["date"] = rideData["date"]
            parameters["car_type"] = rideData["car_type"]
            parameters["ride_pickup_point"] = self.pickUpPoint
            parameters["ride_pickup_point_location"] = self.pickupPointLocation
            
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.AddRide2(parameters, headers), success: { (response) in
                // -- hide loading --
                print(response)
                HUD.hide(to: self.view)
                // -- parse response --
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        if let data = response as? [String:Any] {
                            print("ibrahim rideid");
                            print(data["ride_id"]!);
                            print(data["driver_id"]!);
                            //1
                            self.updateAddRideFirebase(with:"PENDING", travel_status: "PENDING", ride_id:(data["ride_id"]! as! NSNumber).stringValue)
                            self.updateAddNotificationFirebase(with:"request", ride_id:(data["ride_id"]! as! NSNumber).stringValue, travel_id: self.rideData["travel_id"]!, user_id: self.rideData["driver_id"]!)
                            self.updateTravelCounterFirebase(with: "PENDING", travel_id: self.rideData["travel_id"]!)
                            
                            _ = self.navigationController?.popToRootViewController(animated: true)
                            //                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                            //                            vc.requestPage = RequestView.pending
                            //                            vc.PlatformString = "PENDING"
                            //                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
                print("success")
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
                print("failure")
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
                print("error")
            })
        }
        else if confirmRequestPage == confirmRequestView.PlatformViewController
        {
            // -- manage parameters --
            var parameters = [String:Any]()
            parameters["user_id"] = Common.instance.getUserId()
            parameters["travel_id"] = self.travels[0].travel_id
            parameters["driver_id"] = self.travels[0].driverId
            parameters["pickup_address"] = self.travels[0].pickupAddress
            parameters["drop_address"] = self.travels[0].dropAddress
            parameters["pickup_location"] = self.travels[0].pickLocation
            parameters["drop_location"] = self.travels[0].dropLocation
            parameters["booked_set"] = enteredText
            parameters["ride_notes"] = self.bagsNotes
            parameters["distance"] = "0"
            parameters["amount"] = self.travels[0].amount
            parameters["Ride_smoked"] = self.travels[0].smoked
            //parameters["booked_set"] = rideData["booked_set"]
            parameters["time"] = self.travels[0].travel_time
            parameters["date"] = self.travels[0].travel_date
            parameters["date"] = self.travels[0].car_type
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading --
            HUD.show(to: view)
            
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.AddRide2(parameters, headers), success: { (response) in
                // -- hide loading --
                print(response)
                HUD.hide(to: self.view)
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        if let data = response as? [String:Any] {
                            print("ibrahim rideid");
                            print(data["ride_id"]!);
                            //2
                            self.updateAddRideFirebase(with:"PENDING", travel_status: "PENDING", ride_id:(data["ride_id"]! as! NSNumber).stringValue)
                            self.updateAddNotificationFirebase(with:"request", ride_id:(data["ride_id"]! as! NSNumber).stringValue, travel_id: self.travels[0].travel_id, user_id: self.travels[0].driverId)
                            self.updateTravelCounterFirebase(with: "PENDING", travel_id: self.travels[0].travel_id)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
                print("success")
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
                print("failure")
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
                print("error")
            })
        }
    }
    
    func sendRequests(with status:String){
        let params = ["ride_id":rideData["ride_id"]!,"status":status,"by":"user"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        print("sendRequests")
        _ = Alamofire.request(APIRouters.UpdateRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
            HUD.hide(to: self.view)
            print("response")
            print(response)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides = (response.result.value?.rides)!
                    print("rides")
                    print(self.rides)
                    if self.rides[0].status == "REQUESTED"
                    {
                        print("requested")
                        let alert = UIAlertController(title: NSLocalizedString("",comment: ""), message: LocalizationSystem.sharedInstance.localizedStringForKey(key: "full_travel", comment: ""), preferredStyle: .alert)
                        
                        let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                            //                    self.backWasPressed()
                            //
                            self.handlePostButton(travel_id: self.rides[0].rideId )
                            //
                            _ = self.navigationController?.popToRootViewController(animated: true)
                        })
                        //3
                        self.updateAddRideFirebase(with:"REQUESTED", travel_status: "", ride_id: self.rideData["ride_id"]!)
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        print("requested else")
                        let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
                        
                        let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                            //                    self.backWasPressed()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
                            if status == "ACCEPTED"{
                                vc.requestPage = RequestView.accepted
                                vc.PlatformString = "ACCEPTED"
                                self.updateAddNotificationFirebase(with:"request_approve", ride_id: self.rideData["ride_id"]!, travel_id: self.rideData["travel_id"]!, user_id: self.rideData["driver_id"]!)
                            }
                            else if status == "CANCELLED"{
                                vc.requestPage = RequestView.cancelled
                                vc.PlatformString = "CANCELLED"
                                self.updateAddNotificationFirebase(with:status, ride_id: self.rideData["ride_id"]!, travel_id: self.rideData["travel_id"]!, user_id: self.rideData["driver_id"]!)
                            }
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                        //4
                        self.updateAddRideFirebase(with:status, travel_status: "", ride_id: self.rideData["ride_id"]!)
                        //                        self.updateAddNotificationFirebase(with:status, ride_id: self.rideData["ride_id"]!, travel_id: self.rideData["travel_id"]!, user_id: self.rideData["driver_id"]!)
                        alert.addAction(done)
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.updateTravelCounterFirebase(with: status, travel_id: self.rideData["travel_id"]!)
                }
                else{
                    Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("No data found.", comment: ""), for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!" ,comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    
    func updateTravelCounterFirebase(with status:String, travel_id:String) {
        print("updateTravelCounteR")
        print(status)
        if status == "ACCEPTED"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("ACCEPTED").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("ACCEPTED")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
        else if status == "COMPLETED"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("COMPLETED").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("COMPLETED")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
        else if status == "OFFLINE"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("OFFLINE").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("OFFLINE")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
        else if status == "PAID"{
            Database.database().reference().child("Travels").child(travel_id).child("Counters").child("PAID").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(travel_id).child("Counters").child("PAID")
                    postRef.setValue(data + 1, withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            })
        }
    }
    
    func updateAddRideFirebase(with status:String, travel_status:String, ride_id:String) {
        let postRef = Database.database().reference().child("rides").child(ride_id)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": status,
            "travel_status": travel_status,
            "payment_mode": "",
            "payment_status": ""] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
                
            } else {
            }
        })
    }
    
    func updateAddNotificationFirebase(with status:String, ride_id:String, travel_id:String, user_id:String) {
        let postRef = Database.database().reference().child("Notifications").child(user_id).childByAutoId()
        let postObject = [
            "ride_id": ride_id,
            "travel_id": travel_id,
            //            "text": LocalizationSystem.sharedInstance.localizedStringForKey(key: "Notification_accepted_request", comment: ""),
            "text": status,
            "readStatus": "0",
            "timestamp": [".sv":"timestamp"],
            "uid": Auth.auth().currentUser?.uid] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func handlePostButton(travel_id: String) {
        if self.rides.count > 0{
            guard let userProfile = UserService.currentUserProfile else { return }
            // Firebase code here
            let postRef = Database.database().reference().child("posts").childByAutoId()
            let postObject = [
                "author": [
                    "uid": userProfile.uid,
                    "username": userProfile.username,
                    "photoURL": userProfile.photoURL.absoluteString
                ],
                "text": "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_is_going_from", comment: ""))\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_from", comment: "")) \(self.rides[0].pickupAdress)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_to", comment: "")) \(self.rides[0].dropAdress)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_on", comment: "")) \(self.rides[0].date)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "the_clock", comment: ""))\(self.rides[0].time)",
                "timestamp": [".sv":"timestamp"],
                "type": "1",
                "travel_id": NumberFormatter().number(from: travel_id)!.decimalValue,
                "privacy": "1"
                ] as [String:Any]
            postRef.setValue(postObject, withCompletionBlock: { error, ref in
                if error == nil {
                } else {
                }
            })
        }
    }
    
    @IBAction func ShowDriverInfoButtonClicked(_ sender: Any) {
        let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoViewController") as! DriverInfoViewController
        //        vcConfirm.confirmRequestPage = confirmRequestView.RequestsViewController
        vcConfirm.DriverData = rideData
        self.navigationController?.pushViewController(vcConfirm, animated: true)
        
    }
    
    func configureMapAndMarkersForRoute(results:[String:Any]) {
        let originAddress = results["startLocation"] as! String
        let destinationAddress = results["endLocation"] as! String
        let originCoordinate = results["startCoordinate"] as! CLLocationCoordinate2D
        let destinationCoordinate = results["endCoordinate"] as! CLLocationCoordinate2D
        
        mapView.camera = GMSCameraPosition.camera(withTarget: originCoordinate, zoom: 19)
        originMarker = GMSMarker(position: originCoordinate)
        originMarker.map = mapView
        originMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        originMarker.title = originAddress
        
        destinationMarker = GMSMarker(position: destinationCoordinate)
        destinationMarker.map = mapView
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        destinationMarker.title = destinationAddress
    }
    
    func drawRoute(points:String) {
        let path = GMSPath(fromEncodedPath: points)!
        let routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 2.0
        routePolyline.map = mapView
    }
    
    func deletePost(with travel_id:String) {
        print("ibrahim_delete_post")
        print(travel_id)
        let commentsRef = Database.database().reference().child("posts")
        commentsRef.observe(.value, with: { snapshot in
            for child in snapshot.children {
                print(child)
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data){
                    print(travel_id)
                    if (post.travel_id == Double(travel_id)){
                        childSnapshot.ref.removeValue { error, _ in
                            print(error)
                        }
                    }
                }
            }
        })
    }
}

extension ConfirmRideVC: GMSAutocompleteViewControllerDelegate {
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinate: \(place.coordinate)")
        
        if isPickupPoint{
            if openAlert(){
                self.TextFieldPickupPoint.text = place.name
                let pickupLat = place.coordinate.latitude
                let pickupLog = place.coordinate.longitude
                self.pickupPointLocation = "\(pickupLat),\(pickupLog)"
                isPickupPoint = false
                //                self.TextFieldTripPrice.text = self.TextFieldTripPrice.text
                //                self.TextFieldPassengersNum.text = self.TextFieldPassengersNum.text
                //                self.TextFieldPlatform2.text = self.TextFieldPlatform2.text
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
}
