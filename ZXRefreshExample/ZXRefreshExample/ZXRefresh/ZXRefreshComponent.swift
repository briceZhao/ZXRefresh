//
//  ZXRefreshComponent.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/15.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

/// 状态枚举
///
/// - idle: 闲置
/// - pulling: 正在下拉
/// - willRefresh: 松手刷新
/// - isRefreshing: 正在刷新
/// - noMoreData: 无更多数据
public enum ZXRefreshState {
    case idle
    case pulling
    case willRefresh
    case isRefreshing
    case noMoreData
}

public protocol ZXRefreshComponentDelegate {
    func scollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?)
    func scollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?)
    func scollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?)
}

public class ZXRefreshComponent: UIView {
    
    public weak var scrollView: UIScrollView?
    
    public var scrollViewOriginalInset: UIEdgeInsets?
    
    var state: ZXRefreshState = .idle
    
    /// lifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
        
        self.state = .idle
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if self.state == .willRefresh {
            // 预防view还没显示出来就调用了beginRefreshing
            self.state = .isRefreshing
        }
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard (newSuperview?.isKind(of: UIScrollView.self))! else {
            return
        }
        
        removeObservers()
        
        guard let superView = newSuperview else {
            return
        }
        
        self.frame.size.width = superView.frame.width
        self.frame.origin.x = 0
        
        scrollView = newSuperview as! UIScrollView?
        // 设置永远支持垂直弹簧效果
        scrollView?.alwaysBounceVertical = true
        scrollViewOriginalInset = self.scrollView?.contentInset
        
        addObservers()
    }
    
    // MARK: - KVO
    
    private func addObservers() {
        scrollView?.addObserver(self, forKeyPath: ZXRefreshConstant.keyPathContentOffset, options: .new, context: nil)
        scrollView?.addObserver(self, forKeyPath: ZXRefreshConstant.keyPathContentSize, options: .new, context: nil)
        scrollView?.panGestureRecognizer.addObserver(self, forKeyPath: ZXRefreshConstant.keyPathPanState, options: .new, context: nil)
    }
    
    private func removeObservers() {
        scrollView?.removeObserver(self, forKeyPath: ZXRefreshConstant.keyPathContentOffset)
        scrollView?.removeObserver(self, forKeyPath: ZXRefreshConstant.keyPathContentSize)
        scrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: ZXRefreshConstant.keyPathPanState)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard isUserInteractionEnabled else {
            return
        }
        
        if let delegate:ZXRefreshComponentDelegate = self as? ZXRefreshComponentDelegate {
            
            if keyPath == ZXRefreshConstant.keyPathContentSize {
                delegate.scollViewContentSizeDidChange(change)
            }
            
            guard !self.isHidden else {
                return
            }
            
            if keyPath == ZXRefreshConstant.keyPathContentOffset {
                delegate.scollViewContentOffsetDidChange(change)
            } else if keyPath == ZXRefreshConstant.keyPathPanState {
                delegate.scollViewPanStateDidChange(change)
            }
        }
    }
}



