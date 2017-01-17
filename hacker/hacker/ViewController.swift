//
//  ViewController.swift
//  hacker
//
//  Created by yesway on 2017/1/10.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

class ViewController: YYTableViewController {

    var fileter: Post.PostFilter = .Top
    var loadMoreEnable = false
    var infiniteScrollingView: UIView?
    
    // MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News"
        
        setupInfiniteScrollingView()
        setupNavigationItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        
        onPullToFresh()
        showFirstTimeEditingCellAlert()
    }
    
    // MARK: - setUp
    
    fileprivate func setupInfiniteScrollingView() {
        self.infiniteScrollingView = UIView(frame: CGRect(x: 0, y: self.tableView.contentSize.height, width: self.tableView.bounds.size.width, height: 60))
        self.infiniteScrollingView!.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.infiniteScrollingView!.backgroundColor = UIColor.LoadMoreLightGrayColor()
        let activityViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityViewIndicator.color = UIColor.darkGray
        activityViewIndicator.frame = CGRect(x: self.infiniteScrollingView!.frame.size.width/2-activityViewIndicator.frame.width/2, y: self.infiniteScrollingView!.frame.size.height/2-activityViewIndicator.frame.height/2, width: activityViewIndicator.frame.width, height: activityViewIndicator.frame.height)
        activityViewIndicator.startAnimating()
        self.infiniteScrollingView!.addSubview(activityViewIndicator)
    }
    
    fileprivate func setupNavigationItems() {
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.organize, target: self, action: #selector(ViewController.onRightButton))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    // MARK: - Tools
    
    func onRightButton() {
//        let navCategories = self.storyboard?.instantiateViewController(withIdentifier: "categoriesNavigationController") as! UINavigationController
//        let categoriesVC = navCategories.visibleViewController as! CategoriesViewController
//        categoriesVC.delegate = self
//        navCategories.modalPresentationStyle = UIModalPresentationStyle.popover
//        if (navCategories.popoverPresentationController != nil) {
//            navCategories.popoverPresentationController?.sourceView = self.view
//            navCategories.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
//        }
//        self.present(navCategories, animated: true, completion: nil)
        
    }
    
    fileprivate func showFirstTimeEditingCellAlert() {
        if (!Preferences.sharedInstance.firstTimeLaunch) {
            let alert = UIAlertController(title: "Quick actions",
                                          message: "By swiping a cell you can quickly send post to the Safari Reading list, or use the more button to share it and access other functionalities",
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {(action: UIAlertAction) in
                Preferences.sharedInstance.firstTimeLaunch = true
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showActionSheetForPost(_ post: Post) {
        var titles = ["Share", "Open", "Open in Safari", "Cancel"]
        
        let sheet = UIAlertController(title: post.title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let handler = {(action: UIAlertAction?) -> () in
            self.tableView.setEditing(false, animated: true)
            if let _ = action {
                if (action!.title == titles[0]) {
                    Helper.showShareSheet(post, controller: self, barbutton: nil)
                }
                else if (action!.title == titles[1]) {
                    let webview = self.storyboard?.instantiateViewController(withIdentifier: "WebviewController") as! WebviewController
                    webview.post = post
                    self.showDetailViewController(webview, sender: nil)
                }
                else if (action!.title == titles[2]) {
                    UIApplication.shared.openURL(post.url! as URL)
                }
            }
        }
        
        for title in titles {
            var type = UIAlertActionStyle.default
            if (title == "Cancel") {
                type = UIAlertActionStyle.cancel
            }
            sheet.addAction(UIAlertAction(title: title, style: type, handler: handler))
        }
        
        self.present(sheet, animated: true, completion: nil)
    }

    
    internal override func onPullToFresh() {
        self.refreshing = true
        
        Post.fetch(filter: self.fileter) { (posts, error, local) in
            if let realDatasource = posts {
                self.datasource = realDatasource
                if self.datasource.count % 30 == 0 {
                    self.loadMoreEnable = true
                } else {
                    self.loadMoreEnable = false
                }
            }
            if !local {
                self.refreshing = false
            }
        }
    }
    
    internal func loadMore() {
        let fetchPage = Int(ceil(Double(self.datasource.count)/30)) + 1
        Post.fetch(self.fileter, withPage: fetchPage) { (posts, error, local) in
            if let realDatasource = posts {
                
                var tempDatasource = self.datasource
                let postsNotFromNewPageCount = ((fetchPage-1)*30)
                if ((tempDatasource?.count)! - postsNotFromNewPageCount > 0) {
                    tempDatasource?.removeSubrange(postsNotFromNewPageCount...((tempDatasource?.count)! - postsNotFromNewPageCount))
                }
                tempDatasource?.append(realDatasource as AnyObject)

                self.datasource = tempDatasource
                if (self.datasource.count % 30 == 0) {
                    self.loadMoreEnable = true
                } else {
                    self.loadMoreEnable = false
                }
            }
            if (!local) {
                self.refreshing = false
                self.tableView.tableFooterView = nil
            }
        }
    }
    
//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if #available(iOS 9, *) {
//            if identifier == "toWebview" {
//                if let url = (sender as? NewsCell)?.post.url {
//                    present(SafariViewController(url: url as URL), animated: true, completion: nil)
//                    return false
//                }
//            }
//        }
//        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!)  {
        if (segue.identifier == "toWebview") {
            let destination = segue.destination as! WebviewController
            if let selectedRows = self.tableView.indexPathsForSelectedRows {
                destination.post = self.datasource[selectedRows[0].row] as! Post
            }
        }
    }
    
}


extension ViewController {
    
    override func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        if (self.datasource != nil) {
            return self.datasource.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellsId) as? NewsCell
        cell!.post = self.datasource[indexPath.row] as! Post
        cell!.cellDelegate = self

        if (loadMoreEnable && indexPath.row == self.datasource.count-3) {
            self.tableView.tableFooterView = self.infiniteScrollingView
            loadMore()
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard let post = self.datasource[indexPath.row] as? Post, let title = post.title as NSString? else {
            return 0
            
        }
        return NewsCell.heightForText(title, bounds: self.tableView.bounds)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]
    {
        let readingList = UITableViewRowAction(style: UITableViewRowActionStyle.normal,
                                               title: "Read\nLater",
                                               handler: {(action: UITableViewRowAction, indexpath: IndexPath) -> Void in
                                                if (Helper.addPostToReadingList(self.datasource[indexPath.row] as! Post )) {
                                                }
                                                _ = self.datasource
                                                Preferences.sharedInstance.addToReadLater(self.datasource[indexPath.row] as! Post )
                                                let cell = self.tableView.cellForRow(at: indexPath) as! NewsCell
                                                cell.readLaterIndicator.isHidden = false
                                                self.tableView.setEditing(false, animated: true)
        })
        readingList.backgroundColor = UIColor.ReadingListColor()
        
        let more = UITableViewRowAction(style: UITableViewRowActionStyle.normal,
                                        title: "More",
                                        handler: {(action: UITableViewRowAction, indexpath: IndexPath) -> Void in
                                            self.showActionSheetForPost(self.datasource[indexPath.row] as! Post )
        })
        
        return [readingList, more]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
extension ViewController: NewsCellDelegate {
    func newsCellDidSelectButton(_ cell: NewsCell, actionType: Int, post: Post) {
        let indexPath = self.tableView.indexPath(for: cell)
        if let realIndexPath = indexPath {
            let delay = 0.2 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) { () -> Void in
                self.tableView.selectRow(at: realIndexPath, animated: false, scrollPosition: .none)
            }
        }
        if (actionType == NewsCellActionType.comment.rawValue) {
            let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            detailVC.post = post
            self.showDetailViewController(detailVC, sender: self)
        }
        else if (actionType == NewsCellActionType.username.rawValue) {
            if post.username != nil {
//                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
//                detailVC.user = realUsername
//                self.showDetailViewController(detailVC, sender: self)
            }
        }

    }
}


