//
//  NotificationsViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 11/21/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire


class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    var notifications = [Notification]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching:CGFloat = 3.0
    
    var refreshControl:UIRefreshControl!
    
    var seeNewPostsButton:SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor:NSLayoutConstraint!
    
    var lastUploadedPostID:String?
    
    var postsRef:DatabaseReference {
        return Database.database().reference().child("Notifications").child(Common.instance.getUserId())
    }
    
    var oldPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let lastPost = notifications.last
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    var newPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let firstPost = notifications.first
        if firstPost != nil {
            let firstTimestamp = firstPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    var rides = [Ride]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "MenuItem16", comment: "")
        
        // -- setup revealview (side menu) --
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
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        let cellNib = UINib(nibName: "NotificationTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.backgroundColor = UIColor(white: 0.90,alpha:1.0)
        view.addSubview(tableView)
        var layoutGuide:UILayoutGuide!
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        
        seeNewPostsButton = SeeNewPostsButton()
        view.addSubview(seeNewPostsButton)
        seeNewPostsButton.translatesAutoresizingMaskIntoConstraints = false
        seeNewPostsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        seeNewPostsButtonTopAnchor = seeNewPostsButton.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: -44)
        seeNewPostsButtonTopAnchor.isActive = true
        seeNewPostsButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        seeNewPostsButton.widthAnchor.constraint(equalToConstant: seeNewPostsButton.button.bounds.width).isActive = true
        
        seeNewPostsButton.button.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        
        //observePosts()
        beginBatchFetch()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        listenForNewPosts()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //        stopListeningForNewPosts()
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
    
    @objc func handleRefresh() {
        print("Refresh!")
        
        toggleSeeNewPostsButton(hidden: true)
        
        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Notification]()
            print(snapshot)
            let firstPost = self.notifications.first
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let notification = Notification.parse(childSnapshot.key, data),
                    //                    post.privacy == "1",
                    childSnapshot.key != firstPost?.id {
                    
                    tempPosts.insert(notification, at: 0)
                }
            }
            
            self.notifications.insert(contentsOf: tempPosts, at: 0)
            
            let newIndexPaths = (0..<tempPosts.count).map { i in
                return IndexPath(row: i, section: 0)
            }
            
            self.refreshControl.endRefreshing()
            self.tableView.insertRows(at: newIndexPaths, with: .top)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.listenForNewPosts()
            
        })
    }
    
    func fetchPosts(completion:@escaping (_ notification:[Notification])->()) {
        
        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Notification]()
            print(snapshot)
            let lastPost = self.notifications.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let notification = Notification.parse(childSnapshot.key, data),
                    //                    post.privacy == "1",
                    childSnapshot.key != lastPost?.id {
                    
                    tempPosts.insert(notification, at: 0)
                }
            }
            
            return completion(tempPosts)
        })
    }
    
    @IBAction func handleLogout(_ sender:Any) {
        try! Auth.auth().signOut()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return notifications.count
        case 1:
            return fetchingMore ? 1 : 0
        default:
            return 0
        }
    }
    
    @available(iOS 10.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! NotificationTableViewCell
            
            let userRef = Database.database().reference().child("users/profile/\(self.notifications[indexPath.row].uid)")
            
            userRef.observe(.value, with: { snapshot in
                if let dict = snapshot.value as? [String:Any],
                    let username_ = dict["username"] as? String,
                    let photoURL_ = dict["photoURL"] as? String,
                    let url_ = URL(string:photoURL_) {
                    print("ibrahim was here")
                    print(photoURL_)
                    cell.set(notification: self.notifications[indexPath.row], username: username_, url_: url_)
                }
            })
            // return to by ibrahim for username
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 72.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let x = self.notifications[indexPath.row].ride_id
        loadSpecificRide(ride_id: self.notifications[indexPath.row].ride_id, notification_id: self.notifications[indexPath.row].id)
    }
    
    func updateNotificationFirebase(with status:String, ride_id:String, user_id:String, notification_id:String) {
        let postRef = Database.database().reference().child("Notifications").child(user_id).child(notification_id)
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
    
    func loadSpecificRide(ride_id: String, notification_id:String){
        let params = ["ride_id": ride_id]
        let headers = ["X-API-KEY":Common.instance.getAPIKey()]
        //        HUD.show(to: view)
        _ = Alamofire.request(APIRouters.getSpecificRide(params,headers)).responseObject { (response: DataResponse<Rides>) in
            //            HUD.hide(to: self.view)
            if response.result.isSuccess{
                if response.result.value?.status == true , ((response.result.value?.rides) != nil) {
                    self.rides = (response.result.value?.rides)!
                    if #available(iOS 11.0, *) {
                        self.updateNotificationFirebase(with:"WAITED", ride_id:self.rides[0].rideId, user_id:self.rides[0].userId, notification_id: notification_id)
                        var requestPage:RequestView?
                        if self.rides[0].status == "WAITED"
                        {
                            let vcConfirm = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmRideVC") as! ConfirmRideVC
                            vcConfirm.confirmRequestPage = confirmRequestView.waited
                            vcConfirm.rideData = ["pickup": self.rides[0].pickupAdress,
                                                  "drop": self.rides[0].dropAdress,
                                                  "pickupLocation": self.rides[0].pickLocation,
                                                  "dropLocation": self.rides[0].dropLocation,
                                                  "driverName": self.rides[0].driverName,
                                                  "driverCity": self.rides[0].driverCity,
                                                  "driverVehicle": self.rides[0].vehicle_no,
                                                  "mobileNum":self.rides[0].driverMobile,
                                                  "vehicle":self.rides[0].vehicle_no,
                                                  "smoked":self.rides[0].Ridesmoked,
                                                  "passengers":self.rides[0].avalableSet,
                                                  "empty_set":self.rides[0].emptySet as? String ?? "0",
                                                  "driver_id": self.rides[0].driverId,
                                                  "travel_id": self.rides[0].travelId,
                                                  "ride_id" : self.rides[0].rideId,
                                                  "amount" : self.rides[0].amount,
                                                  "time" : self.rides[0].time,
                                                  "date" : self.rides[0].date,
                                                  "model" : self.rides[0].model,
                                                  "color" : self.rides[0].color,
                                                  "vehicle_no" : self.rides[0].vehicle_no,
                                                  "pickup_point" : self.rides[0].pickup_point,
                                                  "DriverRate" : self.rides[0].DriverRate,
                                                  "FareRate" : self.rides[0].FareRate,
                                                  "Travels_Count" : self.rides[0].Travels_Count,
                                                  "booked_set": self.rides[0].bookedSeat]
                            
                            vcConfirm.DriverAvatarURL = self.rides[0].driverAvatar
                            vcConfirm.DriverCarURL = self.rides[0].vehicle_info
                            self.navigationController?.pushViewController(vcConfirm, animated: true)
                        }
                        else
                        {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailReqViewController") as! DetailReqViewController
                            if self.rides[0].status == "PENDING"
                            {
                                requestPage = RequestView.pending
                            }
                            if self.rides[0].status == "ACCEPTED"
                            {
                                requestPage = RequestView.accepted
                            }
                            if self.rides[0].status == "COMPLETED"
                            {
                                requestPage = RequestView.completed
                            }
                            if self.rides[0].status == "CANCELLED"
                            {
                                requestPage = RequestView.cancelled
                            }
                            vc.requestPage = requestPage
                            vc.rideDetail = self.rides[0]
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        
        fetchPosts { newPosts in
            self.notifications.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                
                self.listenForNewPosts()
            }
        }
    }
    
    var postListenerHandle:UInt?
    
    func listenForNewPosts() {
        
        guard !fetchingMore else { return }
        
        // Avoiding duplicate listeners
        stopListeningForNewPosts()
        
        postListenerHandle = newPostsQuery.observe(.childAdded, with: { snapshot in
            
            print(snapshot)
            if snapshot.key != self.notifications.first?.id,
                let data = snapshot.value as? [String:Any],
                let notification = Notification.parse(snapshot.key, data) {
                //self.stopListeningForNewPosts()
                if snapshot.key == self.lastUploadedPostID {
                    self.handleRefresh()
                    self.lastUploadedPostID = nil
                } else {
                    self.toggleSeeNewPostsButton(hidden: false)
                }
            }
        })
    }
    
    func stopListeningForNewPosts() {
        if let handle = postListenerHandle {
            newPostsQuery.removeObserver(withHandle: handle)
            postListenerHandle = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPostNavBar = segue.destination as? UINavigationController,
            let newPostVC = newPostNavBar.viewControllers[0] as? NewPostViewController {
            
            newPostVC.delegate = self
        }
    }
}

extension NotificationsViewController: NewPostVCDelegate {
    func didUploadPost(withID id: String) {
        self.lastUploadedPostID = id
    }
}
