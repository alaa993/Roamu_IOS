//
//  AcceptDetailReqViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 1/2/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit
import GoogleMaps
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation
import Braintree
import Firebase
import Alamofire

class AcceptDetailReqViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    var mapTasks = MapTasks()
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var markerView = MarkerView()
    var GoogleDistanceMatrixView = GoogleDistanceMatrix()
    
    @IBOutlet var name: UILabel!
    @IBOutlet var pickupLoc: UILabel!
    @IBOutlet var dropLoc: UILabel!
    @IBOutlet var PickUpPoint: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var time: UILabel!
    
    @IBOutlet var Namelbl: UILabel!
    @IBOutlet var PickupAddlbl: UILabel!
    @IBOutlet var DropAddlbl: UILabel!
    @IBOutlet var PickupPointlbl: UILabel!
    @IBOutlet var datelbl: UILabel!
    @IBOutlet var Timelbl: UILabel!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var trackButton: UIButton!
    @IBOutlet var payButton: UIButton!
    var CommentTextView: UITextField!
    var requestPage:RequestView?
    var rideDetail:Ride?
    var braintreeClient: BTAPIClient!
    var resultText = ""
    var DriverRatingText = ""
    var FareRatingText = ""
    var isRating = false
    var seeNewPostsButton:SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor:NSLayoutConstraint!
    var postListenerHandle:UInt?
    var travel_status = ""
    var paymentMode = ""
    var paymentStatus = ""
    var locationListenerHandle:UInt?
    var latitude = 0.0
    var longitude = 0.0
    var isGoogleDistanceMatrixView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        braintreeClient = BTAPIClient(authorization: "sandbox_w3rk5zkh_mhmfgyqszjv5hqpw")
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTitle", comment: "")
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        Timelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTimelbl", comment: "")//
        PickupPointlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupPointlbl", comment: "")
        datelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCdatelbl", comment: "")
        
        completeButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Complete", comment: ""), for: .normal)
        cancelButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cancel", comment: ""), for: .normal)
        trackButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Track", comment: ""), for: .normal)
        trackButton.isHidden = true
        payButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Pay", comment: ""), for: .normal)
        //
        
        var layoutGuide:UILayoutGuide!
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        seeNewPostsButton = SeeNewPostsButton()
        seeNewPostsButton.button.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_refreshButton", comment: ""), for: .normal)
        view.addSubview(seeNewPostsButton)
        seeNewPostsButton.translatesAutoresizingMaskIntoConstraints = false
        seeNewPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeNewPostsButtonTopAnchor = seeNewPostsButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44)
        seeNewPostsButtonTopAnchor.isActive = true
        seeNewPostsButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        seeNewPostsButton.widthAnchor.constraint(equalToConstant: seeNewPostsButton.button.bounds.width).isActive = true
        
        seeNewPostsButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        self.travel_status = rideDetail?.Travel_Status as! String
        self.paymentMode = rideDetail?.paymentMode as! String
        self.paymentStatus = rideDetail?.paymentStatus as! String
        setupData()
        
        // -- setup delegates --
        mapView.delegate = self
        
        // -- call required API --
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 ) {
            // -- get current coordintes --
            let manager = LocationManager.sharedInstance
            self.latitude = manager.latitude
            self.longitude = manager.longitude
            self.loadData(with:self.latitude, longitude:self.longitude)
            self.listenForLocationUpdate()
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ibrahim DetailReqViewController")
        //        CheckRating()
        //PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenForNewRefresh()
        
    }
    
    @IBAction func homeWasClicked(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGoogleDistanceMatrixView(GoogleDistanceMatrixView:UIView){
        GoogleDistanceMatrixView.translatesAutoresizingMaskIntoConstraints = false
        // -- add leading constraint --
        let leadingConstraint = NSLayoutConstraint(item: GoogleDistanceMatrixView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .leading,
                                                   multiplier: 1, constant: 0)
        // -- add trailing constraint --
        let trailingConstraint = NSLayoutConstraint(item: GoogleDistanceMatrixView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .trailing,
                                                    multiplier: 1, constant: 0)
        // -- add bottom constraint --
        let bottomConstraint = NSLayoutConstraint(item: GoogleDistanceMatrixView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .bottom,
                                                  multiplier: 1, constant: -15)
        // -- add height constraint --
        let heightConstraint = NSLayoutConstraint(item: GoogleDistanceMatrixView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1, constant: 150)
        // -- activate constraints --
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint])
    }
    
    func updateGoogleDistanceMatrixViewDetails(data:Travel){
        //        infoView.distance.text = (taxiFare?.cost)! + (taxiFare?.unit)! //String(format: "%.2f", Double(data.distance)!) + "km"
        
    }
    
    func removeUnwantedViews(){
        if GoogleDistanceMatrixView.isDescendant(of: view) {
            UIView.animate(withDuration: 1.0, animations: {
                self.GoogleDistanceMatrixView.alpha = 0
                self.GoogleDistanceMatrixView.alpha = 0
            }) { (finished) in
                if finished {
                    self.GoogleDistanceMatrixView.removeFromSuperview()
                    self.GoogleDistanceMatrixView.removeFromSuperview()
                    //                    if self.tableView.isDescendant(of: self.view){
                    //                        self.tableView.removeFromSuperview()
                    //                    }
                }
            }
        }
    }
    
    @IBAction func trackWasPressed(_ sender: UIButton) {
        //        print("going to track ride view controller")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrackRideViewController") as! TrackRideViewController
        vc.currentRide = rideDetail
        self.navigationController?.pushViewController(vc, animated: true)
        self.showTracking()
    }
    
    @IBAction func cancelWasPressed(_ sender: UIButton) {
        sendRequests(with: "CANCELLED")
    }
    
    @IBAction func payButtonWasClicked(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        
        let cashOnHand = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_Cash", comment: ""), style: .default) { (action) in
            self.sendPaymentRequests(with: "OFFLINE")
        }
        let paypal = UIAlertAction(title: LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_ElecPay", comment: "") , style: .default) { (action) in
            self.makePayment()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        actionSheet.addAction(cashOnHand)
        actionSheet.addAction(paypal)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    @IBAction func completeWasPressed(_ sender: UIButton) {
        var alertController:UIAlertController?
        alertController = UIAlertController(title:
            NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCRating", comment: ""),comment: ""),message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCEnterRating", comment: ""),comment: ""),preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDriverRating", comment: ""),comment: "")
                
                //                textField.keyboardType = UIKeyboardType.decimalPad
                textField.keyboardType = .asciiCapableNumberPad
                
                
        })
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCFareRating", comment: ""),comment: "")
                
                //                textField.keyboardType = UIKeyboardType.decimalPad
                textField.keyboardType = .asciiCapableNumberPad
                
                
                
        })
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                self.CommentTextView = textField
                self.CommentTextView.placeholder = NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCAddComment", comment: ""),comment: "")
                textField.textColor = UIColor.systemBlue
                
                //self.CommentTextView.keyboardType = UIKeyboardType.decimalPad
                //self.CommentTextView.keyboardType = .asciiCapableNumberPad
        })
        let action = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Submit", comment: ""),comment: ""),style: UIAlertAction.Style.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        print(theTextFields[0].text!)
                                        if theTextFields[0].text!.count == 0 || Int(theTextFields[0].text!)! > 10 ||
                                            Int(theTextFields[0].text!)! < 0{
                                            Common.showAlert(with: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCAlert", comment: ""), comment: ""), for: self!)
                                            return
                                        }else{
                                            self?.DriverRatingText = theTextFields[0].text!
                                        }
                                        print(theTextFields[1].text!)
                                        if theTextFields[1].text!.count == 0 || Int(theTextFields[1].text!)! > 10 ||
                                            Int(theTextFields[1].text!)! < 0{
                                            Common.showAlert(with: NSLocalizedString("Alert", comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCAlert", comment: ""), comment: ""), for: self!)
                                            return
                                        }else{
                                            self?.FareRatingText = theTextFields[1].text!
                                        }
                                        if theTextFields[2].text!.count > 0
                                        {
                                            self!.handleCommentButton(driver_id: self!.rideDetail!.driverId)
                                        }
                                        self?.Add_Rating()
                                    }
        })
        
        let action2 = UIAlertAction(title: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "Cancel", comment: ""),comment: ""),
                                    style: UIAlertAction.Style.default,
                                    handler: {[weak self]
                                        (paramAction:UIAlertAction!) in
                                        
        })
        
        
        alertController?.addAction(action)
        alertController?.addAction(action2)
        self.present(alertController!,animated: true, completion: nil)
    }
    
    func Add_Rating(){
        // -- manage parameters --
        var parameters = [String:Any]()
        print(rideDetail?.travelId)
        print(rideDetail?.driverId)
        print(Common.instance.getAPIKey())
        
        parameters["user_id"] = Common.instance.getUserId()
        parameters["travel_id"] = rideDetail?.travelId
        parameters["driver_id"] = rideDetail?.driverId
        parameters["travel_rate"] = FareRatingText
        parameters["driver_rate"] = DriverRatingText
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        // -- show loading --
        HUD.show(to: view)
        
        // -- send request --
        APIRequestManager.request(apiRequest: APIRouters.addRating(parameters, headers), success: { (response) in
            // -- hide loading --
            print(response)
            HUD.hide(to: self.view)
            // -- parse response --
            let alert = UIAlertController(title: NSLocalizedString("Success!!",comment: ""), message: "", preferredStyle: .alert)
            let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                //                _ = self.navigationController?.popViewController(animated: true)
                self.sendRequests(with: "COMPLETED")
                self.updateRideFirebase(with:"COMPLETED",travel_status: self.travel_status, paymentStatus: self.paymentStatus, paymentMode: self.paymentMode)
                self.updateNotificationFirebase(with:"COMPLETED")
                self.updateTravelCounterFirebase(with: "COMPLETED")
                self.setupData()
            })
            alert.addAction(done)
            
            self.present(alert, animated: true, completion: nil)
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
    
    func handleCommentButton(driver_id: String) {
        if CommentTextView.text!.count > 0
        {
            guard let userProfile = UserService.currentUserProfile else { return }
            // Firebase code here
            
            let postRef = Database.database().reference().child("private_posts").child(driver_id).child("Comments").childByAutoId()
            let postObject = [
                "author": [
                    "uid": userProfile.uid,
                    "username": userProfile.username,
                    "photoURL": userProfile.photoURL.absoluteString
                ],
                "text": CommentTextView.text!,//"comment1 test",
                "timestamp": [".sv":"timestamp"],
                "type":"1",
                "travel_id": 0
                ] as [String:Any]
            
            postRef.setValue(postObject, withCompletionBlock: { error, ref in
                if error == nil {
                    //                   self.delegate?.didUploadPost(withID: ref.key!)
                    //                   self.dismiss(animated: true, completion: nil)
                    self.CommentTextView.text = ""
                } else {
                    
                    // Handle the error
                }
            })
        }
    }
    
    func sendRequests(with status:String){
        //        let params = ["ride_id":rideDetail!.rideId,"status":status]
        var params = [String:String]()
        if (requestPage == RequestView.completed && rideDetail?.Travel_Status == "STARTED")
        {
            print("sendRequests pending")
            params = ["ride_id":rideDetail!.rideId,"status":status, "travel_id":rideDetail!.travelId, "travel_status":"COMPLETED","by":"user"]
        }
        else
        {
            print("sendRequests not pending")
            params = ["ride_id":rideDetail!.rideId,"status":status,"by":"user"]
        }
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            if response is String {
                let alert = UIAlertController(title: "Success!!", message: response as? String, preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                    //                    self.backWasPressed()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                    if status == "COMPLETED"{
                        // vc.requestPage = RequestView.completed
                        //vc.PlatformString = "COMPLETED"
                        
                        self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
                        
                        //  vc.requestPage = RequestView.completed
                        // vc.PlatformString = "COMPLETED"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else if status == "CANCELLED"{
                        vc.requestPage = RequestView.cancelled
                        vc.PlatformString = "CANCELLED"
                    }
                    //self.navigationController?.pushViewController(vc, animated: true)
                })
                //
                self.updateRideFirebase(with:status,travel_status: self.travel_status, paymentStatus: self.paymentStatus, paymentMode: self.paymentMode)
                self.updateNotificationFirebase(with:status)
                self.updateTravelCounterFirebase(with: status)
                //
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
                
            }
        }, failure: { (message) in
            //Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func CheckRating(){
        // -- manage parameters --
        var parameters = [String:String]()
        print(Common.instance.getUserId())
        print(rideDetail?.travelId)
        print(rideDetail?.driverId)
        parameters["user_id"] = Common.instance.getUserId()
        parameters["travel_id"] = rideDetail?.travelId
        parameters["driver_id"] = rideDetail?.driverId
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        // response object by ibrahim without encapculation
        // 12345
        APIRequestManager.request(apiRequest: APIRouters.getRating(parameters, headers), success: { (response) in
            print("ibrahim response")
            print(response)
            
            if response as! String == "true"
            {
                self.isRating = true
                self.completeButton.isHidden = true
                self.cancelButton.isHidden = true
                print("true")
            }
            else
            {
                print("false")
                self.completeButton.isHidden = false
            }
            
            //            if let data = response as? [String:Any] {
            //                print("data response")
            //                print(data)
            ////                if let travel_id = data["travel_id"] {
            ////                    self.isRating = true
            ////                    self.completeButton.isHidden = true
            ////                    print("true")
            ////                }
            ////                else
            ////                {
            ////                    print("false")
            ////                    self.completeButton.isHidden = false
            ////                }
            //            }
        }, failure: { (message) in
            print("ibrahim response fail")
        }, error: { (err) in
            print("ibrahim response error")
        })
    }
    
    func sendPaymentRequests(with status:String){
        let params = ["ride_id":rideDetail!.rideId,"payment_mode":status,"by":"user"]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        APIRequestManager.request(apiRequest: APIRouters.UpdateRides(params, headers), success: { (response) in
            if response is String {
                let alert = UIAlertController(title: "Success!!", message: response as? String, preferredStyle: .alert)
                let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                    //                    self.backWasPressed()
                })
                var ride_status_st = ""
                if self.requestPage!.rawValue == RequestView.pending.rawValue
                {ride_status_st = "PENDING"}
                else if self.requestPage!.rawValue == RequestView.accepted.rawValue
                {ride_status_st = "ACCEPTED"}
                else if self.requestPage!.rawValue == RequestView.completed.rawValue
                {ride_status_st = "COMPLETED"}
                else if self.requestPage!.rawValue == RequestView.cancelled.rawValue
                {ride_status_st = "CANCELLED"}
                else if self.requestPage!.rawValue == RequestView.requested.rawValue
                {ride_status_st = "REQUESTED"}
                else if self.requestPage!.rawValue == RequestView.waited.rawValue
                {ride_status_st = "WAITED"}
                self.updateRideFirebase(with: ride_status_st, travel_status: self.travel_status, paymentStatus: self.paymentStatus, paymentMode: status)
                self.updateNotificationFirebase(with: "offline_request")
                self.updateTravelCounterFirebase(with: "OFFLINE")
                //
                //
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func makePayment(){
        let payPalDriver = BTPayPalDriver(apiClient: braintreeClient)
        payPalDriver.viewControllerPresentingDelegate = self
        payPalDriver.appSwitchDelegate = self // Optional
        
        // Specify the transaction amount here. "2.32" is used in this example.
        let request = BTPayPalRequest(amount: rideDetail!.amount)
        request.currencyCode = "USD" // Optional; see BTPayPalRequest.h for more options
        
        payPalDriver.requestOneTimePayment(request) { (tokenizedPayPalAccount, error) in
            if let tokenizedPayPalAccount = tokenizedPayPalAccount {
                print("Got a nonce: \(tokenizedPayPalAccount.nonce)")
                
                // Access additional information
                let email = tokenizedPayPalAccount.email
                debugPrint(email)
                let firstName = tokenizedPayPalAccount.firstName
                let lastName = tokenizedPayPalAccount.lastName
                let phone = tokenizedPayPalAccount.phone
                
                // See BTPostalAddress.h for details
                let billingAddress = tokenizedPayPalAccount.billingAddress
                let shippingAddress = tokenizedPayPalAccount.shippingAddress
            } else if let error = error {
                // Handle error here...
                print(error)
            } else {
                // Buyer canceled payment approval
            }
        }
    }
    
    func setupData(){
        print("begin of setupdata")
        // -- setup buttons according to page requests --
        if requestPage == RequestView.requested
        {
            print("requestPage requested")
            completeButton.isHidden = true
            cancelButton.isHidden = true
            trackButton.isHidden = true
            payButton.isHidden = true
        }
        else if requestPage == RequestView.cancelled || requestPage == RequestView.completed
        {
            print("requestPage cancelled or completed")
            completeButton.isHidden = true
            cancelButton.isHidden = true
            trackButton.isHidden = true
            payButton.isHidden = true
            
            if requestPage == RequestView.completed
            {
                print("requestPage completed")
                CheckRating()
            }
        }
        else if requestPage == RequestView.pending
        {
            print("requestPage pending")
            cancelButton.isHidden = false
            completeButton.isHidden = true
            trackButton.isHidden = true
            payButton.isHidden = true
        }
        else
        {
            print("requestPage else")
            trackButton.isHidden = true
            
            if self.paymentStatus == "PAID"{
                print("payent status paid")
                print(self.paymentStatus)
                payButton.isHidden = true
                //update by ibrahim 9-1-2021
                completeButton.isHidden = false
            } else {
                print("payent status not paid")
                print(self.paymentStatus)
                payButton.isHidden = false
                completeButton.isHidden = true
            }
        }
        // -- setup back button --
        let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"),
                                         style: .plain, target: self,
                                         action: #selector(self.backWasPressed))
        self.navigationItem.leftBarButtonItem = backButton
        
        // -- setup ride data --
        name.text = rideDetail?.driverName
        //ibrahim was here
        //---------------------------------------
        pickupLoc.text = rideDetail?.pickupAdress
        dropLoc.text = rideDetail?.dropAdress
        //---------------------------------------
        let inFormatter = DateFormatter()
        inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        inFormatter.dateFormat = "HH:mm:ss"
        
        let outFormatter = DateFormatter()
        outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        outFormatter.dateFormat = "HH:mm"
        
        let date_ = inFormatter.date(from: rideDetail!.time)!
        let outStr = outFormatter.string(from: date_)
        
        time.text = outStr
        PickUpPoint.text = rideDetail?.pickup_point
        date.text = rideDetail?.date
        
        // Set up payPalConfig
        //payPalConfig.acceptCreditCards = true
        
        if self.paymentStatus != "" || self.paymentMode == "OFFLINE"
        {
            print("payment mode offline or status != ")
            if self.paymentMode == "OFFLINE" {
                print("payment mode offline")
            }else {
                print("payment mode not offline ")
            }
            payButton.isHidden = true
            trackButton.isHidden = true
        }
        else
        {
            print("payment mode not  offline or not status != ")
            if requestPage == RequestView.pending
            {
                payButton.isHidden = true
            }
            else if requestPage == RequestView.requested
            {
                payButton.isHidden = true
                trackButton.isHidden = true
            }
            else
            {
                payButton.isHidden = false
                trackButton.isHidden = true
            }
            
        }
        
        if requestPage == RequestView.cancelled || requestPage == RequestView.completed
        {
            payButton.isHidden = true
            trackButton.isHidden = true
        }
        print("end of setupdata")
    }
    
    func loadData(with latitude:Double, longitude:Double){
        
        
        // -- set camera position --
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom:19)
        mapView.clear()
        mapView.animate(to: camera)
        mapView.isMyLocationEnabled = true
        getDirections()
        
    }
    
    func updateTravelCounterFirebase(with status:String) {
        print("updateTravelCounteR")
        if status == "ACCEPTED"{
            Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Counters").child("ACCEPTED").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(self.rideDetail!.travelId).child("Counters").child("ACCEPTED")
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
            Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Counters").child("COMPLETED").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(self.rideDetail!.travelId).child("Counters").child("COMPLETED")
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
            Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Counters").child("OFFLINE").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(self.rideDetail!.travelId).child("Counters").child("OFFLINE")
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
            Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Counters").child("PAID").observeSingleEvent(of: .value, with: { snapshot in
                print("snapshot")
                print(snapshot)
                if let data = snapshot.value as? Int{
                    print("ibrahim")
                    print("data")
                    print(data)
                    let postRef = Database.database().reference().child("Travels").child(self.rideDetail!.travelId).child("Counters").child("PAID")
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
    
    @objc func backWasPressed(){
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleRefresh() {
        
        print("Refresh!")
        
        //        toggleSeeNewPostsButton(hidden: true)
    }
    
    func toggleSeeNewPostsButton(hidden:Bool) {
        if hidden {
            // hide it
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = -44.0
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            // show it
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.seeNewPostsButtonTopAnchor.constant = 12
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func listenForLocationUpdate(){
        Database.database().reference().child("Location").child(Common.instance.getUserId()).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String:Any],
                let latitude_ = dict["latitude"] as? Double,
                let longitude_ = dict["longitude"] as? Double {
                self.loadData(with: latitude_, longitude: longitude_)
                
            }
            self.listenForFirebaseTravelUpdate()
        })
    }
    
    func listenForFirebaseTravelUpdate(){
        print("listenForFirebaseTravelUpdate")
        Database.database().reference().child("Travels").child(rideDetail!.travelId).child("Clients").observeSingleEvent(of: .value, with: { snapshot in
            //            print("snapshot")
            //            print(snapshot)
            for child in snapshot.children {
                //                print("child")
                //                print(child)
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? String
                {
                    //                    print("client")
                    //                    print(data)
                    Database.database().reference().child("Location").child(data).observeSingleEvent(of: .value, with: { snapshot in
                        if let dict = snapshot.value as? [String:Any],
                            let latitude = dict["latitude"] as? Double,
                            let longitude = dict["longitude"] as? Double {
                            //                            print("ibrahim")
                            //                            print("latitude")
                            //                            print(latitude)
                            //                            print(longitude)
                            
                            let originCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
                            let clientMarker = GMSMarker(position: originCoordinate)
                            clientMarker.map = self.mapView
                            clientMarker.icon = GMSMarker.markerImage(with: UIColor.blue)
                            clientMarker.title = "User"
                        }
                    })
                }
            }
        })
    }
    
    func listenForNewRefresh() {
        postListenerHandle = Database.database().reference().child("rides").child(rideDetail!.rideId).observe(.childChanged, with: { snapshot in
            print("ibrahim snapshot")
            
            print(snapshot.value)
            if let data = snapshot.value as? String{
                if snapshot.key == "ride_status"
                {
                    if data == "PENDING"
                    {
                        self.requestPage = RequestView.pending
                    }
                    else if data == "ACCEPTED"
                    {
                        self.requestPage = RequestView.accepted
                    }
                    else if data == "COMPLETED"
                    {
                        self.requestPage = RequestView.completed
                    }
                    else if data == "CANCELLED"
                    {
                        self.requestPage = RequestView.cancelled
                    }
                }
                else if snapshot.key == "travel_status"
                {
                    self.travel_status = data
                }
                else if snapshot.key == "payment_status"
                {
                    self.paymentStatus = data
                }
                else if snapshot.key == "payment_mode"
                {
                    self.paymentMode = data
                }
                else if snapshot.key == "timestamp"
                {
                    print("timestamp")
                }
                //                self.toggleSeeNewPostsButton(hidden: false)
                self.setupData()
            }
        })
    }
    
    func updateRideFirebase(with status:String, travel_status:String, paymentStatus:String, paymentMode:String) {
        let postRef = Database.database().reference().child("rides").child(rideDetail!.rideId)
        let postObject = [
            "timestamp": [".sv":"timestamp"],
            "ride_status": status,
            "travel_status": travel_status,
            "payment_status": paymentStatus,
            "payment_mode": paymentMode] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func updateNotificationFirebase(with status:String) {
        let postRef = Database.database().reference().child("Notifications").child(rideDetail!.driverId).childByAutoId()
        let postObject = [
            "ride_id": rideDetail!.rideId,
            "travel_id": rideDetail!.travelId,
            "text": status.lowercased(),
            "readStatus": "0",
            "timestamp": [".sv":"timestamp"],
            "uid": Auth.auth().currentUser?.uid] as [String:Any]
        postRef.setValue(postObject, withCompletionBlock: { error, ref in
            if error == nil {
            } else {
            }
        })
    }
    
    func showTracking() {
        let pickupArray = rideDetail?.pickLocation.split(separator: ",")
        //rideDetail?.pickLocation.split(regex: "[, ]+")//rideDetail?.pickLocation.components(separatedBy: ",")
        print(pickupArray!)
        // ibrahim was here
        let pickLat: Double = Double(pickupArray![0])!
        let pickLong: Double = Double(pickupArray![1])!
        print(pickLat)
        print(pickLong)
        
        let dropArray = rideDetail?.dropLocation.split(separator: ",")
        //rideDetail?.dropLocation.split(regex: "[, ]+")//rideDetail?.dropLocation.components(separatedBy: ",")
        print(dropArray!)
        let dropLat: Double = Double(dropArray![0])!
        let dropLong: Double = Double(dropArray![1])!
        print(pickLat)
        print(pickLong)
        
        let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: pickLat, longitude: pickLong), name: rideDetail?.pickupAdress)
        let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: dropLat, longitude: dropLong), name: rideDetail?.dropAdress)
        
        let options = RouteOptions(waypoints: [origin, destination])
        options.routeShapeResolution = .full
        options.includesSteps = true
        
        Directions.shared.calculate(options) { (waypoints, routes, error) in
            guard let route = routes?.first else { return }
            
            let viewController = NavigationViewController(for: route)
            self.present(viewController, animated: true, completion: nil)
        }
    }
    
    func getDirections(){
        print("ibrahim")
        print("getDirections")
        mapTasks.getDirections(rideDetail?.pickLocation, destination: rideDetail?.dropLocation, waypoints: nil, travelMode: nil) { (status, result, success) in
            if success {
                print("success")
                if let response = result {
                    print("result")
                    print(response)
                    self.configureMapAndMarkersForRoute(results: response)
                    //                    self.totalDistance = response["distance"] as! Double
                    //                    self.distance.text = String(format: "%.2f", self.totalDistance) + " km"
                    if let polylines = response["polylines"] as? [String:Any],
                        let pts = polylines["points"] as? String{
                        self.drawRoute(points: pts)
                    }
                    //                    self.fare.text =  ""//String(format: "%.2f", (self.totalDistance * Double((self.rideFare?.cost)!)!)) + " " + (self.rideFare?.unit)!
                }
            } else {
                //                print(status)
                //                print(result?.description)
            }
        }
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
}

extension AcceptDetailReqViewController : BTViewControllerPresentingDelegate{
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
}

extension AcceptDetailReqViewController : BTAppSwitchDelegate {
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
}
extension AcceptDetailReqViewController:GMSMapViewDelegate,UITextFieldDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        markerView = MarkerView.loadFromNib()
        markerView.titleText.text = marker.title
        markerView.descriptionText.text = marker.snippet
        return markerView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //        removeUnwantedViews()
        if(isGoogleDistanceMatrixView == false){
            self.self.distancematrixGet(with:String(self.latitude) + "," + String(self.longitude), destincationCoordinate:String(marker.position.latitude) + "," + String(marker.position.longitude))
        }
        else{
            removeUnwantedViews()
            isGoogleDistanceMatrixView = false
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if(isGoogleDistanceMatrixView == false){
            self.self.distancematrixGet(with:String(self.latitude) + "," + String(self.longitude), destincationCoordinate:String(coordinate.latitude) + "," + String(coordinate.longitude))
        }
        else{
            removeUnwantedViews()
            isGoogleDistanceMatrixView = false
        }
    }
    
    func distancematrixGet(with originCoordinate:String, destincationCoordinate:String) {
        print("distancematrixGet")
        Distance().find(origin: originCoordinate.replacingOccurrences(of: " ", with: "+"), destination: destincationCoordinate.replacingOccurrences(of: " ", with: "+")){ (distance,time) in
//            print("Total Distance : "+distance)
//            print("Estimated Time : "+time)
            if(String(distance).count > 0){
                self.isGoogleDistanceMatrixView = true
                self.GoogleDistanceMatrixView = GoogleDistanceMatrix.loadFromNib()
                self.view.addSubview(self.GoogleDistanceMatrixView)
                self.setupGoogleDistanceMatrixView(GoogleDistanceMatrixView: self.GoogleDistanceMatrixView)
                self.GoogleDistanceMatrixView.layer.position.y += 200
                self.GoogleDistanceMatrixView.slideUpSpring(toPosition: 200, withDuration: 1.0, delay: 0.0, andOptions: [.curveEaseInOut])
                self.GoogleDistanceMatrixView.distance_info.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "distance_info", comment: "")
                self.GoogleDistanceMatrixView.distance1_info.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "distance1_info", comment: "")
                self.GoogleDistanceMatrixView.distance_time_info.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "distance_time_info", comment: "")

                self.GoogleDistanceMatrixView.distance1_info_var.text = distance
                self.GoogleDistanceMatrixView.distance_time_info_var.text = time
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
    }
}
