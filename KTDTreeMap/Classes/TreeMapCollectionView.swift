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
        /// Arranges cells into rows stacked vertically. Also known as 'slicing'.
        /// The delegate's minimumCellSize specifies minimum row height.
        case rows
        
        /// Arranges cells into columns lined horizontally. Also known as 'dicing'.
        /// The delegate's minimumCellSize specifies minimum column width.
        case columns
        
        /// Arranges cells as rectangles with low aspect ratios.
        /// Generally ordered largest-to-smallest from top-left to bottom-right.
        /// The delegate's minimumCellSize specifies minimum cell area.
        case squares
        
        /// Arranges cells as rectangles with a minimum size.
        /// Generally ordered smallest-to-largest in a clockwise spiral.
        /// The delegate's minimumCellSize specifies the minimum cell size.
        case spiral
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
