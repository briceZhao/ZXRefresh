//
//  ZXRefreshHeader.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/16.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

public protocol ZXRefreshHeaderDelegate {
    
    func toNormalState()
    func toRefreshingState()
    func toPullingState()
    func toWillRefreshState()
    func changePullingPercent(percent: CGFloat)
    func willBeginEndRefershing(isSuccess: Bool)
    func willCompleteEndRefreshing()
    
    /// 控件的高度
    func contentHeight() -> CGFloat
}

public class ZXRefreshHeader: ZXRefreshComponent, ZXRefreshComponentDelegate {
    
    /// reload data block
    var refreshBlock: () -> Void = { }
    
    public var delegate: ZXRefreshHeaderDelegate? {
        get { return self as? ZXRefreshHeaderDelegate }
    }
    
    var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var insetTDelta: CGFloat = 0
    
    var pullingPercent: CGFloat = 0 {
        didSet {
            delegate?.changePullingPercent(percent: pullingPercent)
        }
    }
    
    override var state: ZXRefreshState {
        didSet {
            guard oldValue != state else {
                return
            }
            
            switch state {
            case .idle:
                guard oldValue == ZXRefreshState.isRefreshing else {
                    return
                }
                
                UIView.animate(withDuration: ZXRefreshConstant.animationDuration, animations: {
                    self.scrollView?.contentInset.top += self.insetTDelta
                }, completion: { (finished) in
                    self.delegate?.willCompleteEndRefreshing()
                    // reload
                    self.delegate?.toNormalState()
                })
            case .pulling:
                DispatchQueue.main.async {
                    self.delegate?.toPullingState()
                }
            case .willRefresh:
                DispatchQueue.main.async {
                    self.delegate?.toWillRefreshState()
                }
            case .isRefreshing:
                DispatchQueue.main.async {
                    UIView.animate(withDuration: ZXRefreshConstant.animationDuration, animations: {
                        // force change state
                        self.delegate?.toRefreshingState()
                        
                        guard let originInset = self.scrollViewOriginalInset else {
                            return
                        }
                        let top: CGFloat = originInset.top + self.mj_h
                        // 增加滚动区域top
                        self.scrollView?.mj_insetT = top
                        // 设置滚动位置
                        self.scrollView?.contentOffset = CGPoint(x: 0, y: -top)
                    }, completion: { (isFinish) in
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
    
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard newSuperview != nil else {
            // newSuperview == nil 被移除的时候
            return
        }
        
        // newSuperview != nil 被添加到新的View上
        self.mj_y = -self.mj_h
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.bounds
    }
    
    
    /// Loadding动画显示区域的高度(特殊的控件需要重写该方法，返回不同的数值)
    ///
    /// - Returns: Loadding动画显示区域的高度
    open func refreshingHoldHeight() -> CGFloat {
        return self.mj_h
    }
    
    
    // MARK: - ZXRefreshComponentDelegate
    open func scollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        
        guard let scrollV = self.scrollView else {
                return
        }
        
        let originalInset = self.scrollViewOriginalInset!
        
        if state == .isRefreshing {
            guard let _ = self.window else {
                return
            }
            // 考虑SectionHeader停留时的高度
            var insetT: CGFloat = -scrollV.mj_offsetY > originalInset.top ? -scrollV.mj_offsetY : originalInset.top
            insetT = insetT > self.mj_h + originalInset.top ? self.mj_h + originalInset.top : insetT
            
            scrollV.mj_insetT = insetT
            self.insetTDelta = originalInset.top - insetT;
            return
        }
        
        // 跳转到下一个控制器 contentInset可能会变
        self.scrollViewOriginalInset = scrollV.contentInset
        
        // 当前的contentOffset
        let offsetY: CGFloat = scrollV.mj_offsetY
        // 头部控件刚好出现的offsetY
        let headerInOffsetY: CGFloat = -originalInset.top
        
        // 如果是向上滚动头部控件还没出现，直接返回
        guard offsetY <= headerInOffsetY else {
            return
        }
        
        // 普通 和 即将刷新 的临界点
        let idle2pullingOffsetY: CGFloat = headerInOffsetY - self.mj_h
        
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
                    self.pullingPercent = (headerInOffsetY - offsetY) / self.mj_h
                    
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
    
    open func scollViewContentSizeDidChange(change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    
    final public func endRefresing(isSuccess: Bool) {
        
        delegate?.willBeginEndRefershing(isSuccess: isSuccess)
        let deadLineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadLineTime) {
            self.state = .idle
        }
    }
}


class DefaultZXRefreshHeader: ZXRefreshHeader, ZXRefreshHeaderDelegate {
    
    lazy var pullingIndicator: UIImageView = {
        let indicator = UIImageView()
        indicator.image = UIImage(named: "tableview_pull_refresh", in: Bundle(for: DefaultZXRefreshHeader.self), compatibleWith: nil)
        
        return indicator
    }()
    
    lazy var loaddingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .gray
        
        return indicator
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.pullingIndicator)
        self.contentView.addSubview(self.loaddingIndicator)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: frame.width * 0.5 - 70 - 20, y: frame.height * 0.5)
        pullingIndicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        pullingIndicator.mj_center = center
        
        loaddingIndicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        loaddingIndicator.mj_center = center
        messageLabel.frame = self.bounds
    }
    
    
    /// 设置控件的高度
    ///
    /// - Returns: 控件的高度
    func contentHeight() -> CGFloat {
        return 60
    }
    
    
    func toNormalState() {
        self.loaddingIndicator.isHidden = true
        self.pullingIndicator.isHidden = false
        self.loaddingIndicator.stopAnimating()
        
        messageLabel.text =  ZXHeaderString.pullDownToRefresh
        pullingIndicator.image = UIImage(named: "tableview_pull_refresh", in: Bundle(for: DefaultZXRefreshHeader.self), compatibleWith: nil)
    }
    
    func toRefreshingState() {
        self.pullingIndicator.isHidden = true
        self.loaddingIndicator.isHidden = false
        self.loaddingIndicator.startAnimating()
        messageLabel.text = ZXHeaderString.refreshing
    }
    
    func toPullingState() {
        self.loaddingIndicator.isHidden = true
        messageLabel.text = ZXHeaderString.pullDownToRefresh
        
        guard pullingIndicator.transform == CGAffineTransform(rotationAngle: CGFloat(-Double.pi+0.000001))  else{
            return
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.pullingIndicator.transform = CGAffineTransform.identity
        })
    }
    
    func toWillRefreshState() {
        messageLabel.text = ZXHeaderString.releaseToRefresh
        self.loaddingIndicator.isHidden = true
        
        guard pullingIndicator.transform == CGAffineTransform.identity else{
            return
        }
        UIView.animate(withDuration: 0.4, animations: {
            self.pullingIndicator.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi+0.000001))
        })
    }
    
    func changePullingPercent(percent: CGFloat) {
        // here do nothing
    }
    
    func willBeginEndRefershing(isSuccess: Bool) {
        self.pullingIndicator.isHidden = false
        self.pullingIndicator.transform = CGAffineTransform.identity
        self.loaddingIndicator.isHidden = true
        
        if isSuccess {
            messageLabel.text =  ZXHeaderString.refreshSuccess
            pullingIndicator.image = UIImage(named: "success", in: Bundle(for: DefaultZXRefreshHeader.self), compatibleWith: nil)
        } else {
            messageLabel.text =  ZXHeaderString.refreshFailure
            pullingIndicator.image = UIImage(named: "failure", in: Bundle(for: DefaultZXRefreshHeader.self), compatibleWith: nil)
        }
        
    }
    
    func willCompleteEndRefreshing() {
        
    }
}


