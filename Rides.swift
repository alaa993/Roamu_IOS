////
////  Rides.swift
////  Taxi
////
////  Created by Bhavin on 27/03/17.
////  Copyright © 2017 icanStudioz. All rights reserved.
////
//
//import UIKit
//
//struct Ride: ResponseObjectSerializable, ResponseCollectionSerializable {
//    var rideId = ""
//    var travel_id = ""
//    var userId = ""
//    var driverId = ""
//    var pickupAdress = ""
//    var dropAdress = ""
//    var pickLocation = ""
//    var dropLocation = ""
//    var distance = ""
//    var status = ""
//    var paymentMode = ""
//    var paymentStatus = ""
//    var amount = ""
//    var dateTime = ""
//    var userName = ""
//    var userMobile = ""
//    var userAvatar = ""
//    var driverName = ""
//    var driverMobile = ""
//    var driverAvatar = ""
//
//    init?(response: HTTPURLResponse, representation: Any) {
//        guard let json = representation as? [String: String]
//            else { return nil }
//
//        rideId = json["ride_id"] ?? ""
//        travel_id = json["travel_id"] ?? ""
//        userId  = json["user_id"] ?? ""
//        driverId = json["driver_id"] ?? ""
//        pickupAdress = json["pickup_address"] ?? ""
//        dropAdress = json["drop_address"] ?? ""
//        pickLocation = json["pickup_location"] ?? ""
//        dropLocation = json["drop_location"] ?? ""
//        distance = json["distance"] ?? ""
//        status = json["status"] ?? ""
//        paymentMode = json["payment_mode"] ?? ""
//        paymentStatus = json["payment_status"] ?? ""
//        dateTime = json["time"] ?? ""
//        amount = json["amount"] ?? ""
//        userName = json["user_name"] ?? ""
//        userMobile = json["user_mobile"] ?? ""
//        userAvatar = json["user_avatar"] ?? ""
//        driverName = json["driver_name"] ?? ""
//        driverMobile = json["driver_mobile"] ?? ""
//        driverAvatar = json["driver_avatar"] ?? ""
//    }
//
//    static func collection(response: HTTPURLResponse, representation: Any) -> [Ride] {
//        let rides = representation as! [[String:String]]
//        return rides.map({ Ride(response: response, representation: $0)! })
//    }
//}
//
//struct Rides: ResponseObjectSerializable {
//    var rides:[Ride]?
//    var status:Bool
//    var error:String?
//
//    init?(response: HTTPURLResponse, representation: Any) {
//        guard let representation = representation as? [String: Any]
//            else { return nil }
//
//        if let stat = representation["status"] as? String {
//            if stat == "success" {
//                self.status = true
//            } else {
//                self.status = false
//            }
//        } else {
//            self.status = false
//        }
//
//        if let err = representation["error"] as? String{
//            self.error = err
//        }
//
//        if let json = representation["data"] as? [[String:String]] {
//            self.rides = Ride.collection(response: response, representation: json)
//        }
//    }
//}
//
//
//
//



//
//  Rides.swift
//  Taxi
//
//  Created by Bhavin on 27/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

struct Ride: ResponseObjectSerializable, ResponseCollectionSerializable {
    var rideId = ""
    var travelId = ""
    var userId = ""
    var driverId = ""
    var pickupAdress = ""
    var dropAdress = ""
    var pickLocation = ""
    var dropLocation = ""
    var distance = ""
    var bookedSeat = ""
    var status = ""
    var Ridesmoked = ""
    var paymentStatus = ""
    var payDriver = ""
    var paymentMode = ""
    var amount = ""
    var date = ""
    var time = ""
    //var dateTime = ""
    var driverCity = ""
    var userName = ""
    var userMobile = ""
//    var userAvatar = ""
    var driverName = ""
    var driverMobile = ""
    var driverAvatar = ""
    var avalableSet = ""
    var emptySet = ""
    // new ride
    var pickup_point = ""
    var vehicle_no = ""
    var model = ""
    var color = ""
    var vehicle_info = ""
    var DriverRate = ""
    var FareRate = ""
    var Travels_Count = ""
    var Travel_Status = ""
    var car_type = ""
    var ride_notes = ""

    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? [String: String]
            else { return nil }

        rideId = json["ride_id"] ?? ""
        userId  = json["user_id"] ?? ""
        driverId = json["driver_id"] ?? ""
        travelId = json["travel_id"] ?? ""
        pickupAdress = json["pickup_address"] ?? ""
        dropAdress = json["drop_address"] ?? ""
        pickLocation = json["pickup_location"] ?? ""
        dropLocation = json["drop_location"] ?? ""
        distance = json["distance"] ?? ""
        status = json["status"] ?? ""
        paymentMode = json["payment_mode"] ?? ""
        paymentStatus = json["payment_status"] ?? ""
        amount = json["amount"] ?? ""
        date = json["date"] ?? ""
        time = json["time"] ?? ""
        userName = json["user_name"] ?? ""
        driverCity = json["driverCity"] ?? ""
        userMobile = json["user_mobile"] ?? ""
//        userAvatar = json["user_avatar"] ?? ""
        driverName = json["driver_name"] ?? ""
        driverMobile = json["driver_mobile"] ?? ""
        driverAvatar = json["driver_avatar"] ?? ""
        avalableSet = json["available_set"] ?? ""
        bookedSeat = json["booked_set"] ?? ""
        emptySet = json["empty_set"] ?? ""
        //new ride
        pickup_point = json["pickup_point"] ?? ""
        model = json["model"] ?? ""
        color = json["color"] ?? ""
        vehicle_info = json["vehicle_info"] ?? ""
        DriverRate = json["DriverRate"] ?? ""
        FareRate = json["FareRate"] ?? ""
        Travels_Count = json["Travels_Count"] ?? ""
        vehicle_no = json["vehicle_no"] ?? ""
        Travel_Status = json["travel_status"] ?? ""
        car_type = json["car_type"] ?? ""
        ride_notes = json["ride_notes"] ?? ""
        //rides2
    }

    static func collection(response: HTTPURLResponse, representation: Any) -> [Ride] {
        let rides = representation as! [[String:String]]
        return rides.map({ Ride(response: response, representation: $0)! })
    }
}

struct Rides: ResponseObjectSerializable {
    var rides:[Ride]?
    var status:Bool
    var error:String?

    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any]
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

        if let json = representation["data"] as? [[String:String]] {
            self.rides = Ride.collection(response: response, representation: json)
        }
    }
}
