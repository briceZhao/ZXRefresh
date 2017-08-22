//
//  QQRefreshViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/17.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class QQRefreshViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let qqHeader = QQRefreshHeader()
        self.tableView.addRefreshHeaderView(qqHeader, refreshBlock: { 
            [unowned self] in
            
            self.refresh()
        })
    }

    func refresh() {
        perform(#selector(endRefresing), with: nil, afterDelay: 3)
    }
    
    func endRefresing() {
        self.tableView.endRefreshing(isSuccess: true)
    }

}
