//
//  DetailViewController.swift
//  hacker
//
//  Created by yesway on 2017/1/16.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

class DetailViewController: YYTableViewController {

    var post: Post!
    var cellHeightCache: [CGFloat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Post"
        
        self.setupBarButtonItems()
        self.onPullToFresh()
    }

    func setupBarButtonItems() {
        let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(DetailViewController.onShareButton))
        self.navigationItem.rightBarButtonItem = shareItem
    }
    
    override func onPullToFresh() {
        
        Comment.fetch(forPost: self.post, completion: {(comments: [Comment]!, error: Fetcher.ResponseError!, local: Bool) in
            if let realDatasource = comments {
                DispatchQueue.global().async {
                    self.cacheHeight(realDatasource as NSArray)
                    DispatchQueue.main.async {
                        self.datasource = comments
                    }
                }
            }
            if (!local) {
                self.refreshing = false
            }
        } as! Comment.Response)
    }
    
    func onShareButton() {
        Helper.showShareSheet(self.post, controller: self, barbutton: self.navigationItem.rightBarButtonItem)
    }
    
    func cacheHeight(_ comments: NSArray) {
        cellHeightCache = []
        for comment in comments {
            if let realComment = comment as? Comment {
                let height = CommentsCell.heightForText(realComment.text!, bounds: self.tableView.bounds, level: realComment.depth)
                cellHeightCache.append(height)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0) {
            let title: NSString = self.post.title! as NSString
            return NewsCell.heightForText(title, bounds: self.tableView.bounds)
        }
        return self.cellHeightCache[indexPath.row] as CGFloat
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        
        if (self.datasource != nil) {
            return self.datasource.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellsId) as? NewsCell
            cell!.post = self.post
            cell!.cellDelegate = self;
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentsCellId) as! CommentsCell!
        let comment = self.datasource[indexPath.row] as! Comment
        cell?.comment = comment
        
        return cell!
    }
    
}

extension DetailViewController: NewsCellDelegate {
    func newsCellDidSelectButton(_ cell: NewsCell, actionType: Int, post: Post) {
        if (actionType == NewsCellActionType.username.rawValue) {
            if let realUsername = post.username {
//                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
//                detailVC.user = realUsername
//                self.showDetailViewController(detailVC, sender: self)
            }
        }

    }
}
