//
//  AppDelegate.swift
//  Taxi
//
//  Created by Bhavin on 03/03/17.
//  Copyright ©️ 2017 icanStudioz. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Fabric
import Crashlytics
import Mapbox
import Braintree


let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1)
let secondaryColor = UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var locationManager = LocationManager.sharedInstance
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // paypal by ibrahim marie
        BTAppSwitch.setReturnURLScheme("com.alaan.roamu.payments")
        // Override point for customization after application launch.
        
        // -- Use Firebase library to configure APIs --
        
        
        //-----------------------------------------------------------
        // auth for platform application by ibrahim
        let authListener = Auth.auth().addStateDidChangeListener { auth, user in
            
            if user != nil {
                
                UserService.observeUserProfile(user!.uid) { userProfile in
                    UserService.currentUserProfile = userProfile
                }
            }
        }
        //-----------------------------------------------------------
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,selector: #selector(self.tokenRefreshNotification),
                                               name: .InstanceIDTokenRefresh,
                                               object: nil)
        // -- register for remote notifications
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Override point for customization after application launch.
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            //FIRMessaging.messaging().remoteMessageDelegate = self
            
        }
        else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        application.registerForRemoteNotifications()
        
        
        
        
        // -- google maps provide api key --
        //  GMSServices.provideAPIKey(configs.googleAPIKey)
        GMSServices.provideAPIKey("AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU")
        
        // -- google places provide api key --
        // GMSPlacesClient.provideAPIKey(configs.googlePlaceAPIKey)
        GMSPlacesClient.provideAPIKey("AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU")
        // -- google search api key for search nearby by ibrahim
        GoogleApi.shared.initialiseWithKey("AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU")
        
        // -- mapbox provide api key --
        //ibrahim was here
        //MGLAccountManager.setAccessToken("")
        
        //TODO: - Enter your credentials
        //PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox: configs.paypal_ClientId])
        
        
        // -- enable IQKeyboardManager --
        //ibrahim was here
        IQKeyboardManager.shared.enable = true
        //IQKeyboardManager.sharedManager().enable = true
        
        // -- start location manager --
        locationManager.startUpdatingLocation()
        
        // -- set navigationbar appearance --
        UINavigationBar.appearance().tintColor = UIColor.black
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: customFont.medium, size: 19.0)!,
                                                             NSAttributedString.Key.foregroundColor: UIColor.black ]
        
        // -- set rootview controller --
        if Common.instance.isUserLoggedIn() {
            
            
            
            //change language
            if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
                self.updateLanguage(lang_nu:"1", lang_text:"ar")
            }
            else{
                self.updateLanguage(lang_nu:"2", lang_text:"en")
            }
            
            if (Auth.auth().currentUser != nil && Common.instance.getUserId().count > 0) {
                loginByMobile(mobileNumber: String((Auth.auth().currentUser?.phoneNumber)!),
                              password: String((Auth.auth().currentUser?.uid)!),
                              token: String((Auth.auth().currentUser?.refreshToken)!))
            }
            
            
            //
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let menu = mainStoryBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            let dashboard = mainStoryBoard.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
            let dashboardNav = UINavigationController(rootViewController: dashboard)
            let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
            
            self.window?.rootViewController = revealController
        }
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func loginByMobile(mobileNumber:String ,password:String , token:String){
        var params = [String:Any]()
        //params["email"] = self.emailText.text
        params["mobile"] = mobileNumber
        params["password"] = password
        params["utype"] = "0"  // utype = "0" means user and "1" = driver
        
        APIRequestManager.request(apiRequest: APIRouters.LoginUser(params), success: { (responseData) in
            if let data = responseData as? [String:Any] {
                let userData = User(userData: data)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: userData)
                UserDefaults.standard.set(encodedData, forKey: "user")
                UserDefaults.standard.set(data["key"], forKey: "key")
                
                self.moveToDashboard()
            }
        }, failure: { (message) in
            //Common.showAlert(with: NSLocalizedString("Alert!!", comment: ""), message: message, for: self)
            self.moveToSignUpPage(mobileParam: mobileNumber , passwordParam: password, token:token)
        }, error: { (err) in
        })
    }
    
    func moveToDashboard(){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let menu = mainStoryBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let dashboard = mainStoryBoard.instantiateViewController(withIdentifier: "FindTravelViewController") as! FindTravelViewController
        let dashboardNav = UINavigationController(rootViewController: dashboard)
        let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
        self.window?.rootViewController = revealController
    }
    
    func moveToSignUpPage(mobileParam:String , passwordParam:String , token:String){
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let menu = mainStoryBoard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        let dashboard = mainStoryBoard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        //        dashboard.UserData = ["mobile":mobileParam, "password":passwordParam,"gcm_token":token]
        let dashboardNav = UINavigationController(rootViewController: dashboard)
        let revealController = SWRevealViewController(rearViewController: menu, frontViewController: dashboardNav)
        self.window?.rootViewController = revealController
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        locationManager.stopUpdatingLocation()
        //        FIRMessaging.messaging().disconnect()
        //        print("Disconnected from FCM.")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        locationManager.startUpdatingLocation()
        connectToFcm()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // [START receive_message]
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // This notification is not auth related, developer should handle it.
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if userInfo["gcm.message_id"] != nil {
            //            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        //        print(userInfo)
    }
    
    func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
        //        print(error.localizedDescription)
    }
    
    // [END receive_message]
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.unknown)
        
        //        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
        //Messaging.messaging().apnsToken = deviceToken
        //        print(deviceToken.description)
        let token1 = Messaging.messaging().fcmToken
        print("FCM token: \(token1 ?? "")")
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["Token"] = token1
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        APIRequestManager.request(apiRequest: APIRouters.UpdateToken(params,headers), success: { (responseData) in
            print("success")
        }, failure: { (message) in
            
        }, error: { (err) in
        })
        // task.resume()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.alaan.roamu.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    
    
    
    // [START: Handle Notification]
    func handleNotification(userInfo:[AnyHashable:Any]){
        NotificationCenter.default.post(name: Firebase.Notification.Name("NotificationRecieved"), object: nil)
    }
    // [END: Handle Notification]
    
    
    // [START refresh_token]
    @objc func tokenRefreshNotification(notification: NSNotification) {
        //          ibrahim was here
        //        if let refreshedToken = InstanceID.instanceID().token() {
        //            print("InstanceID token: \(refreshedToken)")
        //
        //            let defaults = UserDefaults.standard
        //            defaults.set(refreshedToken, forKey: "DEVICE_TOKEN")
        //            defaults.synchronize()
        //
        //            if Common.instance.getUserId().count > 0{
        //                self.updateToken(token: refreshedToken)
        //            }
        //        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    
    // [START connect_to_fcm]
    
    func connectToFcm() {
        // Won't connect since there is no token
        //        guard InstanceID.instanceID().token() != nil else {
        //            return
        //        }
        
        // Disconnect previous FCM connection if it exists.
        //        Messaging.messaging().disconnect()
        
        // connect to FCM
        //        Messaging.messaging().connect { (error) in
        //            if (error != nil) {
        //                print("Unable to connect with FCM. \(error.debugDescription)")
        //            } else {
        //                print("Connected to FCM.")
        //            }
        //        }
        
    }
    // [END connect_to_fcm]
    
    
    // MARK: - Update Token
    func updateToken(token:String){
        var params = [String:String]()
        params["user_id"] = Common.instance.getUserId()
        params["gcm_token"] = token
        
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        
        APIRequestManager.request(apiRequest: APIRouters.UpdateUser(params,headers), success: { (responseData) in
            //..
        }, failure: { (message) in
        }, error: { (err) in
            print(err.localizedDescription)
        })
    }
    
    func updateLanguage(lang_nu:String, lang_text:String)
    {
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



// [START ios_10_message_handling]

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        //print("sssss",notification)
        
        // Print full message.
        debugPrint("%@", userInfo)
        
        
        
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        debugPrint("%@", userInfo)
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        //        print("Received data message: \(remoteMessage.appData)")
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //        print("Firebase registration token: \(fcmToken)")
    }
    
    func redirectToView(_ userInfo:[AnyHashable:Any]) {
        if let viewInfo: [String:Any] = userInfo as? [String : Any], let view: String = viewInfo["action"] as? String {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if view == "PENDING" {
                let vc  = mainStoryBoard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                vc.requestPage = RequestView.pending
                let nav = UINavigationController(rootViewController: vc)
                nav.setViewControllers([vc], animated:true)
                self.window?.rootViewController?.revealViewController().setFront(nav, animated: true)
                self.window?.rootViewController?.revealViewController().pushFrontViewController(nav, animated: true)
            } else if view == "ACCEPTED" {
                let vc  = mainStoryBoard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                vc.requestPage = RequestView.accepted
                let nav = UINavigationController(rootViewController: vc)
                nav.setViewControllers([vc], animated:true)
                self.window?.rootViewController?.revealViewController().setFront(nav, animated: true)
                self.window?.rootViewController?.revealViewController().pushFrontViewController(nav, animated: true)
            } else if view == "COMPLETED" {
                let vc  = mainStoryBoard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                vc.requestPage = RequestView.completed
                let nav = UINavigationController(rootViewController: vc)
                nav.setViewControllers([vc], animated:true)
                self.window?.rootViewController?.revealViewController().setFront(nav, animated: true)
                self.window?.rootViewController?.revealViewController().pushFrontViewController(nav, animated: true)
            } else if view == "CANCELLED" {
                let vc  = mainStoryBoard.instantiateViewController(withIdentifier: "RequestsViewController") as! RequestsViewController
                vc.requestPage = RequestView.cancelled
                let nav = UINavigationController(rootViewController: vc)
                nav.setViewControllers([vc], animated:true)
                self.window?.rootViewController?.revealViewController().setFront(nav, animated: true)
                self.window?.rootViewController?.revealViewController().pushFrontViewController(nav, animated: true)
            }
        }
    }
}
