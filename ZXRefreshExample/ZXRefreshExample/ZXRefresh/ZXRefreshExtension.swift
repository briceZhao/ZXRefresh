//
//  ZXRefreshExtension.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/16.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIScrollView {
    
    private var zx_header: ZXRefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &ZXRefreshConstant.associatedObjectRefreshHeader) as? ZXRefreshHeader
        }
        set {
            objc_setAssociatedObject(self, &ZXRefreshConstant.associatedObjectRefreshHeader, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var zx_footer: ZXLoadMoreFooter? {
        get {
            return objc_getAssociatedObject(self, &ZXRefreshConstant.associatedObjectRefreshFooter) as? ZXLoadMoreFooter
        }
        set {
            objc_setAssociatedObject(self, &ZXRefreshConstant.associatedObjectRefreshFooter, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 添加下拉刷新
    
    public func addRefreshHeaderView(_ refreshHeader: ZXRefreshHeader? = DefaultZXRefreshHeader(), refreshBlock:@escaping () -> Void) {
        if let _: ZXRefreshHeaderDelegate = self as? ZXRefreshHeaderDelegate {
            fatalError("refreshHeader must implement ZXRefreshHeaderDelegate")
        }
        if let header: DefaultZXRefreshHeader = refreshHeader as? DefaultZXRefreshHeader {
            header.frame = CGRect(x: 0, y: 0, width: self.mj_w, height: 60.0)
        }
        if zx_header != refreshHeader {
            zx_header?.removeFromSuperview()
            
            if let header:ZXRefreshHeader = refreshHeader {
                header.refreshBlock = refreshBlock
                self.insertSubview(header, at: 0)
                self.zx_header = header
            }
        }
    }
    
    /// 添加上拉加载
    
    public func addLoadMoreFooterView(_ loadMoreFooter: ZXLoadMoreFooter? = DefaultZXLoadMoreFooter(), loadMoreBlock:@escaping () -> Void) {
        
        if let _: ZXLoadMoreFooterDelegate = self as? ZXLoadMoreFooterDelegate {
            fatalError("loadMoreFooter must implement ZXLoadMoreFooterDelegate")
        }
        if zx_footer != loadMoreFooter {
            zx_footer?.removeFromSuperview()
            
            if let footer:ZXLoadMoreFooter = loadMoreFooter {
                footer.loadMoreBlock = loadMoreBlock
                self.insertSubview(footer, at: 0)
                self.zx_footer = footer
            }
        }
    }
    
    public func endRefreshing() {
        self.zx_header?.endRefresing()
    }
}

extension UIScrollView {
    var mj_insetT: CGFloat {
        get { return contentInset.top }
        set {
            var inset = self.contentInset
            inset.top = newValue
            self.contentInset = inset
        }
    }
    var mj_insetB: CGFloat {
        get { return contentInset.bottom }
        set {
            var inset = self.contentInset
            inset.bottom = newValue
            self.contentInset = inset
        }
    }
    var mj_insetL: CGFloat {
        get { return contentInset.left }
        set {
            var inset = self.contentInset
            inset.left = newValue
            self.contentInset = inset
        }
    }
    var mj_insetR: CGFloat {
        get { return contentInset.right }
        set {
            var inset = self.contentInset
            inset.right = newValue
            self.contentInset = inset
        }
    }
    
    
    var mj_offsetX: CGFloat {
        get { return contentOffset.x }
        set {
            var offset = self.contentOffset
            offset.x = newValue
            self.contentOffset = offset
        }
    }
    var mj_offsetY: CGFloat {
        get { return contentOffset.y }
        set {
            var offset = self.contentOffset
            offset.y = newValue
            self.contentOffset = offset
        }
    }
    
    
    var mj_contentW: CGFloat {
        get { return contentSize.width }
        set {
            var size = self.contentSize
            size.width = newValue
            self.contentSize = size
        }
    }
    var mj_contentH: CGFloat {
        get { return contentSize.height }
        set {
            var size = self.contentSize
            size.height = newValue
            self.contentSize = size
        }
    }
}

extension UIView {
    
    var mj_x: CGFloat {
        get { return frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var mj_y: CGFloat {
        get { return frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var mj_w: CGFloat {
        get { return frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var mj_h: CGFloat {
        get { return frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var mj_size: CGSize {
        get { return frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    var mj_origin: CGPoint {
        get { return frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var mj_center: CGPoint {
        get { return CGPoint(x: (frame.size.width-frame.origin.x)*0.5, y: (frame.size.height-frame.origin.y)*0.5) }
        set {
            var frame = self.frame
            frame.origin = CGPoint(x: newValue.x - frame.size.width*0.5, y: newValue.y - frame.size.height*0.5)
            self.frame = frame
        }
    }
    
}


