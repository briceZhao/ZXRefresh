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
    static let pullDownToRefresh = "下拉刷新页面"
    static let releaseToRefresh = "松手开始刷新"
    static let refreshSuccess = "成功加载页面"
    static let refreshFailure = "刷新失败"
    static let refreshing = "正在刷新...请稍等"
}

struct ZXFooterString{
    static let pullUpToRefresh = "上拉加载更多内容"
    static public let loadding = "正在加载..."
    static let noMoreData = "没有更多的内容了..."
    static public let releaseLoadMore = "松手加载更多内容"
    static let scrollAndTapToRefresh = "scrollAndTapToRefresh"
}


