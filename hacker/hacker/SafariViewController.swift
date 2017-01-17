//
//  SafariViewController.swift
//  SwiftHN
//
//  Created by TETRA2000 on 12/23/15.
//  Copyright © 2015 Thomas Ricouard. All rights reserved.
//

import SafariServices

@available(iOS 9.0, *)
class SafariViewController: SFSafariViewController {
    fileprivate var previousBarStyle: UIStatusBarStyle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        overrideStatusBarStyle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        restoreStatusBarStyle()
    }
    
    fileprivate func overrideStatusBarStyle() {
        if previousBarStyle == nil {
            previousBarStyle = UIApplication.shared.statusBarStyle
        }
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    fileprivate func restoreStatusBarStyle() {
        if let previousBarStyle = previousBarStyle {
            UIApplication.shared.statusBarStyle = previousBarStyle
        }
    }
}
