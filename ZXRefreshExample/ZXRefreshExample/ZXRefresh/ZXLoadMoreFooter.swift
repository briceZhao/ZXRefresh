//
//  ZXLoadMoreFooter.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/16.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

public protocol ZXLoadMoreFooterDelegate {
    
}

public class ZXLoadMoreFooter: ZXRefreshComponent {
    
    var loadMoreBlock: () -> Void = {}
    
}


class DefaultZXLoadMoreFooter: ZXLoadMoreFooter {
    
}
