//
//  User.swift
//  MyChat
//
//  Created by Marc Lee on 10/9/19.
//  Copyright © 2019 Marc Lee. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var name: String?
    var imageURL: String?
    var id: String?
    
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as! String?
        self.email = dictionary["email"] as! String?
        self.imageURL = dictionary["profileImageUrl"] as! String?
    }
}
