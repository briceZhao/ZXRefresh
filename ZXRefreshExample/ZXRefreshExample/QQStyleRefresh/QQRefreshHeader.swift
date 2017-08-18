//
//  QQRefreshHeader.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/17.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

class QQRefreshHeader: ZXRefreshHeader, ZXRefreshHeaderDelegate {

    let control: QQStylePullingIndicator
    
    open let textLabel: UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 120,height: 40))
    
    open let imageView: UIImageView = UIImageView()
    
    fileprivate let totalHegiht:CGFloat = 80.0
    
    override public init(frame: CGRect) {
        control = QQStylePullingIndicator(frame: frame)
        let adjustFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: totalHegiht)
        super.init(frame: adjustFrame)
        
        self.autoresizingMask = .flexibleWidth
        self.backgroundColor = UIColor.white
        imageView.sizeToFit()
        imageView.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.darkGray
        addSubview(control)
        addSubview(textLabel)
        addSubview(imageView)
        
        //        textLabel.text = textDic[.pullToRefresh]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        control.frame = self.bounds
        imageView.center = CGPoint(x: frame.width/2 - 40 - 40, y: totalHegiht * 0.75)
        textLabel.center = CGPoint(x: frame.size.width/2, y: totalHegiht * 0.75);
    }
    
    
    // MARK: ZXRefreshHeaderDelegate
    func contentHeight() -> CGFloat {
        return 80.0
    }
    
    func toNormalState() {
        self.control.isHidden = false
        self.imageView.isHidden = true
        self.textLabel.isHidden = true
    }
    
    func toRefreshingState() {
        self.control.animating = true
    }
    
    func toPullingState() {
        
    }
    
    func changePullingPercent(percent: CGFloat) {
        
        self.control.animating = false
        if pullingPercent > 0.5 && pullingPercent <= 1.0{
            self.control.progress = (pullingPercent - 0.5)/0.5
        }else if pullingPercent <= 0.5{
            self.control.progress = 0.0
        }else{
            self.control.progress = 1.0
        }
    }
    func toWillRefreshState() {
        
    }
    
    func willBeginEndRefershing(isSuccess: Bool) {
        if isSuccess {
            self.control.isHidden = true
            imageView.isHidden = false
            textLabel.isHidden = false
            textLabel.text =  ZXHeaderString.refreshSuccess
            imageView.image = UIImage(named: "success", in: Bundle(for: ZXRefreshHeader.self), compatibleWith: nil)
        } else {
            self.control.isHidden = true
            imageView.isHidden = false
            textLabel.isHidden = false
            textLabel.text = ZXHeaderString.refreshFailure
            imageView.image = UIImage(named: "failure", in: Bundle(for: ZXRefreshHeader.self), compatibleWith: nil)
        }
    }

}
