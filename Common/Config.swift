//
//  Config.swift
//  Taxi
//
//  Created by Bhavin
//  skype : bhavin.bhadani
//

struct configs{
    static let googleAPIKey      = "AIzaSyAspMldDJRyiM5hh5Iy3M2RfqXFZcd2aX0"
    static let googlePlaceAPIKey = "AIzaSyCa3yhDGMZM2xHCc5ieYeyz87SuHYDzozU"
    
    static let mapBox = "pk.eyJ1IjoiaWNhbnN0dWRpb3oiLCJhIjoiY2oyMXQ3dGRpMDAwdDJ3bXpmZHRkdTBtNyJ9.PxslIcrVRj_gVgiv-Y-jog"
    static let autoCompleteQuery = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    static let paypal_ClientId   = "AYi2W29-PSkOI0-utUCLVEuPL1qP8BjYCEOAz3OlnDomdc8yXl10QbGJVX3yc7QgZwM2AEgGn-3K-aoM"

    static let hostUrl      = "https://roamu.net/"
    static let hostUrlImage = "https://www.roamu.net/"
    static let registerUser = "user/register/format/json"
    static let loginUser    = "user/loginByMobile/format/json"//"user/login/format/json"
    static let forgotPaswrd = "user/forgot_password/format/json"
    static let changePaswrd = "api/user/change_password/format/json"
    static let updateUser   = "api/user/update/format/json"
    static let getProfile   = "api/user/profile/format/json"
    static let nearBy       = "api/user/nearby/format/json"
    static let addRide      = "api/user/addRide/format/json"
    static let addRide2     = "api/user/addRide2/format/json"
    static let addRating    = "api/user/addRating/format/json"
    static let updateRides  = "api/user/rides_ios/format/json"
    static let getRides     = "api/user/rides2/format/json"
    static let addTravel    = "api/user/addTravel2/format/json"
    static let GetTravels   = "api/user/travels/format/json"
    static let GetTravels2  = "api/user/travels2/format/json"
    static let travels3_get = "api/user/travels3/format/json"
    static let GetPromo     = "api/user/promo/format/json"
    static let getDriverInfo = "api/driver/getDriverInfo/format/json"
    static let updateToken = "user/updateToken/format/json"
    static let updateLanguage = "api/user/updateLang/format/json"
    static let getRating     = "api/user/rating/format/json"
    static let getSpecificRide     = "api/user/ride_specific/format/json"
    static let getGroupList = "api/driver/getGroupList/format/json"
    static let getAdminGroupInfo = "api/driver/getAdminGroupInfo/format/json"
    static let ChangeGruopName = "api/driver/editgroup/format/json"
    static let getMyGroupList = "api/driver/getMyGroupList/format/json"
    static let addGroup = "api/driver/addgroup/format/json"
    static let addUserToGroup = "api/driver/addUserToGroup/format/json"
    static let delUserFromGroup = "api/driver/delUserFromGroup/format/json"
    static let rides_notes = "api/user/rides_notes/format/json"
}

struct customFont{
    static let normal  = "Avenir-Book"
    static let medium  = "Avenir-Medium"
    static let bold    = "Avenir-Black"
}

protocol UIViewLoading {}
extension UIView : UIViewLoading {}

extension UIViewLoading where Self : UIView {
    
    // note that this method returns an instance of type `Self`, rather than UIView
    static func loadFromNib() -> Self {
        let nibName = "\(self)".split{$0 == "."}.map(String.init).last!
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! Self
    }
}
