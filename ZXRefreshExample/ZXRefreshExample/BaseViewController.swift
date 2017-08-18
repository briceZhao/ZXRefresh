//
//  BaseViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/17.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class BaseViewController: UITableViewController {

    var models = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
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
    
    deinit{
        print("Deinit of \(NSStringFromClass(type(of: self)))")
    }
    
}
