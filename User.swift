//
//  User.swift
//  Taxi
//
//  Created by Bhavin on 17/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    var userId: String?
    var name: String?
    var email: String?
    var avatar: String?
    var mobile: String?
    var country: String?
    var state: String?
    var city: String?
    var lat: String?
    var long: String?
    var socialStatus: String?
    
    init(userData:[String:Any]) {
        super.init()
        setData(json: userData as! [String : String])
    }
    
    required init(coder decoder: NSCoder) {
        self.userId = decoder.decodeObject(forKey: "user_id") as? String ?? ""
        self.name   = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.email  = decoder.decodeObject(forKey: "email") as? String ?? ""
        self.avatar = decoder.decodeObject(forKey: "avatar") as? String ?? ""
        self.mobile = decoder.decodeObject(forKey: "mobile") as? String ?? ""
        self.country = decoder.decodeObject(forKey: "country") as? String ?? ""
        self.state  = decoder.decodeObject(forKey: "state") as? String ?? ""
        self.city   = decoder.decodeObject(forKey: "city") as? String ?? ""
        self.lat    = decoder.decodeObject(forKey: "latitude") as? String ?? ""
        self.long   = decoder.decodeObject(forKey: "longitude") as? String ?? ""
        self.socialStatus = decoder.decodeObject(forKey: "socialStatus") as? String ?? ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(userId, forKey: "user_id")
        coder.encode(name, forKey: "name")
        coder.encode(email, forKey: "email")
        coder.encode(avatar, forKey: "avatar")
        coder.encode(mobile, forKey: "mobile")
        coder.encode(country, forKey: "country")
        coder.encode(state, forKey: "state")
        coder.encode(city, forKey: "city")
        coder.encode(lat, forKey: "latitude")
        coder.encode(long, forKey: "longitude")
        coder.encode(socialStatus, forKey: "socialStatus")
    }
    
    func setData(json:[String:String]){
        userId  = json["user_id"] ?? ""
        name    = json["name"] ?? ""
        email   = json["email"] ?? ""
        avatar  = json["avatar"] ?? ""
        mobile  = json["mobile"] ?? ""
        country = json["country"] ?? ""
        state   = json["state"] ?? ""
        city    = json["city"] ?? ""
        lat     = json["latitude"] ?? ""
        long    = json["longitude"] ?? ""
        socialStatus = json["socialStatus"] ?? ""
    }
}
