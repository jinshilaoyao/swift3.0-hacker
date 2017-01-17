//
//  OpenSafariActivity.swift
//  hacker
//
//  Created by yesway on 2017/1/13.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit
class OpenSafariActivity: UIActivity {
    
//    override var activityType : String {
//        return "Open in Safari"
//    }
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "Open in Safari")
    }
    
    override var activityTitle : String  {
        return "Open in Safari"
    }
    
    override var activityImage : UIImage {
        return UIImage(named: "Safari")!
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        let urlToOpen = activityItems[1] as! URL
        UIApplication.shared.openURL(urlToOpen)
    }
}
