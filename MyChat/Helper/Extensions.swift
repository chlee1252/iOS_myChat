//
//  Extensions.swift
//  MyChat
//
//  Created by Marc Lee on 10/11/19.
//  Copyright © 2019 Marc Lee. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        // check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        
        // Otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            // download hit an error so lets return out
            if error != nil {
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
        }).resume()
    }
}
