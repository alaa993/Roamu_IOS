//
//  PickUpView.swift
//  Taxi
//
//  Created by Bhavin on 09/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

protocol PickUpViewDelegate {
    func currentLocationWasPressed()
    func dismissWasPressed()
    func pickupAction(sender: UIButton)
    func dropAction(sender: UIButton)
}

class PickUpView: UIView {
    //MARK:- IBOutlets
    @IBOutlet var currentLocationButton: UIButton!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var pickupButton: UIButton!
    @IBOutlet var dropButton: UIButton!
    
    // MARK:- Delegate
    var delegate:PickUpViewDelegate?
    
    // MARK:- Register Xib
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PickUpView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    }
    
    // MARK:- IBActions
    @IBAction private func currentLocationWasPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.currentLocationWasPressed()
        }
    }
    
    @IBAction private func dismissWasPressed(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.dismissWasPressed()
        }
    }
    @IBAction func pickupAction(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.pickupAction(sender: sender)
        }
    }
    
    @IBAction func dropAction(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.dropAction(sender: sender)
        }
    }
    
}
