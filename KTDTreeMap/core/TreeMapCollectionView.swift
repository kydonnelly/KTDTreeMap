//
//  TreeMapCollectionView.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import UIKit

/// Extended DataSource behavior
@objc public protocol TreeMapCollectionViewDataSource : UICollectionViewDataSource {
    
    func weights(for treeMap: TreeMapCollectionView) -> [CGFloat]
    @objc optional func minimumCellSize(for treeMap: TreeMapCollectionView) -> CGSize
    
}

/// Definition and overrides
@objc public class TreeMapCollectionView : UICollectionView {
    
    @objc public enum LayoutType: Int {
        case rows
        case columns
        case squares
    }
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: TreeMapCollectionViewLayout())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.collectionViewLayout = TreeMapCollectionViewLayout()
    }
    
    @objc public var layoutType: LayoutType = .squares {
        didSet {
            self.treeMapLayout?.setLayoutType(layoutType)
            self.collectionViewLayout.invalidateLayout()
        }
    }
    
}

/// Variable Casts
extension TreeMapCollectionView {
    
    fileprivate var treeMapLayout: TreeMapCollectionViewLayout? {
        return self.collectionViewLayout as? TreeMapCollectionViewLayout
    }
    
    fileprivate var treeMapDataSource: TreeMapCollectionViewDataSource? {
        return self.delegate as? TreeMapCollectionViewDataSource
    }
    
}

/// DataSource access methods
extension TreeMapCollectionView {
    
    internal var currentWeights: [CGFloat] {
        guard let dataSource = self.treeMapDataSource else {
            return []
        }
        
        return dataSource.weights(for: self)
    }
    
    internal var minCellSize: CGSize {
        guard let dataSource = self.treeMapDataSource else {
            return .zero
        }
        
        return dataSource.minimumCellSize?(for: self) ?? .zero
    }
    
}
