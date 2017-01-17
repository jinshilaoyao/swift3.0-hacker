//
//  Helper.swift
//  hacker
//
//  Created by yesway on 2017/1/13.
//  Copyright © 2017年 joker. All rights reserved.
//

import Foundation
import SafariServices

class Helper {
    
    class func addPostToReadingList(_ post: Post) -> Bool {
        let readingList = SSReadingList.default()
        var error: NSError?
        if let url: String = post.url?.absoluteString {
            do {
                try readingList!.addItem(with: URL(string: url)!, title: post.title, previewText: nil)
            } catch let error1 as NSError {
                error = error1
            }
            return error != nil
        }
        return false
    }
    
    
    class func showShareSheet(_ post: Post, controller: UIViewController, barbutton: UIBarButtonItem!) {
        let sheet = UIActivityViewController(activityItems: [NSString(string: post.title!), post.url!], applicationActivities: [OpenSafariActivity()])
        if sheet.popoverPresentationController != nil {
            sheet.modalPresentationStyle = UIModalPresentationStyle.popover
            sheet.popoverPresentationController?.sourceView = controller.view
            if let barbutton = barbutton {
                sheet.popoverPresentationController?.barButtonItem = barbutton
            }
        }
        controller.present(sheet, animated: true, completion: nil)
    }
    

}
