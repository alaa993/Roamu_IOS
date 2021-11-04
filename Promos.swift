import UIKit

struct Promo: ResponseObjectSerializable, ResponseCollectionSerializable {
    
    var promo_code = ""
    var minimum_value = ""
    var promo_percentage = ""
    var promo_title = ""
    var promo_desc = ""
    var promo_policy = ""
    var promo_start_date = ""
    var promo_end_date = ""
    var banner_image = ""
    var status = ""
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let json = representation as? [String: String]
            else { return nil }
        
        promo_code = json["promo_code"] ?? ""
        minimum_value = json["minimum_value"] ?? ""
        promo_percentage = json["promo_percentage"] ?? ""
        promo_title = json["promo_title"] ?? ""
        promo_desc = json["promo_desc"] ?? ""
        promo_policy = json["promo_policy"] ?? ""
        promo_start_date = json["promo_start_date"] ?? ""
        promo_end_date = json["promo_end_date"] ?? ""
        banner_image = json["banner_image"] ?? ""
        status = json["status"] ?? ""
    }
    
    static func collection(response: HTTPURLResponse, representation: Any) -> [Promo] {
        let promos = representation as! [[String:String]]
        return promos.map({ Promo(response: response, representation: $0)! })
    }
}

struct Promos: ResponseObjectSerializable {
    var promos:[Promo]?
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
            self.promos = Promo.collection(response: response, representation: json)
            //self.travels = Travel.collection(response: response, representation: json)
        }
    }
}
