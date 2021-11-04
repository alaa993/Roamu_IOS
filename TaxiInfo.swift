//
//  TexiInfo.swift
//  Taxi
//
//  Created by Bhavin on 08/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

protocol TaxiInfoDelegate {
    func requestRideClicked()
}

class TaxiInfo: UIView {
    //MARK:- IBOutlets
    @IBOutlet var driverName: UILabel!
    @IBOutlet var from: UILabel!
    @IBOutlet var to: UILabel!
//    @IBOutlet var currentLocation: UILabel!
    var markerData:Travel?
    
    // MARK:- Delegate
    var delegate:TaxiInfoDelegate?
    
    // MARK:- IBActions
    @IBAction func requestRideClicked(_ sender: Any) {
        if let delegate = delegate {
            delegate.requestRideClicked()
        }
    }
    
    // MARK:- Register Xib
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "TaxiInfo", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    }
    
}
