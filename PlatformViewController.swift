//
//  PlatformViewController.swift
//  Taxi
//
//  Created by ibrahim.marie on 6/13/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PlatformViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    var posts = [Post]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching:CGFloat = 3.0
    
    var refreshControl:UIRefreshControl!
    
    var seeNewPostsButton:SeeNewPostsButton!
    var seeNewPostsButtonTopAnchor:NSLayoutConstraint!
    
    var lastUploadedPostID:String?
    
    var postsRef:DatabaseReference {
        return Database.database().reference().child("posts")
    }
    
    var oldPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let lastPost = posts.last
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
        let firstPost = posts.first
        if firstPost != nil {
            let firstTimestamp = firstPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "PlatformVC_Title", comment: "")
        if let revealController = self.revealViewController() {
            revealController.panGestureRecognizer()
            let menuButton = UIBarButtonItem(image: UIImage(named: "menu"),
                                             style: .plain, target: revealController,
                                             action: #selector(SWRevealViewController.revealToggle(_:)))
            self.navigationItem.leftBarButtonItem = menuButton
            
        }
        
        if LocalizationSystem.sharedInstance.getLanguage() == "ar" {
            //self.storyboard
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
        
        let cellNib = UINib(nibName: "PostTableViewCell", bundle: nil)
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
            var tempPosts = [Post]()
            print(snapshot)
            let firstPost = self.posts.first
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data),
                    //                    post.privacy == "1",
                    childSnapshot.key != firstPost?.id {
                    
                    tempPosts.insert(post, at: 0)
                }
            }
            
            self.posts.insert(contentsOf: tempPosts, at: 0)
            
            let newIndexPaths = (0..<tempPosts.count).map { i in
                return IndexPath(row: i, section: 0)
            }
            
            self.refreshControl.endRefreshing()
            self.tableView.insertRows(at: newIndexPaths, with: .top)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.listenForNewPosts()
            
        })
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()) {
        
        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            print(snapshot)
            let lastPost = self.posts.last
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data),
                    //                    post.privacy == "1",
                    childSnapshot.key != lastPost?.id {
                    
                    tempPosts.insert(post, at: 0)
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
            return posts.count
        case 1:
            return fetchingMore ? 1 : 0
        default:
            return 0
        }
    }
    
    @available(iOS 10.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
            cell.edit_post.isHidden = true
            cell.commentsLabel.isHidden = false
            var count = 0
            if #available(iOS 11.0, *) {
                let userRef = Database.database().reference().child("posts").child(posts[indexPath.row].id).child("Comments")
                userRef.observe(.value, with: { snapshot in
                    count = Int(snapshot.childrenCount)
                    //type = 0 => driver
                    //type = 1 => user
                    if (self.posts[indexPath.row].type == "0" && self.posts[indexPath.row].travel_id > 0)
                    {
                        cell.AboutButton.isHidden = false
//                        cell.edit_post.isHidden = true
                        
                    }
                    else{
                        cell.AboutButton.isHidden = true
//                        cell.edit_post.isHidden = false
                    }
                    if (self.posts[indexPath.row].author.uid == Auth.auth().currentUser?.uid){
//                        cell.edit_post.isHidden = false
                    }else{
//                    cell.edit_post.isHidden = true
                    }
                    
                    cell.set(post: self.posts[indexPath.row],post_id: self.posts[indexPath.row].id, CommentsNo: count, subStoryboard:self.storyboard!, subNavigationVC: self.navigationController!)
                    
                    if(self.posts[indexPath.row].type == "0"){
                        
                        cell.iii.backgroundColor = UIColor.init(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
                        cell.postTextView.font = UIFont.init(name: "Times New Roman", size: 20)
                        cell.postTextView.isEditable = false
                        cell.postTextView.isUserInteractionEnabled = false
                        cell.postTextView.backgroundColor = UIColor.init(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0)
                    }
                    else if(self.posts[indexPath.row].type == "1"){
                        cell.iii.backgroundColor = UIColor.white
                    }
                })
            } else {
                // Fallback on earlier versions
            }
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
        // -- push to detail view with required data --
        //        print("row was clicked")
        //        print(indexPath.row)
        
        if #available(iOS 11.0, *) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailsViewController") as! PostDetailsViewController
            vc.post.append(posts[indexPath.row])
            
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            // Fallback on earlier versions
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
            self.posts.append(contentsOf: newPosts)
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
            if snapshot.key != self.posts.first?.id,
                let data = snapshot.value as? [String:Any],
                let post = Post.parse(snapshot.key, data) {
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
extension PlatformViewController: NewPostVCDelegate {
    func didUploadPost(withID id: String) {
        self.lastUploadedPostID = id
    }
}
