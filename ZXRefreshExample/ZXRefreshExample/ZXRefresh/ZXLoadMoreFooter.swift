//
//  ZXLoadMoreFooter.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/16.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

public protocol ZXLoadMoreFooterDelegate {
    func toNormalState()
    func toNoMoreDataState()
    func toWillRefreshState()
    func toRefreshingState()
    //  func setPullingPrecent(precent: CGFloat)
    
    func contentHeight() -> CGFloat
}

public class ZXLoadMoreFooter: ZXRefreshComponent, ZXRefreshComponentDelegate {
    
    var loadMoreBlock: () -> Void = {}
    
    var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var lastBottomDelta: CGFloat = 0.0
    
    public var delegate: ZXLoadMoreFooterDelegate? {
        get { return self as? ZXLoadMoreFooterDelegate }
    }
    
    override var state: ZXRefreshState {
        didSet {
            guard oldValue != state, let scrollV = scrollView else {
                return
            }
            switch state {
            case .noMoreData, .idle:
                guard oldValue == .isRefreshing else {
                    return
                }
                // 结束加载
                UIView.animate(withDuration: ZXRefreshConstant.animationDuration, animations: {
                    scrollV.mj_insetB -= self.lastBottomDelta
                }, completion: { (isComplet) in
                    self.state == .idle ? self.delegate?.toNormalState() : self.delegate?.toNoMoreDataState()
                })
            case .isRefreshing:
                // 展示正在加载动效
                UIView.animate(withDuration: ZXRefreshConstant.animationDuration, animations: {
                    let overflowHeight = self.contentOverflowHeight
                    var toInsetB = self.mj_h + (self.scrollViewOriginalInset?.bottom)!
                    if overflowHeight < 0 {
                        // 如果内容还没占满
                        toInsetB -= overflowHeight
                    }
                    
                    self.lastBottomDelta = toInsetB - scrollV.mj_insetB
                    scrollV.mj_insetB = toInsetB
                    scrollV.mj_offsetY = self.footerCloseOffsetY + self.mj_h
                }, completion: { (isComplet) in
                    self.loadMoreBlock()
                    self.delegate?.toRefreshingState()
                })
                
            case .willRefresh:
                DispatchQueue.main.async {
                    self.delegate?.toWillRefreshState()
                }
                
            default: break
            }
        }
    }
    
    // MARK: Life Cycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.contentView)
        self.contentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.scollViewContentSizeDidChange(change: nil)
        
    }
    
    // MARK: ZXRefreshComponentDelegate
    
    open func scollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        // isRefreshing或者noMoreData状态，直接返回
        guard state != .isRefreshing, state != .noMoreData, let scrollV = scrollView else {
            return
        }
        
        self.scrollViewOriginalInset = scrollV.contentInset
        
        let currentOffsetY = scrollV.mj_offsetY
        let footerCloseOffsetY = self.footerCloseOffsetY
        
        
        guard currentOffsetY >= footerCloseOffsetY else {
            // footer还没出现， 直接返回
            return
        }
        
        if scrollV.isDragging {
            // 拖动状态
            let willLoadMoreOffsetY = footerCloseOffsetY + self.mj_h
            
            switch currentOffsetY {
            case footerCloseOffsetY...willLoadMoreOffsetY:
                state = .pulling
            case willLoadMoreOffsetY...1000:
                state = .willRefresh
            default: break
            }
        } else {
            // 停止拖动状态
            switch state {
            case .pulling:
                state = .idle
            case .willRefresh:
                state = .isRefreshing
            default: break
            }
        }
    }
    
    open func scollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        // here do nothing
        guard let scrollV = scrollView, let originInset = scrollViewOriginalInset else {
            return
        }
        // 重设位置
        let contentH = scrollV.mj_contentH  // 内容高度
        let visibleH = scrollV.mj_h - originInset.top - originInset.bottom  // 可见区域高度
        
        self.mj_y = contentH > visibleH ? contentH : visibleH
    }
    
    // MARK: Public
    public func endLoadMore(isNoMoreData: Bool) {
        if isNoMoreData {
            state = .noMoreData
        } else {
            state = .idle
        }
    }
    
    
    // MARK: Layout
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.bounds
    }
    
    
    // MARK: Private
    
    /// ScrollView内容溢出的高度
    private var contentOverflowHeight: CGFloat {
        get {
            guard let scrollV = scrollView, let originInset = scrollViewOriginalInset else {
                return 0.0
            }
            // ScrollView内容占满的高度
            let fullContentHeight = scrollV.mj_h - originInset.bottom - originInset.top
            return scrollV.mj_contentH - fullContentHeight
        }
    }
    
    /// 上拉刷新控件即将出现时的OffsetY
    private var footerCloseOffsetY: CGFloat {
        get {
            guard let _ = scrollView, let originInset = scrollViewOriginalInset else {
                return 0.0
            }
            let overflowHeight = contentOverflowHeight
            if overflowHeight > 0 {
                return overflowHeight - originInset.top
            } else {
                return -originInset.top
            }
        }
    }
    
    
}


class DefaultZXLoadMoreFooter: ZXLoadMoreFooter,ZXLoadMoreFooterDelegate {
    
    lazy var pullingIndicator: UIImageView = {
        let pindicator = UIImageView()
        pindicator.image = UIImage(named: "tableview_pull_refresh", in: Bundle(for: ZXLoadMoreFooter.self), compatibleWith: nil)
        return pindicator
    }()
    
    lazy var loaddingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .gray
        indicator.backgroundColor = UIColor.white
        
        return indicator
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = ZXFooterString.pullUpToRefresh
        
        return label
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.pullingIndicator)
        self.contentView.addSubview(self.loaddingIndicator)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard newSuperview != nil else {
            return
        }
        
        self.pullingIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi + 0.000001))
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: frame.width * 0.5 - 70 - 30, y: frame.height * 0.5)
        pullingIndicator.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        pullingIndicator.mj_center = center
        
        loaddingIndicator.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        loaddingIndicator.mj_center = center
        messageLabel.frame = self.bounds
    }
    
    // MARK: ZXLoadMoreFooterDelegate
    
    func contentHeight() -> CGFloat {
        
        return 60.0
    }
    
    func toNormalState() {
        pullingIndicator.isHidden = false
        self.loaddingIndicator.isHidden = true
        self.loaddingIndicator.stopAnimating()
        
        messageLabel.text =  ZXFooterString.pullUpToRefresh
        UIView.animate(withDuration: 0.4, animations: {
            self.pullingIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi + 0.000001))
        })
    }
    
    func toNoMoreDataState() {
        pullingIndicator.isHidden = true
        self.loaddingIndicator.isHidden = true
        self.loaddingIndicator.stopAnimating()
        messageLabel.text =  ZXFooterString.noMoreData
    }
    
    func toWillRefreshState() {
        messageLabel.text =  ZXFooterString.releaseLoadMore
        UIView.animate(withDuration: 0.4, animations: {
            self.pullingIndicator.transform = CGAffineTransform.identity
        })
    }
    
    func toRefreshingState() {
        self.loaddingIndicator.isHidden = false
        self.loaddingIndicator.startAnimating()
        messageLabel.text =  ZXFooterString.loadding
    }

}
