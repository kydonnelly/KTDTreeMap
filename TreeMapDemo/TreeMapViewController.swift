//
//  TreeMapViewController.swift
//  TreeMapDemo
//
//  Created by Kyle Donnelly on 3/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit
import KTDTreeMap

class TreeMapViewController: UIViewController {
    
    @IBOutlet var collectionView: TreeMapCollectionView!
    
    private var sizes: [Double] = []
    private var layoutType: TreeMapCollectionView.LayoutType = .squares
    
    public func setup(sizes: [Double], layoutType: TreeMapCollectionView.LayoutType) {
        self.sizes = sizes
        self.layoutType = layoutType
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.collectionView.layoutType = self.layoutType
        self.collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.reloadData()
    }

}

extension TreeMapViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sizes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TreeMapCell", for: indexPath)
        
        guard let tmCell = cell as? TreeMapCell else {
            return cell
        }
        
        let size = self.sizes[indexPath.row]
        tmCell.setup(title: "\(size)", colorIndex: indexPath.row, numColors: self.sizes.count)
        
        return tmCell
    }
    
}

extension TreeMapViewController : TreeMapCollectionViewDataSource {
    
    func weights(for treeMap: TreeMapCollectionView) -> [CGFloat] {
        return self.sizes.map { CGFloat($0) }
    }
    
    func minimumCellSize(for treeMap: TreeMapCollectionView) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
}

