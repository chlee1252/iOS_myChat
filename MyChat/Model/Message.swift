//
//  Message.swift
//  MyChat
//
//  Created by Jieun Park on 10/12/19.
//  Copyright © 2019 Marc Lee. All rights reserved.
//

import UIKit

class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    init(dictionary: [String: AnyObject]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.toId = dictionary["toId"] as? String
    }
    
}
