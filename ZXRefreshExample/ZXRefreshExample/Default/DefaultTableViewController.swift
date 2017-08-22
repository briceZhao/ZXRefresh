//
//  DefaultTableViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/22.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class DefaultTableViewController: UITableViewController {
    
    var models = [1,2,3,4,5,6,7,8,9,10]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.tableView?.addRefreshHeaderView {
            [unowned self] in
            
            self.refresh()
        }
        
        self.tableView?.addLoadMoreFooterView {
            [unowned self] in
            
            self.loadMore()
        }
    }
    
    
    func refresh() {
        perform(#selector(endRefresing), with: nil, afterDelay: 3)
    }
    
    func endRefresing() {
        self.tableView?.endRefreshing(isSuccess: true)
    }
    
    func loadMore() {
        perform(#selector(endLoadMore), with: nil, afterDelay: 3)
    }
    
    func endLoadMore() {
        self.tableView?.endLoadMore(isNoMoreData: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "\(models[(indexPath as NSIndexPath).row])"
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    deinit{
        print("Deinit of DefaultTableViewController")
    }
    
}
