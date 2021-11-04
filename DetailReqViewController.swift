import UIKit
import MapboxDirections
import MapboxNavigation
import MapboxCoreNavigation
import Braintree
import Firebase
import Alamofire

class DetailReqViewController: UIViewController {
    
    @IBOutlet var DriverAvatar: UIImageView!
    @IBOutlet var DriverCar: UIImageView!
    
    // -- IBOutlets --
    @IBOutlet var name: UILabel!
    @IBOutlet var driverCity: UILabel!
    @IBOutlet var pickupLoc: UILabel!
    @IBOutlet var dropLoc: UILabel!
    @IBOutlet var fare: UILabel!
    @IBOutlet var status: UILabel!
    @IBOutlet var EmtySet: UILabel!
    
    @IBOutlet var vehicle: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var VechileColor: UILabel!
    @IBOutlet var DriverRate: UILabel!
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
    @IBOutlet var PaymentStatuslbl: UILabel!
    @IBOutlet var EmptySetlbl: UILabel!
    
    @IBOutlet var Vehiclelbl: UILabel!
    @IBOutlet var VehicleColorlbl: UILabel!
    @IBOutlet var DriverRatelbl: UILabel!
    @IBOutlet var Timelbl: UILabel!
    @IBOutlet var travelsCountlbl: UILabel!
    @IBOutlet var PickupPointlbl: UILabel!
    @IBOutlet var VechileNolbl: UILabel!
    @IBOutlet var datelbl: UILabel!
    @IBOutlet var FareRatelbl: UILabel!
    @IBOutlet var Commentslbl: UILabel!
    @IBOutlet var Noteslbl: UILabel!
    
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var trackButton: UIButton!
    @IBOutlet var payButton: UIButton!
    
    var CommentTextView: UITextField!
    
