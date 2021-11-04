//
//  APIRouters.swift
//  Created by Bhavin
//  skype : bhavin.bhadani
//

import Alamofire

enum APIRouters: URLRequestConvertible {
    static let baseURLString  = configs.hostUrl
    
    static let registerUser   = configs.registerUser
    static let loginUser      = configs.loginUser
    static let forgotPaswrd   = configs.forgotPaswrd
    static let changePaswrd   = configs.changePaswrd
    static let updateUser     = configs.updateUser
    static let getProfile     = configs.getProfile
    static let nearBy         = configs.nearBy
    static let addRide        = configs.addRide
    static let addRide2       = configs.addRide2
    static let addRating      = configs.addRating
    static let getRides       = configs.getRides
    static let updateRides    = configs.updateRides
    static let addTravel      = configs.addTravel
    static let GetTravels     = configs.GetTravels
    static let GetTravels2    = configs.GetTravels2
    static let travels3_get   = configs.travels3_get
    static let GetPromo       = configs.GetPromo
    static let getDriverInfo  = configs.getDriverInfo
    static let updateToken    = configs.updateToken
    static let updateLanguage    = configs.updateLanguage
    static let getRating    = configs.getRating
    static let getSpecificRide    = configs.getSpecificRide
    
    static let getGroupList = configs.getGroupList
    static let getMyGroupList = configs.getMyGroupList
    static let getAdminGroupInfo = configs.getAdminGroupInfo
    static let ChangeGruopName = configs.ChangeGruopName
    static let addGroup = configs.addGroup
    static let addUserToGroup = configs.addUserToGroup
    static let delUserFromGroup = configs.delUserFromGroup
    static let rides_notes = configs.rides_notes
    
    
    
    
    case RegisterUser([String:Any])
    case LoginUser([String:Any])
    case ForgotPassword([String:String])
    case ChangePassword([String:String],[String:String])
    case UpdateUser([String:String],[String:String])
    case GetProfile([String:String],[String:String])
    case NearBy([String:Double],[String:String])
    case AddRide([String:Any],[String:String])
    case AddRide2([String:Any],[String:String])
    case addRating([String:Any],[String:String])
    case GetRides([String:Any],[String:String])
    case UpdateRides([String:Any],[String:String])
    case AddTravel([String:Any],[String:String])
    case GetTravels([String:Any],[String:String])
    case GetTravels2([String:Any],[String:String])
    case travels3_get([String:Any],[String:String])
    case GetPromo([String:Any],[String:String])
    case getDriverInfo([String:Any],[String:String])
    case UpdateToken([String:String],[String:String])
    case UpdateLanguage([String:String],[String:String])
    case getRating([String:String],[String:String])
    case getSpecificRide([String:String],[String:String])
    
    case getGroupList([String:Any],[String:String])
    case getMyGroupList([String:Any],[String:String])
    case getAdminGroupInfo([String:Any],[String:String])
    case ChangeGruopName([String:Any],[String:String])
    case addGroup([String:Any],[String:String])
    case addUserToGroup([String:Any],[String:String])
    case delUserFromGroup([String:Any],[String:String])
    case rides_notes([String:Any],[String:String])
    
    public func asURLRequest() throws -> URLRequest {
        
        let (path, parameters, method, headers) : (String, [String: Any]?, HTTPMethod, HTTPHeaders?) = {
            switch self {
            case .RegisterUser(let params):
                return (APIRouters.registerUser, params, .post, nil)
                
            case .LoginUser(let params):
                return (APIRouters.loginUser, params, .post, nil)
                
            case .ForgotPassword(let params):
                return (APIRouters.forgotPaswrd, params, .post, nil)
                
            case .ChangePassword(let params, let headers):
                return (APIRouters.changePaswrd, params, .post, headers)
                
            case .UpdateUser(let params, let headers):
                return (APIRouters.updateUser, params, .post, headers)
                
            case .GetProfile(let params, let headers):
                return (APIRouters.getProfile, params, .get, headers)
                
            case .NearBy(let params, let headers):
                return (APIRouters.nearBy, params, .get, headers)
                
            case .AddRide(let params, let headers):
                return (APIRouters.addRide, params, .post, headers)
                
            case .AddRide2(let params, let headers):
                return (APIRouters.addRide2, params, .post, headers)
                
            case .addRating(let params, let headers):
                return (APIRouters.addRating, params, .post, headers)
                
            case .GetRides(let params, let headers):
                return (APIRouters.getRides, params, .get, headers)
                
            case .UpdateRides(let params, let headers):
                return (APIRouters.updateRides, params, .post, headers)
                
            case .AddTravel(let params, let headers):
                return (APIRouters.addTravel, params, .post, headers)
                
            case .GetTravels(let params, let headers):
                return (APIRouters.GetTravels, params, .get, headers)
            //temporary for optional conditions in where statement
            case .GetTravels2(let params, let headers):
                return (APIRouters.GetTravels2, params, .get, headers)
            case .travels3_get(let params, let headers):
                return (APIRouters.travels3_get, params, .get, headers)
                
            case .GetPromo(let params, let headers):
                return (APIRouters.GetPromo, params, .get, headers)
                
            case .getDriverInfo(let params, let headers):
                return (APIRouters.getDriverInfo, params, .get, headers)
                
            case .UpdateToken(let params, let headers):
                return (APIRouters.updateToken, params, .post, headers)
                
            case .UpdateLanguage(let params, let headers):
                return (APIRouters.updateLanguage, params, .post, headers)
                
            case .getRating(let params, let headers):
                return (APIRouters.getRating, params, .get, headers)
                
            case .getSpecificRide(let params, let headers):
                return (APIRouters.getSpecificRide, params, .get, headers)
                
            case .getGroupList(let params, let headers):
                return (APIRouters.getGroupList, params, .get, headers)
                
            case .getAdminGroupInfo(let params, let headers):
                return (APIRouters.getAdminGroupInfo, params, .get, headers)
                
            case .ChangeGruopName(let params, let headers):
                return (APIRouters.ChangeGruopName, params, .post, headers)
                
            case .getMyGroupList(let params, let headers):
                return (APIRouters.getMyGroupList, params, .get, headers)
                
            case .addGroup(let params, let headers):
                return (APIRouters.addGroup, params, .post, headers)
                
            case .addUserToGroup(let params, let headers):
                return (APIRouters.addUserToGroup, params, .post, headers)
                
            case .delUserFromGroup(let params, let headers):
                return (APIRouters.delUserFromGroup, params, .post, headers)
                
                case .rides_notes(let params, let headers):
                return (APIRouters.rides_notes, params, .get, headers)
                
            }
            
        }()
        
        let url = try APIRouters.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        if let headers = headers {
            for (headerField, headerValue) in headers {
                urlRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        return try URLEncoding.default.encode(urlRequest, with: parameters)
    }
    
    
}
