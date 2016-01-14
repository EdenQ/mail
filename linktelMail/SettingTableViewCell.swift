//
//  SettingTableViewCell.swift
//  linktelMail
//
//  Created by administrator on 2015/10/23.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var settingImage: UIImageView!

    @IBOutlet weak var settingLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
