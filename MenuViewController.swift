//
//  MenuViewController.swift
//  Taxi
//
//  Created by Bhavin on 06/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class MenuViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var nameText: UILabel!
    @IBOutlet var avatar: UIImageView!
    
    var menuItems = [String]()
    var selectedIndex = 0
    
    //----------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- ViewController Lifecycle
    //----------------------------------------------------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
        //            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SWRevealViewController.rightRevealToggle(_:)))
        //        }
        //        else{
        //            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SWRevealViewController.revealToggle(_:)))
        //        }
        
        // Do any additional setup after loading the view.
        menuItems = [LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem0", comment: ""),
                     LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem19", comment: ""),//maps
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem20", comment: ""),
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem1", comment: ""),
            //                     LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem3", comment: ""),
            //                     LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem4", comment: ""),
            //                     LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem5", comment: ""),
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem6", comment: ""), //promo codes
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem7", comment: ""), //Profile //3
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem18", comment: ""),//5 group management
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem11", comment: ""), //Social media platform //4
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem8", comment: ""),//general provisions //5
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem13", comment: ""),//Success and Profit // 6
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem9", comment: ""), //about us //7
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem14", comment: ""), // contact us //8
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem15", comment: ""), // Nominate Driver //9
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem10", comment: ""), //Language //10
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem16", comment: ""), //Notificatoin //11
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem17", comment: ""), //Share app //12
            LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem12", comment: "")] //Log Out //13
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        
        tableView.tableFooterView = UIView()
        
        // -- make circle imageview --
        avatar.corner(radius: avatar.frame.width / 2, color: .black, width: 0.0)
    }
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isUserInteractionEnabled = true
        
        if let data = UserDefaults.standard.data(forKey: "user"){
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
            nameText.text = userData?.name
            /* if let urlString = URL(string: (userData?.avatar)!){
             avatar.kf.setImage(with: urlString)
             }*/
            getImgProfile()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getImgProfile() {
        
        Database
            .database()
            .reference()
            .child("users")
            .child("profile")
            .child(Auth.auth().currentUser!.uid)
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                
                guard let dict = snapshot.value as? [String:Any] else {
                    print("Error")
                    return
                }
                
                let photoURL = (dict["photoURL"] as? String)!
                if let urlString = URL(string: (photoURL)){
                    
                    self.avatar.kf.setImage(with: urlString)
                }
                //                print("tttttttt",photoURL)
                // let priceAd = dict["priceAd"] as? String
            })
    }
    
}

//--------------------------------------------------------------------------------------------------------------------------------------------------
// MARK:- Extensions
//--------------------------------------------------------------------------------------------------------------------------------------------------
extension MenuViewController: UITableViewDelegate,UITableViewDataSource {
    
    //----------------------------------------------------------------------------------------------------------------------------------------------
    // MARK:- UITableView Delegate And DataSource
    //----------------------------------------------------------------------------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        let textLabel = cell?.contentView.viewWithTag(10) as? UILabel
        textLabel?.text = menuItems[indexPath.row]
        
        if selectedIndex == indexPath.row {
            textLabel?.textColor = UIColor(red: 255/255.0, green: 202/255.0, blue: 38/255.0, alpha: 1.0)
        } else {
            textLabel?.textColor = UIColor.darkGray
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        tableView.isUserInteractionEnabled = false
        switch indexPath.row {
        case 0:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 1:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 2:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "AcceptRequestsViewController") as! AcceptRequestsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 3:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
            vc.requestPage = RequestView.all_requests
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
            //        case 3:
            //            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
            //            vc.requestPage = RequestView.completed
            //            let nav = UINavigationController(rootViewController: vc)
            //            nav.setViewControllers([vc], animated:true)
            //            self.revealViewController().setFront(nav, animated: true)
            //            self.revealViewController().pushFrontViewController(nav, animated: true)
            //        case 4:
            //            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
            //            vc.requestPage = RequestView.cancelled
            //            let nav = UINavigationController(rootViewController: vc)
            //            nav.setViewControllers([vc], animated:true)
            //            self.revealViewController().setFront(nav, animated: true)
            //            self.revealViewController().pushFrontViewController(nav, animated: true)
            //        case 5:
            //            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
            //            vc.requestPage = RequestView.requested
            //            let nav = UINavigationController(rootViewController: vc)
            //            nav.setViewControllers([vc], animated:true)
            //            self.revealViewController().setFront(nav, animated: true)
        //            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 4:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
            vc.requestPage = RequestView.promo
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 5:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 6:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "GroupManagementViewController") as! GroupManagementViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 7:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "PlatformViewController") as! PlatformViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 8:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProvisionsViewController") as! ProvisionsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 9:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProfitViewController") as! ProfitViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 10:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 11:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ContactUsViewController") as! ContactUsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 12:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "NominateDriverViewController") as! NominateDriverViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 13:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "LanguageViewController") as! LanguageViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 14:
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
            let nav = UINavigationController(rootViewController: vc)
            nav.setViewControllers([vc], animated:true)
            self.revealViewController().setFront(nav, animated: true)
            self.revealViewController().pushFrontViewController(nav, animated: true)
        case 15:
            let items = ["Let me recommend you this application\n","http://onelink.to/ve7c4k"]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            present(ac, animated: true)
        case 16:
            if LocalizationSystem.sharedInstance.getLanguage() == "ar"
            {
                Common.instance.removeUserdata()
                self.revealViewController().revealToggle(nil)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
                let nav = UINavigationController(rootViewController: vc)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = nav
                LocalizationSystem.sharedInstance.setLanguage(languageCode: "ar")
                print("arabic")
            }
            if LocalizationSystem.sharedInstance.getLanguage() == "en"
            {
                Common.instance.removeUserdata()
                self.revealViewController().revealToggle(nil)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
                let nav = UINavigationController(rootViewController: vc)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = nav
                LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
                print("english")
            }
            else
            {
                Common.instance.removeUserdata()
                self.revealViewController().revealToggle(nil)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
                let nav = UINavigationController(rootViewController: vc)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = nav
                LocalizationSystem.sharedInstance.setLanguage(languageCode: "en")
                print("english")
            }
            
        default:
            //            self.dismiss(animated: true, completion: nil)
            break;
        }
    }
}
