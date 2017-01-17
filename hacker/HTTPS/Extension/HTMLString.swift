//
//  HTMLString.swift
//  hacker
//
//  Created by yesway on 2017/1/12.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation

extension String {
    static func stringByRemovingHTMLEntities(string: String) -> String {
        var result = string
        
        result = result.replacingOccurrences(of: "<P>", with: "\n\n", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "<p>", with:  "\n\n", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "</p>", with:  "", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "<i>", with:  "", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "</i>", with:  "", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#38;", with:  "&", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#62;", with:  ">", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#x27;", with:  "'", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#x2F;", with:  "/", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&quot;", with:  "\"", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&#60;", with:  "<", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&lt;", with:  "<", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&gt;", with:  ">", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "&amp;", with:  "&", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "<pre><code>", with:  "", options: String.CompareOptions.caseInsensitive, range: nil)
        result = result.replacingOccurrences(of: "</code></pre>", with:  "", options: String.CompareOptions.caseInsensitive, range: nil)
        
        let regex = try? NSRegularExpression(pattern: "<a[^>]+href=\"(.*?)\"[^>]*>.*?</a>",
                                             options: NSRegularExpression.Options.caseInsensitive)
        result = regex!.stringByReplacingMatches(in: result, options: [], range: NSMakeRange(0, result.utf16.count), withTemplate: "$1")
        
        return result
    }
}
