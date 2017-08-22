//
//  DefaultWebViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/22.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class DefaultWebViewController: UIViewController, UIWebViewDelegate {

    var webview: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webview = UIWebView(frame:view.bounds)
        self.webview?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.webview?.backgroundColor = UIColor.white
        view.addSubview(self.webview!)
        
        self.webview?.scrollView.addRefreshHeaderView {
            [unowned self] in
            
            self.refresh()
        }
        
        self.webview?.scrollView.addLoadMoreFooterView {
            [unowned self] in
            
            self.loadMore()
        }
    }
    
    
    func refresh() {
        perform(#selector(endRefresing), with: nil, afterDelay: 3)
    }
    
    func endRefresing() {
        self.webview?.scrollView.endRefreshing(isSuccess: true)
    }
    
    func loadMore() {
        perform(#selector(endLoadMore), with: nil, afterDelay: 3)
    }
    
    func endLoadMore() {
        self.webview?.scrollView.endLoadMore(isNoMoreData: true)
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webview?.scrollView.endRefreshing(isSuccess: true)
    }
    
}
