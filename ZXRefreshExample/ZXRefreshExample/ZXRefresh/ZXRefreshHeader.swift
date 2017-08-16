//
//  ZXRefreshHeader.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/16.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

public protocol ZXRefreshHeaderDelegate {
    func headerToNormalState()
    func headerToRefreshingState()
    func headerToPullingState()
    func headerSet(pullingPercent: CGFloat)
    func headerToWillRefreshState()
}

public class ZXRefreshHeader: ZXRefreshComponent, ZXRefreshComponentDelegate {
    
    /// reload data block
    var refreshBlock: () -> Void = { print("refreshBlock") }
    
    var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var insetTDelta: CGFloat = 0
    
    var pullingPercent: CGFloat = 0 {
        didSet {
            let delegate: ZXRefreshHeaderDelegate? = self as? ZXRefreshHeaderDelegate
            delegate?.headerSet(pullingPercent: pullingPercent)
        }
    }
    
    
    override var state: ZXRefreshState {
        // FIXME: get方法可能死循环，需要测试
        didSet {
            guard oldValue != state else {
                return
            }
            
            let sub: ZXRefreshHeaderDelegate? = self as? ZXRefreshHeaderDelegate
            switch state {
            case .idle:
                guard oldValue == ZXRefreshState.isRefreshing else {
                    return
                }
                // 恢复Inset
                UIView.animate(withDuration: ZXRefreshConstant.animationDuration, animations: {
                    self.scrollView?.contentInset.top += self.insetTDelta
                    sub?.headerToNormalState()
                })
            case .pulling:
                DispatchQueue.main.async {
                    sub?.headerToPullingState()
                }
            case .willRefresh:
                DispatchQueue.main.async {
                    sub?.headerToWillRefreshState()
                }
            case .isRefreshing:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: ZXRefreshConstant.animationDuration, animations: {
                        guard let originInset = self.scrollViewOriginalInset else {
                            return
                        }
                        let top: CGFloat = originInset.top + self.frame.height
                        // 增加滚动区域top
                        self.scrollView?.contentInset.top = top
                        // 设置滚动位置
                        self.scrollView?.contentOffset = CGPoint(x: 0, y: -top)
                    }, completion: { (isFinish) in
                        sub?.headerToRefreshingState()
                        // 执行刷新操作
                        self.refreshBlock()
                    })
                }
            default: break
            }
        }
    }
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.contentView)
        self.contentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // change frame
        var f = frame
        f.origin.y = -frame.size.height
        self.frame = f
        print("f.origin.y = \(f.origin.y) frame.size.height = \(frame.size.height)")

        self.contentView.frame = self.bounds
    }
    
    // MARK: - ZXRefreshComponentDelegate
    
    open func scollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
        guard let scrollV = self.scrollView
            else {
                return
        }
        
        let originalInset = self.scrollViewOriginalInset!
        
        if state == .isRefreshing {
            
            var insetT: CGFloat = -scrollV.contentOffset.y > originalInset.top ? -scrollV.contentOffset.y : originalInset.top
            insetT = insetT > self.frame.height + originalInset.top ? self.frame.height + originalInset.top : insetT
            
            scrollV.contentInset.top = insetT
            self.insetTDelta = originalInset.top - insetT;
            return
        }
        
        // 跳转到下一个控制器 contentInset可能会变
        self.scrollViewOriginalInset = scrollV.contentInset
        
        // 当前的contentOffset
        let offsetY: CGFloat = scrollV.contentOffset.y;
        // 头部控件刚好出现的offsetY
        let headerInOffsetY: CGFloat = -originalInset.top;
        
        // 如果是向上滚动头部控件还没出现，直接返回
        guard offsetY <= headerInOffsetY else {
            return
        }
        
        // 普通 和 即将刷新 的临界点
        let idle2pullingOffsetY: CGFloat = headerInOffsetY - self.mj_h;
        
        if scrollV.isDragging {
            switch state {
            case .idle:
                if offsetY <= headerInOffsetY {
                    state = .pulling
                }
            case .pulling:
                // print("offsetY = \(offsetY)  idle2pullingOffsetY = \(idle2pullingOffsetY)")
                if offsetY <= idle2pullingOffsetY {
                    state = .willRefresh
                } else {
                    self.pullingPercent = (headerInOffsetY - offsetY) / self.mj_h;
                    
                }
            case .willRefresh:
                if offsetY > idle2pullingOffsetY {
                    state = .idle
                }
            default: break
            }
        } else {
            // 停止Drag && 并且是即将刷新状态
            if state == .willRefresh {
                // 开始刷新
                self.pullingPercent = 1.0;
                // 只要正在刷新，就完全显示
                if self.window != nil {
                    state = .isRefreshing
                } else {
                    // 预防正在刷新中时，调用本方法使得header inset回置失败
                    if state != .isRefreshing {
                        state = .willRefresh
                        // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
                        self.setNeedsDisplay()
                    }
                }
            }
        }
    }
    
    open func scollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    open func scollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    final public func endRefresing() {
        DispatchQueue.main.async {
            print("header.endRefresing()")
            self.state = .idle
        }
    }
}


class DefaultZXRefreshHeader: ZXRefreshHeader, ZXRefreshHeaderDelegate {
    
    lazy var pullingIndicator: UIImageView = {
        let pindicator = UIImageView()
        pindicator.image = UIImage(named: "tableview_pull_refresh", in: Bundle(for: DefaultZXRefreshHeader.self), compatibleWith: nil)
        
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
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: frame.width * 0.5 - 70 - 20, y: frame.height * 0.5)
        pullingIndicator.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        pullingIndicator.mj_center = center
        
        loaddingIndicator.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        loaddingIndicator.mj_center = center
        messageLabel.frame = self.bounds
    }
    
    
    
    func headerToNormalState() {
        print("-------> headerToNormalState() ")
        self.loaddingIndicator.isHidden = true
        self.loaddingIndicator.stopAnimating()
    }
    func headerToRefreshingState() {
        print("-------> headerToRefreshingState() ")
        self.loaddingIndicator.isHidden = false
        self.loaddingIndicator.startAnimating()
        messageLabel.text = ZXHeaderString.refreshing
    }
    func headerToPullingState() {
        print("-------> headerToPullingState() ")
        self.loaddingIndicator.isHidden = true
        messageLabel.text = ZXHeaderString.pullDownToRefresh
        
        guard pullingIndicator.transform == CGAffineTransform(rotationAngle: CGFloat(-Double.pi+0.000001))  else{
            return
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.pullingIndicator.transform = CGAffineTransform.identity
        })
    }
    func headerToWillRefreshState() {
        print("-------> headerToWillRefreshState() ")
        messageLabel.text = ZXHeaderString.releaseToRefresh
        self.loaddingIndicator.isHidden = true
        
        guard pullingIndicator.transform == CGAffineTransform.identity else{
            return
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.pullingIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi+0.000001))
        })
    }
    func headerSet(pullingPercent: CGFloat) {
        
    }
}

/// 指示器进度
class WaterIndicator: UIView {
    
    let maxRadius: CGFloat = 15.0
    
    var progress: CGFloat {
        get { return self.progress }
        set {
            if progress != newValue {
                self.setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
}


