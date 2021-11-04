//
//  MapViewController.swift
//  Taxi
//
//  Created by Bhavin on 04/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class MapViewController: UIViewController {
    
    @IBOutlet var mapview: GMSMapView!
    var infoView = TaxiInfo()
    var pickupView = PickUpView()
    var markerView = MarkerView()
    var taxiFare:Fare?
    
    var isPickup = Bool()
    var isDrop = Bool()
    var travels: Travel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "roamu"
        
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
        
        // -- setup delegates --
        mapview.delegate = self
        
        // -- call required API --
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 ) {
            self.loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(){
        // -- get current coordintes --
        let manager = LocationManager.sharedInstance
        let latitude = manager.latitude
        let longitude = manager.longitude
        
        // -- set camera position --
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom:19)
        mapview.animate(to: camera)
        mapview.isMyLocationEnabled = true
        
        // -- set up parameters/headers for request --
        let params = ["lat":latitude,"long":longitude]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        // -- call request --   
        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.GetTravels2(params,headers)).responseObject { (response: DataResponse<Travels>) in
            //debugPrint(response)
            print("ibrahim")
            HUD.hide(to: self.view)
            if response.result.isSuccess{
                print("response ibrahim")
                print(response.result)
                print(response.data)
                if response.result.value?.status == true , ((response.result.value?.travels) != nil){
                    //                    self.travels = (response.result.value?.travels)!
                    if let locations = response.value?.travels {
                        locations.forEach {
                            let pickupArray = $0.pickLocation.split(separator: ",")
                            //rideDetail?.pickLocation.split(regex: "[, ]+")//rideDetail?.pickLocation.components(separatedBy: ",")
                            print(pickupArray)
                            // ibrahim was here
                            let pickLat: Double = Double(pickupArray[0])!
                            let pickLong: Double = Double(pickupArray[1])!
                            
                            if let lat = Double(pickLat) as? Double, let long = Double(pickLong) as? Double {
                                let marker = GMSMarker()
                                marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                marker.userData = $0
                                marker.title = $0.pickupAddress
                                marker.snippet = $0.driverName
                                marker.map = self.mapview
                                
                            } else {
                                debugPrint($0)
                            }
                        }
                    }
                } else {
                    Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.value?.error, for: self)
                }
            }
            
            if response.result.isFailure{
                Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: response.error?.localizedDescription, for: self)
            }
        }
    }
    
    func setupInfoView(infoView:UIView){
        infoView.translatesAutoresizingMaskIntoConstraints = false
        // -- add leading constraint --
        let leadingConstraint = NSLayoutConstraint(item: infoView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .leading,
                                                   multiplier: 1, constant: 0)
        // -- add trailing constraint --
        let trailingConstraint = NSLayoutConstraint(item: infoView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .trailing,
                                                    multiplier: 1, constant: 0)
        // -- add bottom constraint --
        let bottomConstraint = NSLayoutConstraint(item: infoView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .bottom,
                                                  multiplier: 1, constant: -15)
        // -- add height constraint --
        let heightConstraint = NSLayoutConstraint(item: infoView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1, constant: 150)
        // -- activate constraints --
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint])
    }
    
    func setupPickupView(pickView:UIView){
        pickView.translatesAutoresizingMaskIntoConstraints = false
        // -- add leading constraint --
        let leadingConstraint = NSLayoutConstraint(item: pickView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .leading,
                                                   multiplier: 1, constant: 0)
        // -- add trailing constraint --
        let trailingConstraint = NSLayoutConstraint(item: pickView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .trailing,
                                                    multiplier: 1, constant: 0)
        // -- add top constraint --
        let bottomConstraint = NSLayoutConstraint(item: pickView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .top,
                                                  multiplier: 1, constant: 80)
        // -- add height constraint --
        let heightConstraint = NSLayoutConstraint(item: pickView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1, constant: 81)
        
        // -- activate constraints --
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint])
    }
    
    func updateInfoViewDetails(data:Travel){
        //        infoView.distance.text = (taxiFare?.cost)! + (taxiFare?.unit)! //String(format: "%.2f", Double(data.distance)!) + "km"
        infoView.driverName.text = data.driverName
        infoView.from.text = data.pickupAddress
        infoView.to.text = data.dropAddress
        self.travels = data
        
        
        //        placesClient = GMSPlacesClient.shared()
        //        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
        //            if let error = error {
        //                print("Pick Place error: \(error.localizedDescription)")
        //                return
        //            }
        //
        //            self.nameLabel.text = "No current place"
        //            self.addressLabel.text = ""
        //
        //            if let placeLikelihoodList = placeLikelihoodList {
        //                let place = placeLikelihoodList.likelihoods.first?.place
        //                if let place = place {
        //                    self.nameLabel.text = place.name
        //                    self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
        //                        .joined(separator: "\n")
        //                }
        //            }
        //        })
        
        //        let pickupArray = data.pickLocation.split(separator: ",")
        //        //rideDetail?.pickLocation.split(regex: "[, ]+")//rideDetail?.pickLocation.components(separatedBy: ",")
        //        print(pickupArray)
        //        // ibrahim was here
        //        let pickLat: Double = Double(pickupArray[0])!
        //        let pickLong: Double = Double(pickupArray[1])!
        //
        //        LocationManager.sharedInstance.reverseGeocodeLocationWithLatLong(latitude: Double(pickLat), longitude: Double(pickLong)) { (response, placemark, error) in
        //            //print(response as Any)
        //            if placemark != nil {
        //                let addressLines = placemark?.addressDictionary!["FormattedAddressLines"] as! [String]
        //                var address = ""
        //                if addressLines.count > 0 {
        //                    address = addressLines.joined(separator: ", ")
        //                } else {
        //                    address = ""
        //                }
        //
        //                DispatchQueue.main.async {
        //                    self.infoView.currentLocation.text = address
        //                }
        //            } else {
        //                //print("Problem with the data received from geocoder")
        //            }
        //        }
    }
    
    func removeUnwantedViews(){
        if infoView.isDescendant(of: view) {
            UIView.animate(withDuration: 1.0, animations: {
                self.infoView.alpha = 0
                self.pickupView.alpha = 0
            }) { (finished) in
                if finished {
                    self.infoView.removeFromSuperview()
                    self.pickupView.removeFromSuperview()
                    //                    if self.tableView.isDescendant(of: self.view){
                    //                        self.tableView.removeFromSuperview()
                    //                    }
                }
            }
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {            
            let addressLines = containsPlacemark.addressDictionary!["FormattedAddressLines"] as! [String]
            var address = ""
            if addressLines.count > 0 {
                address = addressLines.joined(separator: ", ")
            } else {
                address = ""
            }
            
            // -- set address as pickup location --
            pickupView.pickupButton.setTitle(address, for: .normal)
        }
    }
}
extension MapViewController:GMSMapViewDelegate,PickUpViewDelegate,TaxiInfoDelegate,UITextFieldDelegate {
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        markerView = MarkerView.loadFromNib()
        markerView.titleText.text = marker.title
        markerView.descriptionText.text = marker.snippet
        return markerView
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        removeUnwantedViews()
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.4, animations: {
            self.infoView.layer.position.y += 200
            self.pickupView.layer.position.y -= 150
        }) { (finished) in
            if finished {
                self.infoView.removeFromSuperview()
                self.pickupView.removeFromSuperview()
                //                if self.tableView.isDescendant(of: self.view){
                //                    self.tableView.removeFromSuperview()
                //                }
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if infoView.isDescendant(of: view) {
            if let userData = marker.userData as? Travel {
                updateInfoViewDetails(data: userData)
                infoView.markerData = userData
            }
        } else {
            // -- infoView --
            infoView = TaxiInfo.loadFromNib()
            self.view.addSubview(infoView)
            infoView.delegate = self
            setupInfoView(infoView: infoView)
            
            infoView.layer.position.y += 200
            infoView.slideUpSpring(toPosition: 200, withDuration: 1.0, delay: 0.0, andOptions: [.curveEaseInOut])
            
            if let userData = marker.userData as? Travel {
                updateInfoViewDetails(data: userData)
                infoView.markerData = userData
            }
            
            // -- PickUpView --
            //            pickupView = PickUpView.loadFromNib()
            //            pickupView.delegate = self
            //            self.view.addSubview(pickupView)
            //            setupPickupView(pickView: pickupView)
            
            //            pickupView.pickupButton.delegate = self
            //            pickupView.dropButton.delegate = self
            
            //            pickupView.layer.position.y -= 150
            //            pickupView.slideDownSpring(toPosition: 150, withDuration: 1.0, delay: 0.0, andOptions: [.curveEaseInOut])
        }
    }
    
    func currentLocationWasPressed(){
        //print("currentLocationWasPressed")
        let lat = LocationManager.sharedInstance.latitude
        let long = LocationManager.sharedInstance.longitude
        
        LocationManager.sharedInstance.reverseGeocodeLocationWithLatLong(latitude: lat, longitude: long) { (response, placemark, error) in
            print(response as Any)
            if placemark != nil {
                let addressLines = placemark?.addressDictionary!["FormattedAddressLines"] as! [String]
                var address = ""
                if addressLines.count > 0 {
                    address = addressLines.joined(separator: ", ")
                } else {
                    address = ""
                }
                
                self.pickupView.pickupButton.setTitle(address, for: .normal)
            } else {
                print("Problem with the data received from geocoder")
            }
        }
    }
    
    func dismissWasPressed(){
        pickupView.dropButton.setTitle("Drop Location", for: .normal)
        pickupView.resignFirstResponder()
    }
    
    func pickupAction(sender: UIButton) {
        isPickup = true
        autocompleteClicked()
    }
    
    func dropAction(sender: UIButton) {
        isDrop = true
        autocompleteClicked()
    }
    
    func requestRideClicked() {
        removeUnwantedViews()
        //print("ibrahim was here: " + (pickupView.pickupButton.titleLabel?.text)!)
        // -- move to next view --
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
        vc.rideData = ["pickup": travels!.pickupAddress,
                       "drop": travels!.dropAddress,
                       "pickupLocation": travels!.pickLocation,
                       "dropLocation": travels!.dropLocation,
                       "driverName": travels!.driverName,
                       "driverCity": travels!.driverCity,
                       "driverVehicle": travels!.vehicle_no,
                       "mobileNum":travels!.driverMobile,
                       "vehicle":travels!.vehicle_no,
                       "smoked":travels!.smoked,
                       "passengers":travels!.available_set,
                       "empty_set":travels!.empty_set as? String ?? "0",
                       "driver_id": travels!.driverId,
                       "travel_id": travels!.travel_id,
                       //                              "ride_id" : travels![travel_index],
            "amount" : travels!.amount,
            "time" : travels!.travel_time,
            "date" : travels!.travel_date,
            "model" : travels!.model,
            "color" : travels!.color,
            "vehicle_no" : travels!.vehicle_no,
            "pickup_point" : travels!.pickup_point,
            "DriverRate" : travels!.DriverRate,
            "FareRate" : travels!.FareRate,
            "travels_Count" : travels!.Travels_Count,
            "booked_set": travels!.booked_set]
        vc.confirmRequestPage = confirmRequestView.RequestsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
}
extension MapViewController: GMSAutocompleteViewControllerDelegate  {
    
    func autocompleteClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = place.formattedAddress ?? ""
        
        if isPickup  {
            pickupView.pickupButton.setTitle(address, for: .normal)
            isPickup = false
            
        } else if isDrop {
            pickupView.dropButton.setTitle(address, for: .normal)
            isDrop = false
        }
        
        
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "")")
        print("Place attributions: \(place.attributions?.string ?? "")")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
