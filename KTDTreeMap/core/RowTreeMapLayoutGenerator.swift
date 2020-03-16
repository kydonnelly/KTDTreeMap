//
//  RowTreeMapLayoutGenerator.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import Foundation

internal class RowTreeMapLayoutGenerator : TreeMapLayoutGenerator {
    
    func minWeightRatio(minSize: CGSize, fullSize: CGSize) -> CGFloat {
        guard fullSize.width > 0.0 else {
            return 0.0
        }
        
        return minSize.width / fullSize.width
    }
    
    func rects(weights: [CGFloat], bounds: CGRect) -> [CGRect] {
        let sumWeights = weights.reduce(0, +)
        
        var y: CGFloat = 0.0
        var rects: [CGRect] = []
        for weight in weights {
            let height = bounds.size.height * weight / sumWeights
            rects.append(CGRect(x: 0, y: y, width: bounds.size.width, height: height))
            y += height
        }
        
        return rects
    }
    
}
