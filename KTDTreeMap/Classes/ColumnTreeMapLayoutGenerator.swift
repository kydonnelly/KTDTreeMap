//
//  ColumnTreeMapLayoutGenerator.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import Foundation

internal class ColumnTreeMapLayoutGenerator : TreeMapLayoutGenerator {
    
    func minWeightRatio(minSize: CGSize, fullSize: CGSize) -> CGFloat {
        guard fullSize.width > 0.0 else {
            return 0.0
        }
        
        return minSize.width / fullSize.width
    }
    
    func rects(weights: [CGFloat], bounds: CGRect, minSize: CGSize) -> [CGRect] {
        let sumWeights = weights.reduce(0, +)
        
        var x: CGFloat = 0.0
        var rects: [CGRect] = []
        for weight in weights {
            let width = bounds.size.width * weight / sumWeights
            rects.append(CGRect(x: x, y: 0, width: width, height: bounds.size.height))
            x += width
        }
        
        return rects
    }
    
}
