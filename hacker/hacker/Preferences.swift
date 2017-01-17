//
//  Preferences.swift
//  hacker
//
//  Created by yesway on 2017/1/13.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation
import UIKit

let _preferencesSharedInstance = Preferences()

class Preferences {
    
    let pUserDefault = UserDefaults.standard
    let pFirstTimeLaunchString = "isFirstTimeLaunch"
    let pReadLater = "readLater"
    
    
    var firstTimeLaunch: Bool {
        get {
            return self.pUserDefault.bool(forKey: pFirstTimeLaunchString)
        }
        
        set {
            self.pUserDefault.set(newValue, forKey: pFirstTimeLaunchString)
        }
    }
    
    func addToReadLater(_ post: Post) {
        var array: [AnyObject]! = self.pUserDefault.array(forKey: pReadLater) as [AnyObject]!
        if (array == nil) {
            array = []
        }
        array.append(post.postId! as AnyObject)
        self.pUserDefault.set(array, forKey: pReadLater)
    }
    
    func isInReadingList(_ uid: String) -> Bool {
        let array: [AnyObject]! = self.pUserDefault.array(forKey: pReadLater) as [AnyObject]!
        if (array == nil) {
            return false
        }
        return (array as! [String]).contains(uid)
    }
    
    class var sharedInstance: Preferences {
        return _preferencesSharedInstance
    }
    
}
