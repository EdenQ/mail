//
//  MenuTableViewCell.swift
//  linktelMail
//
//  Created by administrator on 2015/10/20.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    
    @IBOutlet weak var menuImage: UIImageView!
    
    @IBOutlet weak var menuLable: UILabel!
    
    @IBOutlet weak var menuNum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
