//
//  Menu.swift
//  linktelMail
//
//  Created by administrator on 2015/10/23.
//  Copyright © 2015年 administrator. All rights reserved.
//

import Foundation

class Menu {
    var name: String!
    var image: String!
    var identifier: String!
    
    init(name:String, image:String, identifier:String) {
        self.name = name
        self.image = image
        self.identifier = identifier
    }
}