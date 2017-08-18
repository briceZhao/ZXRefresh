//
//  ZXRefreshConstant.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/15.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class ZXRefreshConstant {
    
    static let animationDuration: TimeInterval = 0.25
    
    static let keyPathContentOffset: String = "contentOffset"
    static let keyPathContentInset: String = "contentInset"
    static let keyPathContentSize: String = "contentSize"
    
    
    static var associatedObjectRefreshHeader = 0
    static var associatedObjectRefreshFooter = 1
    
}

struct ZXHeaderString{
    static let pullDownToRefresh = "pullDownToRefresh"
    static let releaseToRefresh = "releaseToRefresh"
    static let refreshSuccess = "refreshSuccess"
    static let refreshFailure = "refreshFailure"
    static let refreshing = "refreshing"
}

struct ZXFooterString{
    static let pullUpToRefresh = "pullUpToRefresh"
    static public let loadding = "loadMore"
    static let noMoreData = "noMoreData"
    static public let releaseLoadMore = "releaseLoadMore"
    static let scrollAndTapToRefresh = "scrollAndTapToRefresh"
}
