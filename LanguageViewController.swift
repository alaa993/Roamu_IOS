//
//  LanguageViewController.swift
//  Taxi
//
//  Created by alaa on 4/28/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import UIKit


class LanguageViewController: UIViewController {
    @IBOutlet var changelang: UIButton!
    @IBOutlet var EngLangButton: UIButton!
    @IBOutlet var AraLangButton: UIButton!
    
    var window: UIWindow?
    //@IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem10", comment: "")
        
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            let revealController = self.revealViewController()
            revealController!.panGestureRecognizer().isEnabled = false
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
        changelang.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LanguageVC_button", comment: ""), for: .normal)
        EngLangButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LanguageVC_English", comment: ""), for: .normal)
        EngLangButton.corner(radius: 22.5, color: UIColor.white, width: 1.0)
        AraLangButton.setTitle(LocalizationSystem.sharedInstance.localizedStringForKey(key: "LanguageVC_Arabic", comment: ""), for: .normal)
        AraLangButton.corner(radius: 22.5, color: UIColor.white, width: 1.0)
    }
    
    @IBAction func ChangeLangToEng(_ sender: Any) {
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
        self.updateLanguage(lang_nu:"2", lang_text:"en")
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ChangeLangToAr(_ sender: Any) {
        LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
        updateLanguage(lang_nu:"1", lang_text:"ar")
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateLanguage(lang_nu:String, lang_text:String){
        print("ibrahim change language")
        //lang_nu 1 => arabic, 2 => english
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["lang_nu"] = lang_nu
        params["lang_text"] = lang_text
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        APIRequestManager.request(apiRequest: APIRouters.UpdateLanguage(params,headers), success: { (responseData) in
            print("success changing language")
        }, failure: { (message) in
        }, error: { (err) in
        })
    }
    
}
