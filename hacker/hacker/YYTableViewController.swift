//
//  YYTableViewController.swift
//  hacker
//
//  Created by yesway on 2017/1/13.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

class YYTableViewController: UITableViewController {

    var refreshing: Bool = false {
        didSet {
            if self.refreshing {
                self.refreshControl?.beginRefreshing()
                self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading...")
            } else {
                self.refreshControl?.endRefreshing()
                self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            }
        }
    }
    
    open var datasource: Array<AnyObject>! {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    open var ids: [Int]! {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(YYTableViewController.onPullToFresh), for: UIControlEvents.valueChanged)
        
    }
    
    func onPullToFresh() {
        
    }
}
