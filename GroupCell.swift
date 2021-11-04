//
//  GroupCell.swift
//  Taxi
//
//  Created by ibrahim.marie on 8/11/21.
//  Copyright © 2021 icanStudioz. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    @IBOutlet var DriverNamelbl: UILabel!
    @IBOutlet var DriveMobilelbl: UILabel!
    @IBOutlet var DriverMaillbl: UILabel!
    @IBOutlet var DriverStatuslbl: UILabel!
    
    @IBOutlet var DriverNameVar: UILabel!
    @IBOutlet var DriveMobileVar: UILabel!
    @IBOutlet var DriverMailVar: UILabel!
    @IBOutlet var DriverStatusVar: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
