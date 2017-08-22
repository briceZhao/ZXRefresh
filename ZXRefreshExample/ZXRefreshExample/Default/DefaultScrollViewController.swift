//
//  DefaultScrollViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/22.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class DefaultScrollViewController: UIViewController {
    
    var scrollView: UIScrollView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        setUpScrollView()
        
        self.scrollView?.addRefreshHeaderView {
            [unowned self] in
            
            self.refresh()
        }
        
        self.scrollView?.addLoadMoreFooterView {
            [unowned self] in
            
            self.loadMore()
        }
    }
    
    
    func refresh() {
        perform(#selector(endRefresing), with: nil, afterDelay: 3)
    }
    
    func endRefresing() {
        self.scrollView?.endRefreshing(isSuccess: true)
    }
    
    func loadMore() {
        perform(#selector(endLoadMore), with: nil, afterDelay: 3)
    }
    
    func endLoadMore() {
        self.scrollView?.endLoadMore(isNoMoreData: true)
    }
    
    func setUpScrollView(){
        self.scrollView = UIScrollView(frame: CGRect(x: 0,y: 0,width: 300,height: 300))
        self.scrollView?.backgroundColor = UIColor.lightGray
        self.scrollView?.center = self.view.center
        self.scrollView?.contentSize = CGSize(width: 300,height: 600)
        self.view.addSubview(self.scrollView!)
    }
    
}
