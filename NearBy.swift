//
//  NearBy.swift
//  Taxi
//
//  Created by Bhavin on 18/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

struct Near: ResponseObjectSerializable {
    var fare:Fare?
    var nearByData:[NearBy]?
    var status:Bool
    var error:String?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any]
            else { return nil }
        
        if let stat = representation["status"] as? String {
            if stat == "success" {
                self.status = true
            } else {
                self.status = false
            }
        } else {
            self.status = false
        }
        
        if let err = representation["error"] as? String{
            self.error = err
        }
        
        if let json = representation["data"] as? [[String:String]],
            let fareData = representation["fair"] as? [String:String] {
            self.fare = Fare(json: fareData)
            self.nearByData = NearBy.collection(response: response, representation: json)
        }
    }
}

struct NearBy: ResponseObjectSerializable, ResponseCollectionSerializable {
    var userId = ""
    var name = ""
    var email = ""
    var vehicle = ""
    var distance = ""
    var lat = ""
    var long = ""
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? [String: String]
            else { return nil }
        
        userId  = json["user_id"] ?? ""
        name    = json["name"] ?? ""
        email   = json["email"] ?? ""
        vehicle = json["vehicle_info"] ?? ""
        distance = json["distance"] ?? ""
        lat     = json["latitude"] ?? ""
        long    = json["longitude"] ?? ""
    }
    
    static func collection(response: HTTPURLResponse, representation: Any) -> [NearBy] {
        let nearArray = representation as! [[String:String]]
        return nearArray.map({ NearBy(response: response, representation: $0)! })
    }
}


struct Fare {
    var cost = ""
    var unit = ""
    
    init(json:[String:String]) {
        cost  = json["cost"] ?? ""
        unit  = json["unit"] ?? ""
    }
}

