//
//  BaseViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/17.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class BaseViewController: UITableViewController {

    var models = ["1、你若安好，便是晴天。",
                  "2、人生没有彩排，每一天都是现场直播。",
                  "3、我们走得太快，灵魂都跟不上了。",
                  "4、人生就像一杯茶，不会苦一辈子，但总会苦一阵子。",
                  "5、人生如果错了方向，停止就是进步。",
                  "6、理想很丰满，现实很骨感。",
                  "7、男人一有钱就变坏，女人一边坏就有钱。",
                  "8、择一城终老，遇一人白首。",
                  "9、低头要有勇气，抬头要有底气。",
                  "10、愿得一人心，白首不分离。",
                  "11、一个人炫耀什么，说明内心缺少什么。",
                  "12、试金可以用火，试女人可以用金，试男人可以用女人。",
                  "13、时间就像一张网，你撒在哪里，你的收获就在哪里。",
                  "14、学习要加，骄傲要减，机会要乘，懒惰要除。",
                  "15、如果你简单，这个世界就对你简单。"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.view.backgroundColor = UIColor.lightGray
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
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    deinit{
        print("Deinit of \(NSStringFromClass(type(of: self)))")
    }
    
}
