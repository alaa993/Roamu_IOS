//
//  AddTravelViewController.swift
//  Taxi
//
//  Created by Syria.Apple on 4/11/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit

class AddTravelViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, isAbleToReceiveData {
    
    @IBOutlet var TextFieldPickupAddress: UITextField!
    @IBOutlet var TextFieldDropAddress: UITextField!
    @IBOutlet var TextFieldAmount: UITextField!
    @IBOutlet var TextFieldBookedSet: UITextField!
    @IBOutlet var TextFieldTravelTime: UITextField!
    @IBOutlet var TextFieldSmoked: UITextField!
    
    @IBOutlet var AddTravelButton: UIButton!
    var travelTimeDate = ""
    var travelTime = ""
    
    let datePicker = UIDatePicker()
    
    var isPickup = Bool()
    var isDrop = Bool()
    var PickupLocation = ""
    var DropLocation = ""
    
    @objc let SmokedPicker = UIPickerView()
    let SmokedPickerData = [String](arrayLiteral: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: ""),LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedNo", comment: ""))//["Yes","No"]
    var smokedString = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "AddTravelVC_Title", comment: "")
        
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(AddTravelViewController.cancelWasClicked(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
        
        
        TextFieldPickupAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Pickup_Add", comment: ""),comment: ""))
        TextFieldPickupAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldPickupAddress.frame.height))
        
        TextFieldDropAddress.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Drop_Add", comment: ""),comment: ""))
        TextFieldDropAddress.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldDropAddress.frame.height))
        
        TextFieldAmount.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "AddTravelVC_Amount", comment: ""),comment: ""))
        TextFieldAmount.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldAmount.frame.height))
        
        TextFieldBookedSet.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "AddTravelVC_BookedSet", comment: ""),comment: ""))
        TextFieldBookedSet.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldBookedSet.frame.height))
        
        TextFieldTravelTime.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_TravelTime", comment: ""),comment: ""))
        TextFieldTravelTime.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldTravelTime.frame.height))
        
        TextFieldSmoked.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Smoked", comment: ""),comment: ""))
        TextFieldSmoked.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: TextFieldSmoked.frame.height))
        TextFieldSmoked.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedNo", comment: "")
        
        AddTravelButton.corner(radius: 20.0, color: UIColor.white, width: 1.0)
        
        AddTravelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_AddTravel", comment: ""), for: .normal)
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        SmokedPicker.delegate = self
        //SmokedPicker.dataSource = self
        //TextFieldSmoked.inputView = SmokedPicker
        
        createDatePicker()
        createSmokedPicker()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelWasClicked(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func AddTravelButton(_ sender: UIButton) {
        AddTravel_Func();
    }
    
    func pass(ResultSearchDictionary: [String : Any]!) {
        if isPickup  {
            TextFieldPickupAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            PickupLocation = "\(pickupLat),\(pickupLog)"
            isPickup = false
        }
        else if isDrop {
            TextFieldDropAddress.text = (ResultSearchDictionary["title"] as! String)
            let pickupLat = ResultSearchDictionary["latitude"]!
            let pickupLog = ResultSearchDictionary["longitude"]!
            DropLocation = "\(pickupLat),\(pickupLog)"
            isDrop = false
        }
    }
    
    @IBAction func TextFieldPickupAddressTouchDown(_ sender: Any) {
        isPickup = true
        autocompleteClicked()
    }
    
    @IBAction func TextFieldDropAddressTouchDown(_ sender: Any) {
        isDrop = true
        autocompleteClicked()
    }
    
    func autocompleteClicked() {
        let SearchViewController_ = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as!
        SearchViewController
        SearchViewController_.delegate = self
        SearchViewController_.modalPresentationStyle = .fullScreen
        self.present(SearchViewController_, animated: true, completion: nil)
    }
    
    // by ibrahim
    func AddTravel_Func(){
        var smoked_string = 0
        if TextFieldSmoked.text! == LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_SmokedYes", comment: "")
        {
            smoked_string = 1
        }
        else
        {
            smoked_string = 0
        }
        if self.validateTextFields() {
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
            parameters["amount"] = TextFieldAmount.text!
            parameters["Ride_smoked"] = smoked_string
            parameters["status"] = "REQUESTED"
            parameters["booked_set"] = TextFieldBookedSet.text!
            parameters["time"] = travelTimeDate
            let headers = ["X-API-KEY":Common.instance.getAPIKey()]
            // -- show loading
            HUD.show(to: view)
            // -- send request --
            APIRequestManager.request(apiRequest: APIRouters.AddRide(parameters, headers), success: { (response) in
                // -- hide loading --
                HUD.hide(to: self.view)
                // -- parse response --
                if response is [String : Any] {
                    let alert = UIAlertController(title: NSLocalizedString("Success!\nWe will notify you when a driver accept your ride!",comment: ""), message: "", preferredStyle: .alert)
                    let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                        _ = self.navigationController?.popViewController(animated: true)
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
    
    func createSmokedPicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "FindTravelVC_Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(doneSmokedButton))
        TextFieldSmoked.inputAccessoryView = toolBar;
        TextFieldSmoked.inputView = SmokedPicker
        toolBar.setItems([doneButton], animated: true)
        datePicker.datePickerMode = .dateAndTime
    }
    
    @objc func donePressedButton (){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let loc = Locale(identifier: "us")
        formatter.locale = loc
        travelTimeDate = formatter.string(from: datePicker.date)
        TextFieldTravelTime.text = travelTimeDate
        self.view.endEditing(true)
    }
    
    @objc func doneSmokedButton (){
        self.TextFieldSmoked.text = smokedString//"Yes"
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
         return 1
     }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return SmokedPickerData.count
     }
    
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         TextFieldSmoked.text = SmokedPickerData[row]
        smokedString = SmokedPickerData[row]
     }
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
         return SmokedPickerData[row]
     }
    
    func validateTextFields() -> Bool {
        if TextFieldPickupAddress.text?.count == 0 ||
            TextFieldDropAddress.text?.count == 0 ||
            TextFieldAmount.text?.count == 0 ||
            TextFieldBookedSet.text?.count == 0 ||
            TextFieldTravelTime.text?.count == 0 ||
            TextFieldSmoked.text?.count == 0 {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill all the fields.", comment: ""), for: self)
            return false
        }
        else{
            return true
        }
    }
    
}
