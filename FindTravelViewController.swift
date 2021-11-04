//
//  FindTravelViewController.swift
//  Taxi
//
//  Created by Syria.Apple on 3/30/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import GooglePlaces
import Firebase

protocol isAbleToReceiveData {
    func pass(ResultSearchDictionary: [String:Any]!)  //data: string is an example parameter
}

protocol NoOfPassengers {
    func NoOfPassengersPass(NoOfPassengersVar: Int!)  //data: string is an example parameter
}

class FindTravelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, isAbleToReceiveData, NoOfPassengers{
    
    @objc let SmokedPicker = UIPickerView()
    
    let SmokedPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Minibus", comment: ""), LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Bus", comment: ""))
    var smokedString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: "")
    
    @objc let PlatformPicker = UIPickerView()
    let PlatformPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformNo", comment: ""))//["Yes","No"]
    var PlatformString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
    
    
    @IBOutlet var tableView: UITableView!
    var requestPage:RequestView?
    var rides = [Ride]()
    //var travels = [Travel]()
    var SearchData = [String:Any]()
    
    @IBOutlet var TextFieldPickupAddress: UITextField!
    @IBOutlet var TextFieldDropAddress: UITextField!
    @IBOutlet var FindTravelButton: UIButton!
    @IBOutlet var AddTravelButton: UIButton!
    @IBOutlet var TextFieldTravelTime: UITextField!
    @IBOutlet var TextFieldSmoked: UITextField!
    //    @IBOutlet var TextFieldPlatform: UITextField!
    
    @IBOutlet var NoOfPassengersButton: UIButton!
    
    @IBOutlet var PickupAddressButton: UIButton!
    @IBOutlet var DropAddressButton: UIButton!
    
    var TextFieldPickupPoint: UITextField!
    var TextFieldPickupPoint_location: UITextField!
    
    var travelTimeDate = ""
    var travelDate = ""
    var travelTime = ""
    
    let datePicker = UIDatePicker()
    
    //var Travels = [Travel]()
    
    var isPickup = Bool()
    var isDrop = Bool()
    var isPickupPoint = Bool()
    var PickupLocation = ""
    var DropLocation = ""
    var pickupPointLocation = ""
    var pickUpPoint = ""
    var PassengersStr = "Passenger"
    var PassengersCount = 1
    var enteredText = "1"
    var car_type = "car"
    var bagsNotes = ""
    var button = UIButton(type: .system)
    
    var TextFieldPlatform2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = true
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Title", comment: "")
        
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
        getNotificationsCount()
        
        
        var PlatformString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
        self.TextFieldPickupAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Pickup_Add", comment: ""),comment: ""))
        self.TextFieldPickupAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldPickupAddress.frame.height))
        self.TextFieldDropAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Drop_Add", comment: ""),comment: ""))
        self.TextFieldDropAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: self.TextFieldDropAddress.frame.height))
        self.FindTravelButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        self.AddTravelButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        self.TextFieldTravelTime.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_TravelTime", comment: ""),comment: ""))
        self.TextFieldTravelTime.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldTravelTime.frame.height))
        
        self.TextFieldSmoked.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: ""),comment: ""))
        self.TextFieldSmoked.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldTravelTime.frame.height))
        
        
        NoOfPassengersButton.setTitle("\(String(PassengersCount)) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Passengers", comment: ""))", for: .normal)
        FindTravelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_FindTravel", comment: ""), for: .normal)
        AddTravelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_AddTravel", comment: ""), for: .normal)
        
        SmokedPicker.delegate = self
        
        //Looks for single or multiple taps.
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        //view.addGestureRecognizer(tap)
        
        createDatePicker()
        createSmokedPicker()
        
        PlatformPicker.delegate = self
        createPlatformPicker()
    }
    
    func getNotificationsCount(){
        let userRef = Database.database().reference().child("Notifications").child(Common.instance.getUserId())
        userRef.observe(.value, with: { snapshot in
            var count = 0
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let notification = Notification.parse(childSnapshot.key, data),
                    notification.readStatus == "0" {
                    count = count + 1
                }
            }
            //let button = UIButton(type: .system)
            self.button.setImage(UIImage(named: "notification"), for: .normal)
            self.button.setTitle(String(count), for: .normal)
            self.button.setTitleColor(UIColor.red, for: .normal)
            self.button.sizeToFit()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.button)
            self.button.addTarget(self, action: #selector(self.showNotifications), for: .touchUpInside)
            
        })
    }
    
    func updateNotificationFirebase(){
        print("updateNotificationFirebase")
        Database.database().reference().child("Notifications").child(Common.instance.getUserId()).observeSingleEvent(of: .value, with: { snapshot in
            print("snapshot")
            print(snapshot)
            for child in snapshot.children {
                print("child")
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let notificatoin = Notification.parse(childSnapshot.key, data){
                    print("key")
                    print(childSnapshot.key)
                    let postRef = Database.database().reference().child("Notifications").child(Common.instance.getUserId()).child(childSnapshot.key).child("readStatus")
                    postRef.setValue("1", withCompletionBlock: { error, ref in
                        if error == nil {
                            print("error")
                        } else {
                            print("else")
                            // Handle the error
                        }
                    })
                }
            }
        })
    }
    
    @IBAction func AddTravelbtn(_ sender: Any) {
        // create the alert
        openAlert()
    }
    
    func openAlert() -> Bool {
        if validateTextFields() {
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
            
            //4 platform
            alertController!.addTextField(
                configurationHandler: {(textField: UITextField!) in
                    self.TextFieldPlatform2 = textField
                    self.TextFieldPlatform2.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: ""),comment: "")
                    self.TextFieldPlatform2.text  = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
                    self.TextFieldPlatform2.addTarget(self, action: #selector(self.myTargetFunction), for: .touchDown)
                    
            })
            
            let action = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Submit", comment: ""),comment: ""),
                                       style: UIAlertAction.Style.default,
                                       handler: {[weak self]
                                        (paramAction:UIAlertAction!) in
                                        if let textFields = alertController?.textFields{
                                            let theTextFields = textFields as [UITextField]
                                            if theTextFields[0].text!.count == 0
                                            {
                                                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self!)
                                                return
                                                
                                            }else{
                                                self?.pickUpPoint = theTextFields[0].text!
                                            }
                                            if theTextFields[2].text!.count == 0
                                            {
                                                self?.enteredText = "1"
                                            }
                                            else
                                            {
                                                self?.enteredText = theTextFields[2].text!
                                            }
                                            self?.bagsNotes = theTextFields[3].text!
                                            // self!.displayLabel.text = enteredText
                                            self!.AddTravel_Func()
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
        }
        return true
    }
    
    @objc func myTargetFunction(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        textField.inputAccessoryView = toolBar;
        textField.inputView = self.PlatformPicker
        toolBar.setItems([doneButton], animated: true)
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
    
    func AddTravel_Func(){
        if validateTextFields() {
            // -- manage parameters --
            var parameters = [String:Any]()
            parameters["user_id"] = Common.instance.getUserId()
            parameters["driver_id"] = -1
            parameters["travel_id"] = -1
            parameters["pickup_address"] = TextFieldPickupAddress.text!
            parameters["drop_address"] = TextFieldDropAddress.text!
            parameters["pickup_location"] = PickupLocation
            parameters["drop_location"] = DropLocation
            parameters["distance"] = "0"
            parameters["amount"] = "0"
            parameters["Ride_smoked"] = "1"
            parameters["status"] = "REQUESTED"
            parameters["booked_set"] = self.enteredText
            parameters["time"] = self.travelTime
            parameters["date"] = self.travelDate
            parameters["car_type"] = self.car_type
            parameters["ride_notes"] = self.bagsNotes
            parameters["ride_pickup_point"] = self.pickUpPoint
            parameters["ride_pickup_point_location"] = self.pickupPointLocation
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading
            HUD.show(to: view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.AddRide(parameters, headers), success: { (response) in
                // -- hide loading --
                HUD.hide(to: self.view)
                // -- parse response --
                
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Notification", comment: ""),comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), comment: ""), style: .default, handler: { (action) in
                        if let data = response as? [String:Any] {
                            print("ibrahim rideid");
                            print(data["ride_id"]!);
                            //                    self.savePrivatePost(DriverId: data["user_id"]! as! String)
                            self.AddRideFirebase(ride_id: data["ride_id"]! as! NSNumber)
                            if self.TextFieldPlatform2.text  == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_PlatformYes", comment: "")
                            {
                                self.handlePostButton(travel_id: data["ride_id"]! as! NSNumber )
                            }
                        }
                        _ = self.navigationController?.popViewController(animated: true)
                        self.TextFieldPickupAddress.text = ""
                        self.TextFieldDropAddress.text = ""
                        self.TextFieldTravelTime.text = ""
                    })
                    alert.addAction(done)
                    self.present(alert, animated: true, completion: nil)
                }
            }, failure: { (message) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            }, error: { (err) in
                HUD.hide(to: self.view)
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
            })
        }
        else{
            HUD.hide(to: self.view)
        }
    }
    
    func validateTextFields() -> Bool {
        if TextFieldPickupAddress.text?.count == 0 ||
            TextFieldDropAddress.text?.count == 0 ||
            
            TextFieldTravelTime.text?.count == 0
        {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        }
        else{
            return true
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func showNotifications() {
        
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        let nav = UINavigationController(rootViewController: vc)
        nav.setViewControllers([vc], animated:true)
        self.revealViewController().setFront(nav, animated: true)
        self.revealViewController().pushFrontViewController(nav, animated: true)
        updateNotificationFirebase()
    }
    
    func updateNotificationFirebase(with status:String, ride_id:String, user_id:String, notification_id:String) {
        let postRef = Database.database().reference().child("Notifications").child(user_id)
        let postObject = [
            //            "ride_id": ride_id,
            //            "text": "Ride Updated",
            "readStatus": "1"//,
            //            "timestamp": [".sv":"timestamp"],
            //            "uid": Auth.auth().currentUser?.uid
            ]
            as [String:Any]
        postRef.updateChildValues(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NoOfPassengersButton.setTitle("\(String(PassengersCount)) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Passengers", comment: ""))", for: .normal)
        loadRequests()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rides.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        cell = tableView.dequeueReusableCell(withIdentifier: "RequestsCell") as! RequestsCell
        
        cell.Fromlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Fromlbl", comment: "")
        cell.Tolbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Tolbl", comment: "")
        cell.Datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_Datelbl", comment: "")
        cell.DriverNamelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "RequestsCell_DriverNamelbl", comment: "")
        
        // -- get current Rides Object --
        let currentObj = rides[indexPath.row]
        
        // -- set driver name to cell --
        cell.name.text = currentObj.driverName
        
        // -- set date and time to cell --
        let currentDate = currentObj.date
        let currentTime = currentObj.time
        //let date = Common.instance.getFormattedDate(date: currentDate).components(separatedBy: "-")
        let date = Common.instance.getFormattedDateOnly(date: currentDate)
        let time = Common.instance.getFormattedTimeOnly(date: currentTime)
        cell.dateLabel.text = date
        cell.timeLabel.text = time//date.last
        
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // -- push to detail view with required data --
        print("didSelectRowAt")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
        vc.requestPage = RequestView.accepted
        vc.rideDetail = rides[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func loadRequests(){
        let params = ["id":Common.instance.getUserId(),"status":"ACCEPTED","utype":"0"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetRides(params,headers)).responseObject { (response: DataResponse<Rides>) in
            //            HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides = (response.result.value?.rides)!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    
    @IBAction func FndButton(_ sender: UIButton) {
        let smoked_string = 0
        
        // -- move to next view --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
        vc.requestPage = RequestView.searchTravel
        vc.SearchData = ["PickupAddress":TextFieldPickupAddress.text!,
                         "pickupLocation": PickupLocation,
                         "DropAddress": TextFieldDropAddress.text!,
                         "DropLocation":DropLocation,
                         //"travel_time":travelTime,
            "travel_date":travelTimeDate,
            "NoPassengers":String(PassengersCount),
            "Smoked": String(smoked_string),
            "car_type": car_type]
        print("ibrahim")
        print(car_type)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TextFieldPickupAddressTouchDown(_ sender: Any) {
        isPickup = true
        autocompleteClicked()
    }
    
    @IBAction func TextFieldDropAddressTouchDown(_ sender: Any) {
        isDrop = true
        autocompleteClicked()
    }
    
    @IBAction func ButtonPickupAddressTouchDown(_ sender: Any) {
        isPickup = true
        GoogleSearchClicked()
    }
    
    @IBAction func ButtonDropAddressTouchDown(_ sender: Any) {
        isDrop = true
        GoogleSearchClicked()
    }
    
    @IBAction func NoOfPassengersButtonTouchDown(_ sender: Any) {
        let PassengersViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "PassengersViewController") as!
        PassengersViewController
        PassengersViewController_.delegate = self
        PassengersViewController_.PassengersCount = PassengersCount
        PassengersViewController_.modalPresentationStyle = .fullScreen
        self.present(PassengersViewController_, animated: true, completion: nil)
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
        
        if isPickup  {
            print("latlong from findtravel view controller:")
            print(ResultSearchDictionary["latitude"]!)
            print(ResultSearchDictionary["longitude"]!)
            self.TextFieldPickupAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            self.PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
            
        } else if isDrop {
            self.TextFieldDropAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            self.DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
        else if isPickupPoint{
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
    
    func NoOfPassengersPass(NoOfPassengersVar: Int!) {
        //self.PassengersCount = NoOfPassengersVar
        PassengersCount = NoOfPassengersVar
        if PassengersCount == 1{
            PassengersStr = "Passenger"
        }
        else{
            PassengersStr = "Passengers"
        }
        NoOfPassengersButton.setTitle("\(String(PassengersCount)) \(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Passengers", comment: ""))", for: .normal)
    }
    
    func createDatePicker(){
        let loc = Locale(identifier: "us")
        self.datePicker.locale = loc
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedButton))
        TextFieldTravelTime.inputAccessoryView = toolBar;
        TextFieldTravelTime.inputView = datePicker
        toolBar.setItems([doneButton], animated: true)
        datePicker.datePickerMode = .dateAndTime
    }
    
    func createPlatformPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePlatformButton))
        //        TextFieldPlatform2.inputAccessoryView = toolBar;
        //        TextFieldPlatform2.inputView = PlatformPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
    }
    
    func createSmokedPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSmokedButton))
        TextFieldSmoked.inputAccessoryView = toolBar;
        TextFieldSmoked.inputView = SmokedPicker
        toolBar.setItems([doneButton], animated: true)
        //        datePicker.datePickerMode = .dateAndTime
        
    }
    
    @objc func donePressedButton (){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm"
        let loc = Locale(identifier: "us")
        formatter.locale = loc
        travelTimeDate = formatter.string(from: datePicker.date)
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "YYYY-MM-dd"
        let loc1 = Locale(identifier: "us")
        formatter1.locale = loc1
        travelDate = formatter1.string(from: datePicker.date)
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "HH:mm"
        let loc2 = Locale(identifier: "us")
        formatter2.locale = loc1
        travelTime = formatter2.string(from: datePicker.date)
        
        TextFieldTravelTime.text = travelTimeDate
        self.view.endEditing(true)
    }
    
    @objc func doneSmokedButton (){
        //        self.TextFieldSmoked.text = smokedString//"Yes"
        self.view.endEditing(true)
    }
    
    @objc func donePlatformButton (){
        self.TextFieldPlatform2.text = PlatformString
        self.view.endEditing(true)
        PlatformPicker.endEditing(true)
    }
    
    func handlePostButton(travel_id: NSNumber) {
        guard let userProfile = UserService.currentUserProfile else { return }
        // Firebase code here
        let postRef = Database.database().reference().child("posts").childByAutoId()
        let postObject = [
            "author": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "text": "\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_is_going_from", comment: ""))\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_from", comment: "")) \(TextFieldPickupAddress.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_to", comment: "")) \(TextFieldDropAddress.text!)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Travel_on", comment: "")) \(travelDate)\n\(LocalizationSystem.sharedInstance.localizedStringForKey(key: "the_clock", comment: ""))\(travelTime)",
            "timestamp": [".sv":"timestamp"],
            "type": "1",
            "travel_id": travel_id,
            "privacy": "1"
            ] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func AddRideFirebase(ride_id: NSNumber) {
        let postRef = Database.database().reference().child("rides").child(ride_id.stringValue)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": "REQUESTED",
            "travel_status":"PENDING",
            "payment_status": "",
            "payment_mode": ""] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == SmokedPicker
        {
            return SmokedPickerData.count
        }
        else{
            return PlatformPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == SmokedPicker
        {
            TextFieldSmoked.text = SmokedPickerData[row]
            smokedString = SmokedPickerData[row]
            
            if smokedString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Car", comment: "")
            {
                car_type = "car"
            }
            else if smokedString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Minibus", comment: "")
            {
                car_type = "minibus"
            }
            else if smokedString == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Bus", comment: "")
            {
                car_type = "bus"
            }
        }
        else
        {
            TextFieldPlatform2.text = PlatformPickerData[row]
            PlatformString = PlatformPickerData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView == SmokedPicker
        {
            return SmokedPickerData[row]
        }
        else
        {
            return PlatformPickerData[row]
        }
    }
}

extension FindTravelViewController: GMSAutocompleteViewControllerDelegate {
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinate: \(place.coordinate)")
        
        if isPickup  {
            self.TextFieldPickupAddress.text = place.name
            let pickupLat = place.coordinate.latitude
            let pickupLog = place.coordinate.longitude
            self.PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
        }
        else if isDrop {
            self.TextFieldDropAddress.text = place.name
            let pickupLat = place.coordinate.latitude
            let pickupLog = place.coordinate.longitude
            self.DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
        else if isPickupPoint{
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
