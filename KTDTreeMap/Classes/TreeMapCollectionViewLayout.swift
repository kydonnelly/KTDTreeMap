//
//  TreeMapCollectionViewLayout.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import Foundation

internal class TreeMapCollectionViewLayout : UICollectionViewLayout {
    
    private var preparedAttributes: [UICollectionViewLayoutAttributes] = []
    private var currentLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var layoutGenerator: TreeMapLayoutGenerator = SquareTreeMapLayoutGenerator()
    
    private var treeMapCollectionView: TreeMapCollectionView? {
        return self.collectionView as? TreeMapCollectionView
    }
    
    func setLayoutType(_ layoutType: TreeMapCollectionView.LayoutType) {
        switch layoutType {
        case .rows:
            self.layoutGenerator = RowTreeMapLayoutGenerator()
        case .columns:
            self.layoutGenerator = ColumnTreeMapLayoutGenerator()
        case .squares:
            self.layoutGenerator = SquareTreeMapLayoutGenerator()
        case .spiral:
            self.layoutGenerator = SpiralTreeMapLayoutGenerator()
        }
    }
    
    override public var collectionViewContentSize: CGSize {
        if let collectionView = self.collectionView {
            return collectionView.bounds.size
        } else {
            return .zero
        }
    }
    
    override public func prepare() {
        super.prepare()
        
        guard let collectionView = self.treeMapCollectionView else {
            return
        }
        
        let weights = collectionView.currentWeights
        let minSize = collectionView.minCellSize
        
        let rects = self.layoutGenerator.layoutRects(weights: weights, bounds: collectionView.bounds, minSize: minSize)
        self.preparedAttributes = rects.enumerated().map {
            let indexPath = IndexPath(item: $0.offset, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = $0.element
            return attributes
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.preparedAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        self.currentLayoutAttributes = self.preparedAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard itemIndexPath.row < self.preparedAttributes.count else {
            return nil
        }
        
        return self.currentLayoutAttributes[itemIndexPath.row]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard itemIndexPath.row < self.preparedAttributes.count else {
            return nil
        }
        
        return self.preparedAttributes[itemIndexPath.row]
    }
}
