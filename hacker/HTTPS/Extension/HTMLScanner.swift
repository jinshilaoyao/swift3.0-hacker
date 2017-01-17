//
//  HTMLScanner.swift
//  hacker
//
//  Created by yesway on 2017/1/12.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation

extension Scanner {
    func scanTag(startTag: String, endTag: String) -> String {
        var temp: NSString? = ""
        var result: NSString? = ""
        self.scanUpTo(startTag, into: &temp)
        self.scanString(startTag, into: &temp)
        self.scanUpTo(endTag, into: &result)
        return result as! String
    }
}
