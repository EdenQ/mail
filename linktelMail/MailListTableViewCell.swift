//
//  MailListTableViewCell.swift
//  Linktel Mail
//
//  Created by administrator on 2015/10/29.
//  Copyright © 2015年 administrator. All rights reserved.
//

import UIKit

class MailListTableViewCell: UITableViewCell {

    @IBOutlet weak var mailImage: UIImageView!
    
    @IBOutlet weak var mailSender: UILabel!
    
    @IBOutlet weak var mailSubject: UILabel!
    
    @IBOutlet weak var mailContent: UILabel!
    
    @IBOutlet weak var mailTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