    // -- Instance variables --
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        if requestPage == RequestView.completed
        //        {
        //            CheckRating()
        //        }
        braintreeClient = BTAPIClient(authorization: "sandbox_w3rk5zkh_mhmfgyqszjv5hqpw")
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTitle", comment: "")
        let homeButton = UIBarButtonItem(image: UIImage(named: "homeButton"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(self.homeWasClicked(_:)))
        self.navigationItem.rightBarButtonItem = homeButton
        
        Namelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCNamelbl", comment: "")
        Citylbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCCitylbl", comment: "")
        PickupAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPickupAddlbl", comment: "")
        DropAddlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDropAddlbl", comment: "")
        Farelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCFarelbl", comment: "")
        PaymentStatuslbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCPaymentStatuslbl", comment: "")
        EmptySetlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCEmptySetlbl", comment: "")
        Timelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCTimelbl", comment: "")//
        Vehiclelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_Vehiclelbl", comment: "")
        VehicleColorlbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "ConfirmRideVC_VColorlbl", comment: "")
        DriverRatelbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVCDriverRatelbl", comment: "")
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ibrahim DetailReqViewController")
        //PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (self.requestPage == RequestView.accepted && (self.travel_status == "STARTED" || self.travel_status == "PAID")){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AcceptDetailReqViewController") as! AcceptDetailReqViewController
            vc.requestPage = RequestView.accepted
            vc.rideDetail = self.rideDetail
            vc.rideDetail?.Travel_Status = self.travel_status
            vc.rideDetail?.paymentMode = self.paymentMode
            vc.rideDetail?.paymentStatus = self.paymentStatus
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        listenForNewRefresh()
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
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        print("labelTapped")
        if #available(iOS 11.0, *) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserCommentsViewController") as! UserCommentsViewController
            vc.postid = rideDetail?.driverId
            //vc.post.append(posts[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupLabelTap1() {
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped1(_:)))
        self.Noteslbl.isUserInteractionEnabled = true
        self.Noteslbl.addGestureRecognizer(labelTap)
        
    }
    
    @objc func labelTapped1(_ sender: UITapGestureRecognizer) {
        print("labelTapped")
        if #available(iOS 11.0, *) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "TravelsNotesReqViewController") as! TravelsNotesReqViewController
            vc.travel_id = rideDetail!.travelId
            //vc.post.append(posts[indexPath.row])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func trackWasPressed(_ sender: UIButton) {
        //        print("going to track ride view controller")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrackRideViewController") as! TrackRideViewController
        vc.currentRide = rideDetail
        self.navigationController?.pushViewController(vc, animated: true)
        self.showTracking()
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
    
    @IBAction func cancelWasPressed(_ sender: UIButton) {
        sendRequests(with: "CANCELLED")
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
    
    func sendRequests(with status:String){
        //        let params = ["ride_id":rideDetail!.rideId,"status":status]
        var params = [String:String]()
        if (requestPage == RequestView.completed && rideDetail?.Travel_Status == "STARTED")
        {
            print("sendRequests pending")
            params = ["ride_id":rideDetail!.rideId,"status":status, "travel_id":rideDetail!.travelId, "travel_status":travel_status,"by":"user"]
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
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
                        
                        // vc.requestPage = RequestView.completed
                        //vc.PlatformString = "COMPLETED"
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
                // if status == "COMPLETED"{
                // let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
                //  self.navigationController?.pushViewController(vc, animated: true)
                //vc.requestPage = RequestView.completed
                //vc.PlatformString = "COMPLETED"
                
                //}
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
                alert.addAction(done)
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (message) in
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func updateTravelCounterFirebase(with status:String) {
        print("updateTravelCounteR")
        print(status)
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
        fare.text = rideDetail?.amount
        status.text = self.paymentStatus
        ///************************************
        EmtySet.text = rideDetail?.emptySet
        let inFormatter = DateFormatter()
        inFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        inFormatter.dateFormat = "HH:mm:ss"
        
        let outFormatter = DateFormatter()
        outFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        outFormatter.dateFormat = "HH:mm"
        
        let date_ = inFormatter.date(from: rideDetail!.time)!
        let outStr = outFormatter.string(from: date_)
        
        time.text = outStr
        VechileColor.text = rideDetail?.color
        vehicle.text = rideDetail?.model
        PickUpPoint.text = rideDetail?.pickup_point
        DriverRate.text = rideDetail?.DriverRate
        Travels_Count.text = rideDetail?.Travels_Count
        
        VechileNo.text = rideDetail?.vehicle_no
        date.text = rideDetail?.date
        FareRate.text = rideDetail?.FareRate
        
        // by ibrahim
        if let urlString = URL(string: (rideDetail?.driverAvatar)!){
            //            print("ibrahim")
            //            print(DriverAvatarURL)
            DriverAvatar.kf.setImage(with: urlString)
        }
        if let urlString1 = URL(string: (rideDetail?.vehicle_info)!){
            DriverCar.kf.setImage(with: urlString1)
        }
        
        
        // Set up payPalConfig
        //payPalConfig.acceptCreditCards = true
        
        if self.paymentStatus != "" || self.paymentMode == "OFFLINE"
        {
            print("payment mode offline or status != ")
            if self.paymentMode == "OFFLINE" {
                print("payment mode offline")
                status.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "DetailReqVC_offlinePayment", comment: "")
            }else {
                print("payment mode not offline ")
                status.text = self.paymentStatus
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
                status.text = "UNPAID"
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
                
                if (self.requestPage == RequestView.accepted && (self.travel_status == "STARTED" || self.travel_status == "PAID")){
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AcceptDetailReqViewController") as! AcceptDetailReqViewController
                    vc.requestPage = RequestView.accepted
                    vc.rideDetail = self.rideDetail
                    vc.rideDetail?.Travel_Status = self.travel_status
                    vc.rideDetail?.paymentMode = self.paymentMode
                    vc.rideDetail?.paymentStatus = self.paymentStatus
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
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
}

extension String {
    
    func split(regex pattern: String) -> [String] {
        
        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }
        
        let nsString = self as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.components(separatedBy: stop)
    }
}

extension DetailReqViewController : BTViewControllerPresentingDelegate{
    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        
    }
    
    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        
    }
}

extension DetailReqViewController : BTAppSwitchDelegate {
    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
        
    }
    
    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
        
    }
    
    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
        
    }
}
