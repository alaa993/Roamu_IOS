//
//  SplashViewController.swift
//  Taxi
//
//  Created by Bhavin on 04/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import FirebaseUI

class SplashViewController: UIViewController {
    
    fileprivate var authStateDidChangeHandle: AuthStateDidChangeListenerHandle?
    fileprivate(set) var auth: Auth?
    fileprivate(set) var authUI: FUIAuth?
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var loginButtonWithFirebase: UIButton!
    
    @IBOutlet var changelang: UIButton!
    @IBOutlet var EngLangButton: UIButton!
    @IBOutlet var AraLangButton: UIButton!
    
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changelang.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LanguageVC_button", comment: ""), for: .normal)
        EngLangButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LanguageVC_English", comment: ""), for: .normal)
        EngLangButton.corner(radius: 22.5, color: UIColor.white, width: 1.0)
        AraLangButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LanguageVC_Arabic", comment: ""), for: .normal)
        AraLangButton.corner(radius: 22.5, color: UIColor.white, width: 1.0)
        
        loginButtonWithFirebase.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SplashVC_loginButtonWithFirebase", comment: ""), for: .normal)
        loginButtonWithFirebase.corner(radius: 22.5, color: UIColor.white, width: 2.0)
        
        loginButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "SplashVC_loginButtonWithFirebase", comment: ""), for: .normal)
        loginButton.corner(radius: 22.5, color: UIColor.white, width: 1.0)
        
        registerButton.corner(radius: 22.5, color: UIColor.white, width: 2.0)
        
        loginButton.isHidden = true
        registerButton.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangeLangToEng(_ sender: Any) {
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
        
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ChangeLangToAr(_ sender: Any) {
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
        
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func loginAsDriverWasPressed(_ sender: Any) {
        let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(loginVc, animated: true)
    }
    
    @IBAction func RegistrainonButtonAction(_ sender: Any) {
        
        auth = Auth.auth()
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let phoneProvider = FUIPhoneAuth.init(authUI: authUI!)
        authUI?.providers = [phoneProvider]
        DispatchQueue.main.async {
            phoneProvider.signIn(withPresenting: self, phoneNumber: nil);
        }
        
    }
    
    func loginByMobile(mobileNumber:String ,password:String , token:String){
        var params = [String:Any]()
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
            //Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            self.moveToSignUpPage(mobileParam: mobileNumber , passwordParam: password, token:token)
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
    
    func moveToSignUpPage(mobileParam:String , passwordParam:String , token:String){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.UserData = ["mobile":mobileParam, "password":passwordParam, "gcm_token":token ?? ""]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SplashViewController:FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if error != nil {
            return
        }
        else{
            loginByMobile(mobileNumber: String((authDataResult?.user.phoneNumber)!),
                          password: String((authDataResult?.user.uid)!),
                          token: String((authDataResult?.user.refreshToken)!))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
}
