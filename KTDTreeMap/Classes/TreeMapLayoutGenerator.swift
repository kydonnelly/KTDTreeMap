//
//  TreeMapLayoutGenerator.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import Foundation

internal protocol TreeMapLayoutGenerator {
    
    func rects(weights: [CGFloat], bounds: CGRect, minSize: CGSize) -> [CGRect]
    func minWeightRatio(minSize: CGSize, fullSize: CGSize) -> CGFloat
    
}

extension TreeMapLayoutGenerator {
    
    func layoutRects(weights: [CGFloat], bounds: CGRect, minSize: CGSize) -> [CGRect] {
        let minRatio = self.minWeightRatio(minSize: minSize, fullSize: bounds.size)
        let adjustedWeights = self.adjustedWeights(weights, minRatio: minRatio)
        
        return self.rects(weights: adjustedWeights, bounds: bounds, minSize: minSize)
    }
    
    // Adjusts raw weights with minimum individual:total weight ratio (≥ 0)
    //   (takes from the rich and gives to the poor, visually)
    // (min(weights) + padding) / (sum(weights) + len(weights) * padding) = minRatio
    internal func adjustedWeights(_ weights: [CGFloat], minRatio: CGFloat) -> [CGFloat] {
        // The maximum ratio if all weights were the minimum
        let maxMinRatio = Double(minRatio) * Double(weights.count)
        
        // Validate minRatio can be represented in positive area chart.
        // A maxMinRatio of 1 is not possible
        //  (except if all weights are the minimum, which doesn't need ajustment)
        guard minRatio >= 0 && maxMinRatio < 1.0 else {
            return weights
        }
        
        guard let minWeight = weights.min() else {
            return weights
        }
        
        let sumWeights = weights.reduce(0, +)
        
        // All weights above min, no adjustment needed
        if minWeight / sumWeights >= minRatio {
            return weights
        }
        
        let adjustment = (minRatio * sumWeights - minWeight) / CGFloat(1.0 - maxMinRatio)
        return weights.map { $0 + adjustment }
    }
    
}
