//
//  SignUpViewController.swift
//  Taxi
//
//  Created by Bhavin on 04/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet var nameText: UITextField!
    @IBOutlet var lastNameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var OptionalLbl: UILabel!
    
    @IBOutlet var profileImageView: UIImageView!
    var imagePicker:UIImagePickerController!
    
    var UserData = [String:Any]()
    
    var is_image_selected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if LocalizationSystem.sharedInstance.getLanguage() == "en" {
        //            if let revealController = self.revealViewController() {
        //                revealController.panGestureRecognizer()
        //                let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
        //                                                 style: .plain, target: revealController,
        //                                                 action: #selector(SWRevealViewController.revealToggle(_:)))
        //                self.navigationItem.leftBarButtonItem = menuButton
        //
        //            }
        //        }
        //        else{
        //            // error
        //            let revealController = self.revealViewController()
        //            revealController!.panGestureRecognizer().isEnabled = false
        //
        //
        //
        //            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //
        //            // Here menuViewController is SideDrawer ViewCOntroller
        //            let sidemenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        //            revealViewController().rightViewController = sidemenuViewController
        //            self.revealViewController().rightViewRevealWidth = self.view.frame.width * 0.8
        //            let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
        //                                             style: .plain, target: SWRevealViewController(),
        //                                             action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        //            self.navigationItem.leftBarButtonItem = menuButton
        //        }
        
        signUpButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_signUpButton", comment: ""), for: .normal)
        backButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "BackButton", comment: ""), for: .normal)
        
        nameText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_nameText", comment: ""),comment: ""))
        nameText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: nameText.frame.height))
        lastNameText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_last_nameText", comment: ""),comment: ""))
        lastNameText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: lastNameText.frame.height))
        emailText.cornerRadius(radius: 20.0, andPlaceholderString: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_emailText", comment: ""),comment: ""))
        emailText.paddedTextField(frame: CGRect(x: 0, y: 0, width: 25, height: emailText.frame.height))
        OptionalLbl.text = LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_OptionalText", comment: "")
        
        
        signUpButton.corner(radius: 20.0, color: .white, width: 1.0)
        //loginButton.corner(radius: 20.0, color: .white, width: 2.0)
        backButton.corner(radius: 5.0, color: .white, width: 1.0)
        //------------------
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func openImagePicker(_ sender:Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func registerWasPressed(_ sender: Any) {
        if (nameText.text?.count == 0 || lastNameText.text?.count == 0) {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill required fields.",comment: ""), for: self)
            
        }
        else if (is_image_selected == false){
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SignUpVC_pickup_image", comment: ""),comment: ""), for: self)
            
        }
        else {
            handleSignUp()
        }
    }
    
    @IBAction func backWasPressed(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func handleSignUp() {
        HUD.show(to: self.view)
        print("h1")
        // just for testing----------------
        //        Auth.auth().signIn(withEmail: "eng.ibrahim.meree@gmail.com", password: "1234!@#$") { user, error in
        //            if error == nil && user != nil {
        ////                self.dismiss(animated: false, completion: nil)
        //                print("h2")
        //            } else {
        //                print("Error logging in: \(error!.localizedDescription)")
        //            }
        //        }
        // just for testing----------------
        print("h3")
        guard let image = profileImageView.image else { return }
        self.uploadProfileImage(image) { url in
            
            if url != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameText.text!  + " " + self.lastNameText.text!
                changeRequest?.photoURL = url
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        print("h4")
                        HUD.hide(to: self.view)
                        self.saveProfile(username: self.nameText.text!  + " " + self.lastNameText.text!, profileImageURL: url!) { success in
                            if success {
                                print("success")
                                print("h5")
                                //self.dismiss(animated: true, completion: nil)
                            } else {
                                print("error")
                            }
                        }
                        
                    } else {
                        //                        print("Error: \(error!.localizedDescription)")
                        print("error")
                    }
                }
            } else {
                print("error")
            }
        }
    }
    
    func validateTextFields() -> Bool {
        if (nameText.text?.count == 0 || lastNameText.text?.count == 0) {
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: NSLocalizedString("Please fill required fields.",comment: ""), for: self)
            return false
        }
        else {
            return true
        }
    }
    
    func loginByMobile(mobileNumber:String ,password:String){
        var params = [String:Any]()
        //params["email"] = self.emailText.text
        params["mobile"] = mobileNumber
        params["password"] = password
        params["utype"] = "0"  // utype = "0" means user and "1" = driver
        
        APIRequestManager.request(apiRequest: APIRouters.LoginUser(params), success: { (responseData) in
            HUD.hide(to: self.view)
            if let data = responseData as? [String:Any] {
                let userData = User(userData: data)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
                UserDefaults.standard.set(encodedData, forKey: "user")
                UserDefaults.standard.set(data["key"], forKey: "key")
                self.moveToDashboard()
            }
        }, failure: { (message) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
        }, error: { (err) in
            HUD.hide(to: self.view)
            Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message: err.localizedDescription, for: self)
        })
    }
    
    func moveToDashboard(){
        let menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let dashboard = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
        let dashboardNav = UINavigationController(rootViewController: dashboard)
        let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = revealController
    }
    
    func saveProfile(username:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        HUD.show(to: self.view)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        let userObject = [
            "username": username,
            "photoURL": profileImageURL.absoluteString
            ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
                HUD.hide(to: self.view)
                self.requsetSignupForDB(photoURL: profileImageURL.absoluteString)
                
            }
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                }
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    func requsetSignupForDB(photoURL:String){
        HUD.show(to: self.view)
        if validateTextFields() {
            let manager = LocationManager.sharedInstance
            manager.reverseGeocodeLocationWithLatLong(latitude: manager.latitude, longitude: manager.longitude) { (response, placemark, str) in
                if response != nil {
                    var params = [String:Any]()
                    params["email"] = self.emailText.text ?? ""
                    params["name"]  = self.nameText.text! + " " + self.lastNameText.text!
                    params["mobile"] = self.UserData["mobile"]!//self.mobileNumText.text
                    params["password"] = self.UserData["password"]!//self.passwordText.text
                    params["latitude"] = response?["latitude"]
                    params["longitude"] = response?["longitude"]
                    params["country"] = response?["country"]
                    params["state"] = response?["administrativeArea"]
                    params["city"] = response?["locality"]
                    params["avatar"] = photoURL
                    params["gcm_token"] = self.UserData["gcm_token"]!
                    params["utype"] = "0" // utype = "0" means user and "1" = driver
                    params["mtype"] = "0" // mtype = "0" means iOS  and "1" = Android
                    
                    //print(params)
                    APIRequestManager.request(apiRequest: APIRouters.RegisterUser(params), success: { (responseData) in
                        HUD.hide(to: self.view)
                        //Common.showAlert(with: NSLocalizedString("Error!!", comment: ""), message:"", for: self)
                        let alert = UIAlertController(title: NSLocalizedString("success", comment: ""), message: NSLocalizedString("You are successfully registered", comment: ""), preferredStyle: .alert)
                        let done = UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .default, handler: { (action) in
                            _ = self.navigationController?.popViewController(animated: true)
                            
                            self.loginByMobile(mobileNumber: self.UserData["mobile"]! as! String ,password: self.UserData["password"]! as! String)
                            
                            
                            //                            self.loginByMobile(mobileNumber: self.UserData["mobile"]! as! String ,password: self.UserData["password"]! as! String)
                            // just for testing
                            // self.loginByMobile(mobileNumber: "0988088320" ,password: "12345")
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
            }
        }
    }
}
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        is_image_selected = false;
        picker.dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.profileImageView.image = pickedImage
        is_image_selected = true;
        picker.dismiss(animated: true, completion: nil)
    }
}
