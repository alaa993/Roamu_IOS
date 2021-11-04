//
//  RequestsCell.swift
//  Taxi
//
//  Created by Bhavin on 07/03/17.
//  Copyright © 2017 icanStudioz. All rights reserved.
//

import UIKit

class RequestsCell: UITableViewCell {
    
    @IBOutlet var mainLayer: UIView!
    @IBOutlet var streetFrom: UILabel!
    @IBOutlet var streetTo: UILabel!
    @IBOutlet var detailAdrsFrom: UILabel!
    @IBOutlet var detailAdrsTo: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var ReqTypeVal: UILabel!
    @IBOutlet var CarType: UILabel!
    
    
    @IBOutlet var Fromlbl: UILabel!
    @IBOutlet var Tolbl: UILabel!
    @IBOutlet var Datelbl: UILabel!
    @IBOutlet var DriverNamelbl: UILabel!
    @IBOutlet var ReqTypelbl: UILabel!
    @IBOutlet var CarTypelbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
