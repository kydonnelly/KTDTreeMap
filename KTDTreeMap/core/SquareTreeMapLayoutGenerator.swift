//
//  SquareTreeMapLayoutGenerator.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import Foundation

// Reference: https://www.win.tue.nl/~vanwijk/stm.pdf
internal class SquareTreeMapLayoutGenerator : TreeMapLayoutGenerator {
    
    func minWeightRatio(minSize: CGSize, fullSize: CGSize) -> CGFloat {
        let boundsArea = fullSize.width * fullSize.height
        
        if boundsArea > 0.0 {
            return minSize.width * minSize.height / boundsArea
        } else {
            return 0.0
        }
    }
    
    func rects(weights: [CGFloat], bounds: CGRect) -> [CGRect] {
        // This layout looks best when stepping through weights highest-to-lowest.
        // Keep track of the original index to put back in order.
        let sorted = weights.enumerated().sorted { $0.element > $1.element }
        let sortedIndexes = sorted.map { $0.offset }
        let sortedWeights = sorted.map { $0.element }
        
        // Weights need to sum up to the area of the bounds.
        let sumWeights = weights.reduce(0, +)
        let areaRatio = bounds.width * bounds.height / sumWeights
        let weightedAreas = sortedWeights.map { $0 * areaRatio }
        
        // Get the sorted rects, and then return them to the original order given by the caller.
        let rects = squarify(areas: weightedAreas, areasInRow: [], bounds: bounds)
        let unsorted = rects.enumerated().sorted { sortedIndexes[$0.offset] < sortedIndexes[$1.offset] }.map { $0.element }
        return unsorted
    }
    
    private func squarify(areas: [CGFloat], areasInRow: [CGFloat], bounds: CGRect) -> [CGRect] {
        var minDimension: CGFloat
        var isWidth: Bool
        if bounds.size.width < bounds.size.height {
            isWidth = true
            minDimension = bounds.size.width
        } else {
            isWidth = false
            minDimension = bounds.size.height
        }
        
        guard let area = areas.first else {
            let sizes = finalizeSizes(areas: areasInRow, dimension: minDimension, isWidth: isWidth)
            return finalizeFrames(sizes: sizes, bounds: bounds, isWidth: isWidth)
        }
        
        var insertedAreas = areasInRow
        insertedAreas.append(area)
        
        // Does inserting this area make better (more square) ratios?
        if worstRatio(areas: areasInRow, dimension: minDimension) > worstRatio(areas: insertedAreas, dimension: minDimension) {
            var remainingAreas = areas
            remainingAreas.remove(at: 0)
            
            return squarify(areas: remainingAreas, areasInRow: insertedAreas, bounds: bounds)
        } else {
            let dimension = finalizeDimension(areas: areasInRow, dimension: minDimension, isWidth: isWidth)
            let sizes = finalizeSizes(areas: areasInRow, dimension: minDimension, isWidth: isWidth)
            var frames = finalizeFrames(sizes: sizes, bounds: bounds, isWidth: isWidth)
            
            var subBounds = bounds
            if isWidth {
                // filled width, cut out height
                subBounds.origin.y += dimension.height
                subBounds.size.height -= dimension.height
            } else {
                // filled height, cut out width
                subBounds.origin.x += dimension.width
                subBounds.size.width -= dimension.width
            }
            
            frames.append(contentsOf: squarify(areas: areas, areasInRow: [], bounds: subBounds))
            return frames
        }
    }
    
    private func worstRatio(areas: [CGFloat], dimension: CGFloat) -> CGFloat {
        guard let maxArea = areas.max(), let minArea = areas.min() else {
            return CGFloat.infinity
        }
        
        let sumAreas = areas.reduce(0, +)
        let sumAreasSquared = sumAreas * sumAreas
        let dimensionSquared = dimension * dimension
        
        return max((dimensionSquared * maxArea) / sumAreasSquared,
                   sumAreasSquared / (dimensionSquared * minArea))
    }
    
    private func finalizeDimension(areas: [CGFloat], dimension: CGFloat, isWidth: Bool) -> CGSize {
        let totalArea = areas.reduce(0, +)
        let otherDimension = totalArea / dimension
        
        return isWidth ? CGSize(width: dimension, height: otherDimension) : CGSize(width: otherDimension, height: dimension)
    }
    
    private func finalizeSizes(areas: [CGFloat], dimension: CGFloat, isWidth: Bool) -> [CGSize] {
        let totalRect = finalizeDimension(areas: areas, dimension: dimension, isWidth: isWidth)
        let totalArea = totalRect.width * totalRect.height
        
        return areas.map { isWidth ? CGSize(width: totalRect.width * $0 / totalArea, height: totalRect.height) : CGSize(width: totalRect.width, height: totalRect.height * $0 / totalArea) }
    }
    
    private func finalizeFrames(sizes: [CGSize], bounds: CGRect, isWidth: Bool) -> [CGRect] {
        var frames: [CGRect] = []
        
        if isWidth {
            var x = bounds.origin.x
            for size in sizes {
                frames.append(CGRect(x: x, y: bounds.origin.y, width: size.width, height: size.height))
                x += size.width
            }
        } else {
            var y = bounds.origin.y
            for size in sizes {
                frames.append(CGRect(x: bounds.origin.x, y: y, width: size.width, height: size.height))
                y += size.height
            }
        }
        
        return frames
    }
    
}
