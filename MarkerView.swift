//
//  MarkerView.swift
//  Taxi
//
//  Created by Bhavin on 09/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    @IBOutlet var titleText: UILabel!
    @IBOutlet var descriptionText: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! UIView
    }
}
