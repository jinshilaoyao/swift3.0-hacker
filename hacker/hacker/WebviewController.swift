//
//  WebviewController.swift
//  hacker
//
//  Created by yesway on 2017/1/16.
//  Copyright © 2017年 joker. All rights reserved.
//

import UIKit

class WebviewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var post: Post!
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        if let _ = post {
            if let realUrl = post.url {
                webView.loadRequest(URLRequest(url: realUrl as URL))
            }
        }
    }
    
    func setupLoadingButton() {
        self.navigationItem.rightBarButtonItem = nil
        let loadingItem = UIBarButtonItem(customView: self.activityIndicator)
        self.activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = loadingItem
    }
    
    func setupShareButton() {
        self.navigationItem.rightBarButtonItem = nil
        let shareItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(WebviewController.setupShareButton))
        self.navigationItem.rightBarButtonItem = shareItem
    }
    
    func onShareButton() {
        Helper.showShareSheet(self.post, controller: self, barbutton: self.navigationItem.rightBarButtonItem)
    }
}
extension WebviewController {
    func webViewDidStartLoad(_ webView: UIWebView) {
        setupLoadingButton()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        setupShareButton()
        self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
    }
}
