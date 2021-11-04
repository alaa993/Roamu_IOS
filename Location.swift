//
//  Location.swift
//  Taxi
//
//  Created by ibrahim.marie on 3/29/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import Foundation
class Location {
    
    var id:String
    var latitude:Double
    var longitude:Double
    
    init(id:String, latitude:Double, longitude:Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func parse(_ key:String, _ data:[String:Any]) -> Location? {
        
        if let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double{
            return Location(id: key, latitude:latitude, longitude:longitude)
        }
        return nil
    }
}
