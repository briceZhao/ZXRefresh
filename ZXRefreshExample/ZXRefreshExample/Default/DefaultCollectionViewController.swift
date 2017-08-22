//
//  DefaultCollectionViewController.swift
//  ZXRefreshExample
//
//  Created by briceZhao on 2017/8/22.
//  Copyright © 2017年 chengyue. All rights reserved.
//

import UIKit

private let reuseIdentifier = "DefaultCollectionViewCellId"

class DefaultCollectionViewController: UIViewController, UICollectionViewDataSource{
    
    var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.setUpCollectionView()
        
        self.collectionView?.addRefreshHeaderView {
            [unowned self] in
            
            self.refresh()
        }
        
        self.collectionView?.addLoadMoreFooterView {
            [unowned self] in
            
            self.loadMore()
        }
    }
    
    
    func refresh() {
        perform(#selector(endRefresing), with: nil, afterDelay: 3)
    }
    
    func endRefresing() {
        self.collectionView?.endRefreshing(isSuccess: true)
    }
    
    func loadMore() {
        perform(#selector(endLoadMore), with: nil, afterDelay: 3)
    }
    
    func endLoadMore() {
        self.collectionView?.endLoadMore(isNoMoreData: true)
    }
    
    
    func setUpCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.dataSource = self
        self.view.addSubview(self.collectionView!)
        
        self.collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
    
    deinit{
        print("Deinit of DefaultCollectionViewController")
    }
}
