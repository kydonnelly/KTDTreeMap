//
//  SpiralTreeMapLayoutGenerator.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 4/5/20.
//

import Foundation

internal enum Direction {
    case left, right, up, down
    
    var isSlice: Bool {
        switch self {
        case .left, .right:
            return true
        case .up, .down:
            return false
        }
    }
    
    var nextDirection: Direction {
        switch self {
        case .right: return .down
        case .down: return .left
        case .left: return .up
        case .up: return .right
        }
    }
}

internal class SpiralTreeMapLayoutGenerator : TreeMapLayoutGenerator {
    
    func minWeightRatio(minSize: CGSize, fullSize: CGSize) -> CGFloat {
        let boundsArea = fullSize.width * fullSize.height
        
        if boundsArea > 0.0 {
            return minSize.width * minSize.height / boundsArea
        } else {
            return 0.0
        }
    }
    
    func rects(weights: [CGFloat], bounds: CGRect, minSize: CGSize) -> [CGRect] {
        // This layout looks best when stepping through weights lowest to highest.
        // Keep track of the original index to put back in order.
        let sorted = weights.enumerated().sorted { $0.element < $1.element }
        let sortedIndexes = sorted.map { $0.offset }
        let sortedWeights = sorted.map { $0.element }
        
        // Weights need to sum up to the area of the bounds.
        let sumWeights = weights.reduce(0, +)
        let areaRatio = bounds.size.width * bounds.size.height / sumWeights
        let weightedAreas = sortedWeights.map { $0 * areaRatio }
        
        // Get the sorted rects, and then return them to the original order given by the caller.
//        let rects = spiral(areas: weightedAreas, bounds: bounds, minSize: minSize)
        var startBounds = bounds
        do {
            let startDirection: Direction = bounds.shouldSlice ? .right : .down
            let (indexes, rects) = try self.buildRuns(areas: weightedAreas, currentBounds: bounds, availableBounds: &startBounds, minSize: minSize, direction: startDirection, isFlexible: true)
            let unsorted = rects.enumerated().sorted { sortedIndexes[indexes[$0.offset]] < sortedIndexes[indexes[$1.offset]] }.map { $0.element }
            return unsorted
        } catch {
            return []
        }
    }
    
//    func spiral(areas: [CGFloat], bounds: CGRect, minSize: CGSize) -> [CGRect] {
//        var rects: [CGRect] = []
//
//        var isSubdividing = false
//        var isSlicing = bounds.shouldSlice
//
//        var currentBounds: CGRect = bounds
//        var availableBounds: CGRect = bounds
//        var remainingAreas: [CGFloat] = areas
//        while !remainingAreas.isEmpty {
//            let (subRange, dimension) = self.spiralFrames(areas: remainingAreas, bounds: currentBounds, isSlicing: isSlicing, isFlexible: !isSubdividing, minSize: minSize)
//
//            guard !subRange.isEmpty else {
//                preconditionFailure("Getting stuck in spiral layout loop")
//                break
//            }
//
//            let frames = remainingAreas[subRange].finalizeFrames(bounds: currentBounds, dimension: dimension, isSlicing: isSlicing)
//            remainingAreas.removeSubrange(subRange)
//            rects.append(contentsOf: frames)
//
//            let union = frames.union
//
//            isSubdividing = dimension < (isSlicing ? currentBounds.size.width : currentBounds.size.height)
//
//            if isSubdividing {
//                if isSlicing {
//                    // Didn't quite fill width. Cut out a column from available bounds including leftover space
//                    currentBounds = CGRect(x: union.maxX, y: availableBounds.minY, width: availableBounds.maxX - union.maxX, height: availableBounds.size.height)
//                    availableBounds.slice(subrect: union)
//                } else {
//                    // Didn't quite fill height. Cut out a row from available bounds including leftover space
//                    currentBounds = CGRect(x: availableBounds.minX, y: union.maxY, width: availableBounds.size.width, height: availableBounds.maxY - union.maxY)
//                    availableBounds.dice(subrect: union)
//                }
//
//                isSlicing = !isSlicing
//            } else {
//                if isSlicing {
//                    // filled width, cut out height
//                    availableBounds.slice(subrect: union)
//                } else {
//                    // filled height, cut out width
//                    availableBounds.dice(subrect: union)
//                }
//
//                currentBounds = availableBounds
//                isSlicing = currentBounds.shouldSlice
//            }
//        }
//
//        return rects
//    }
//
//    // 1, 2, 3, 2, 1, 2, 5, 7, 8, 4, 6
//    func spiralFrames(areas: [CGFloat], bounds: CGRect, isSlicing: Bool, isFlexible: Bool, minSize: CGSize) -> (ClosedRange<Int>, CGFloat) {
//        var startIndex: Int? = nil
//        var minWidthSum: CGFloat = 0
//        var minHeightSum: CGFloat = 0
//        for i in 0..<areas.count {
//            let area = areas[i]
//
//            if isSlicing {
//                let minWidthDimension = minSize.width
//                let minHeightDimension = area / minSize.width
//
//                let withThisMinWidth = minWidthDimension + minWidthSum
//                let withThisMinHeight = minHeightDimension + minHeightSum
//
//                if withThisMinWidth <= bounds.size.width - minSize.width && withThisMinHeight <= bounds.size.width {
//                    // Can add this area while leaving open minSize.width if needed, plus others
//                    startIndex = startIndex ?? i
//                    minWidthSum += minWidthDimension
//                    minHeightSum += minHeightDimension
//                } else if withThisMinWidth <= bounds.size.width && withThisMinHeight > bounds.size.width {
//                    // Can fit this area, but no more
//                    startIndex = startIndex ?? i
//                    return (startIndex!...i, bounds.size.width)
//                } else if startIndex != nil {
//                    // Maybe we could have fit this, but there would be leftover space below minSize.width.
//                    // Or maybe just can't fit this. Either way leave earlier areas and sub-divide bounds.
//                    let finalWidth = min(bounds.size.width - minSize.width, minHeightSum)
//                    return (startIndex!...i-1, finalWidth)
//                } else {
//                    // continue looking for a startIndex that works
//                }
//            } else {
//                let minWidthDimension = area / minSize.height
//                let minHeightDimension = minSize.height
//
//                let withThisMinWidth = minWidthDimension + minWidthSum
//                let withThisMinHeight = minHeightDimension + minHeightSum
//
//                if withThisMinHeight <= bounds.size.height - minSize.height && withThisMinWidth <= bounds.size.height {
//                    // Can add this area while leaving open minSize.height if needed, plus others
//                    startIndex = startIndex ?? i
//                    minWidthSum += minWidthDimension
//                    minHeightSum += minHeightDimension
//                } else if withThisMinHeight <= bounds.size.height && withThisMinWidth > bounds.size.height {
//                    // Ready to fill this entire area
//                    startIndex = startIndex ?? i
//                    return (startIndex!...i, bounds.size.height)
//                } else if startIndex != nil {
//                    // Maybe we could have fit this, but there would be leftover space below minSize.height.
//                    // Or maybe just can't fit this. Either way leave earlier areas and sub-divide bounds.
//                    let finalHeight = min(bounds.size.height - minSize.height, minWidthSum)
//                    return (startIndex!...i-1, finalHeight)
//                } else {
//                    // continue looking for a startIndex that works
//                }
//            }
//        }
//
//        return (0...areas.count-1, isSlicing ? bounds.size.width : bounds.size.height)
//    }
    
    enum RunError : Error {
        case leftoverSpace
        case impossibleRun
    }
    
    enum InsertAction {
        case insertAndContinue
        case insertAndClose
        case tryLarger
        case cannotInsert
    }
    
    func buildRuns(areas: [CGFloat], currentBounds: CGRect, availableBounds: inout CGRect, minSize: CGSize, direction: Direction, isFlexible: Bool, isRetrying: Bool = false) throws -> ([Int], [CGRect]) {
        guard areas.count > 0 else {
//            if currentBounds.size == .zero {
                return ([], [])
//            } else {
//                throw RunError.leftoverSpace
//            }
        }
        
        let isSlicing = direction.isSlice
        
        let (run, dimension) = isSlicing ?
                               sliceRun(areas: areas, bounds: currentBounds.size, isFlexible: isFlexible, minSize: minSize) :
                               diceRun(areas: areas, bounds: currentBounds.size, isFlexible: isFlexible, minSize: minSize)
        
        guard let initialRun = run, initialRun.count > 0 else {
            if isFlexible && !isRetrying {
                return try self.buildRuns(areas: areas, currentBounds: currentBounds, availableBounds: &availableBounds, minSize: minSize, direction: direction.nextDirection, isFlexible: true, isRetrying: true)
            } else {
                throw RunError.impossibleRun
            }
        }
        
        let isFullDimension = (dimension == (isSlicing ? currentBounds.size.width : currentBounds.size.height))
        
        let runAreas: [CGFloat] = initialRun.map { areas[$0] }
        let frames = runAreas.finalizeFrames(bounds: currentBounds, dimension: dimension, direction: direction)
        let union = frames.union
        
        var allRuns: [Int] = initialRun
        var allFrames: [CGRect] = frames
        let remainingAreas = areas.enumerated().filter { !initialRun.contains($0.offset) }.map { $0.element }
        
        if isFullDimension {
            // single run filled all the way across bounds
            if isSlicing {
                // filled width, cut out height
                availableBounds.slice(subrect: union)
            } else {
                // filled height, cut out width
                availableBounds.dice(subrect: union)
            }
            
            let (recursiveRuns, recursiveFrames) = try self.buildRuns(areas: remainingAreas, currentBounds: availableBounds, availableBounds: &availableBounds, minSize: minSize, direction: direction.nextDirection, isFlexible: true)
            
            allRuns.append(contentsOf: recursiveRuns)
            allFrames.append(contentsOf: recursiveFrames)
        } else {
            // this run did not go all the way across the bounds
            var subBounds: CGRect
            if isSlicing {
                // Didn't quite fill width. Cut out a column from available bounds including leftover space
                subBounds = CGRect(x: union.minX == currentBounds.minX ? union.maxX : currentBounds.minX,
                                   y: availableBounds.minY,
                                   width: currentBounds.width - union.width,
                                   height: availableBounds.size.height)
                availableBounds.slice(subrect: union)
            } else {
                // Didn't quite fill height. Cut out a row from available bounds including leftover space
                subBounds = CGRect(x: availableBounds.minX,
                                   y: union.minY == currentBounds.minY ? union.maxY : currentBounds.minY,
                                   width: availableBounds.size.width,
                                   height: currentBounds.height - union.height)
                availableBounds.dice(subrect: union)
            }
            
            let (recursiveRuns, recursiveFrames) = try self.buildRuns(areas: remainingAreas, currentBounds: subBounds, availableBounds: &availableBounds, minSize: minSize, direction: direction.nextDirection, isFlexible: false)
            
            allRuns.append(contentsOf: recursiveRuns)
            allFrames.append(contentsOf: recursiveFrames)
        }
        
        return (allRuns, allFrames)
    }
    
    func sliceRun(areas: [CGFloat], bounds: CGSize, isFlexible: Bool, minSize: CGSize) -> ([Int]?, CGFloat) {
        guard let firstArea = areas.first else {
            return (nil, -1)
        }
        
        var startIndex: Int = 0
        var minWidthSize = bounds
        var minHeightSize = bounds
        
        if isFlexible {
            minWidthSize.height = firstArea / minSize.width
            minHeightSize.height = minSize.height
        } else {
            guard let index = areas.firstIndex(where: { $0 >= minWidthSize.height * minSize.width }) else {
                return (nil, -1)
            }
            startIndex = index
        }
        
        var insertedIndexes: [Int] = []
        for i in startIndex..<areas.count {
            let area = areas[i]
            let action = self.sliceAction(area: area, minWidthSize: minWidthSize, minHeightSize: minHeightSize, minSize: minSize)
            
            switch action {
            case .insertAndContinue:
                minWidthSize.width -= area / minWidthSize.height
                minHeightSize.width -= area / minHeightSize.height
                insertedIndexes.append(i)
            case .insertAndClose:
                insertedIndexes.append(i)
                return (insertedIndexes, bounds.width)
            case .tryLarger:
                if let nextLargest = areas.firstIndex(where: { area -> Bool in
                    minWidthSize.width < area / minWidthSize.height && minHeightSize.width >= area / minHeightSize.height
                }) {
                    insertedIndexes.append(nextLargest)
                    return (insertedIndexes, bounds.width)
                } else {
                    let insertWidth = bounds.width - max(minSize.width, minHeightSize.width)
                    return (insertedIndexes, insertWidth)
                }
            case .cannotInsert:
                let insertWidth = bounds.width - max(minSize.width, minHeightSize.width)
                return (insertedIndexes, insertWidth)
            }
        }
        
        // Should never get here
        let insertWidth = bounds.width - max(minSize.width, minHeightSize.width)
        return (insertedIndexes, insertWidth)
    }
    
    func diceRun(areas: [CGFloat], bounds: CGSize, isFlexible: Bool, minSize: CGSize) -> ([Int]?, CGFloat) {
        guard let firstArea = areas.first else {
            return (nil, -1)
        }
        
        var startIndex: Int = 0
        var minWidthSize: CGSize = bounds
        var minHeightSize: CGSize = bounds
        
        if isFlexible {
            minWidthSize.width = minSize.width
            minHeightSize.width = firstArea / minSize.height
        } else {
            guard let index = areas.firstIndex(where: { $0 >= minWidthSize.width * minSize.height }) else {
                return (nil, -1)
            }
            startIndex = index
        }
        
        var insertedIndexes: [Int] = []
        for i in startIndex..<areas.count {
            let area = areas[i]
            let action = self.diceAction(area: area, minWidthSize: minWidthSize, minHeightSize: minHeightSize, minSize: minSize)
            
            switch action {
            case .insertAndContinue:
                minWidthSize.height -= area / minWidthSize.width
                minHeightSize.height -=  area / minHeightSize.width
                insertedIndexes.append(i)
            case .insertAndClose:
                insertedIndexes.append(i)
                return (insertedIndexes, bounds.height)
            case .tryLarger:
                if let nextLargest = areas.firstIndex(where: { area -> Bool in
                    minHeightSize.height < area / minHeightSize.width && minWidthSize.height >= area / minWidthSize.width
                }) {
                    insertedIndexes.append(nextLargest)
                    return (insertedIndexes, bounds.height)
                } else {
                    let finalHeight = bounds.height - max(minSize.height, minWidthSize.height)
                    return (insertedIndexes, finalHeight)
                }
            case .cannotInsert:
                let finalHeight = bounds.height - max(minSize.height, minWidthSize.height)
                return (insertedIndexes, finalHeight)
            }
        }
        
        // Should never get here
        let finalHeight = bounds.height - max(minSize.height, minWidthSize.height)
        return (insertedIndexes, finalHeight)
    }
    
    func sliceAction(area: CGFloat, minWidthSize: CGSize, minHeightSize: CGSize, minSize: CGSize) -> InsertAction {
        let minWidthDimension = area / minWidthSize.height
        let minHeightDimension = area / minHeightSize.height
        
        let remainingMinWidth = minWidthSize.width - minWidthDimension
        let remainingMinHeight = minHeightSize.width - minHeightDimension
        
        if remainingMinWidth >= minSize.width && remainingMinHeight >= 0 {
            // Can add this area while leaving open minSize.width if needed, plus others
            return .insertAndContinue
        } else if remainingMinWidth >= 0 && remainingMinHeight <= 0 {
            // Can fit this area, but no more
            return .insertAndClose
        } else if remainingMinWidth >= 0 {
            // Can't fill this area because there would be leftover room that is unusable.
            // But maybe there is another larger area that could fit it
            return .tryLarger
        } else if remainingMinWidth < 0 {
            // Too big to fit this area at all
            return .cannotInsert
        }
        
        return .cannotInsert
    }
    
    func diceAction(area: CGFloat, minWidthSize: CGSize, minHeightSize: CGSize, minSize: CGSize) -> InsertAction {
        let minHeightDimension = area / minHeightSize.width
        let minWidthDimension = area / minWidthSize.width
        
        let remainingMinHeight = minHeightSize.height - minHeightDimension
        let remainingMinWidth = minWidthSize.height - minWidthDimension
        
        if remainingMinHeight >= minSize.height && remainingMinWidth >= 0 {
            // Can add this area while leaving open minSize.height if needed, plus others
            return .insertAndContinue
        } else if remainingMinHeight >= 0 && remainingMinWidth <= 0 {
            // Can fit this area, but no more
            return .insertAndClose
        } else if remainingMinHeight >= 0 {
            // Can't fill this area because there would be leftover room that is unusable.
            // But maybe there is another larger area that could fit it
            return .tryLarger
        } else if remainingMinHeight < 0 {
            // Too big to fit this area at all
            return .cannotInsert
        }
        
        return .cannotInsert
    }
    
}

extension Collection where Element == CGFloat {
    
    func finalizeFrames(bounds: CGRect, dimension: CGFloat, direction: Direction) -> [CGRect] {
        let area = self.reduce(0, +)
        let step = dimension / area
        let fixed = area / dimension
        
        var frames: [CGRect] = []
        switch direction {
        case .right:
            var x = bounds.minX
            let y = bounds.minY
            for element in self {
                let width = element * step
                frames.append(CGRect(x: x, y: y, width: width, height: fixed))
                x += width
            }
        case .left:
            var x = bounds.maxX
            let y = bounds.maxY - fixed
            for element in self {
                let width = element * step
                x -= width
                frames.append(CGRect(x: x, y: y, width: width, height: fixed))
            }
        case .down:
            let x = bounds.maxX - fixed
            var y = bounds.minY
            for element in self {
                let height = element * step
                frames.append(CGRect(x: x, y: y, width: fixed, height: height))
                y += height
            }
        case .up:
            let x = bounds.minX
            var y = bounds.maxY
            for element in self {
                let height = element * step
                y -= height
                frames.append(CGRect(x: x, y: y, width: fixed, height: height))
            }
        }
        
        return frames
    }
    
}

extension Collection where Element == CGRect {
    
    var union: CGRect {
        var union = self.first ?? CGRect.null
        let remaining = self.dropFirst()
        
        for element in remaining {
            union = union.union(element)
        }
        
        return union
    }
    
}

extension CGRect {
    
    /// As opposed to shouldDice
    fileprivate var shouldSlice: Bool {
        return self.size.width < self.size.height
    }
    
    fileprivate mutating func slice(subrect: CGRect) {
        self.size.height -= subrect.size.height
        if subrect.minY == self.minY {
            self.origin.y += subrect.size.height
        }
    }
    
    fileprivate mutating func dice(subrect: CGRect) {
        self.size.width -= subrect.size.width
        if subrect.minX == self.minX {
            self.origin.x += subrect.size.width
        }
    }
    
    fileprivate func slicing(subrect: CGRect) -> CGRect {
        return CGRect(x: subrect.minX,
                      y: self.minY + (subrect.minY == self.minY ? subrect.size.height : 0),
                      width: subrect.width,
                      height: self.size.height - subrect.size.height)
    }
    
    fileprivate func dicing(subrect: CGRect) -> CGRect {
        return CGRect(x: self.minX + (subrect.minX == self.minX ? subrect.size.width : 0),
                      y: self.minY,
                      width: self.size.width - subrect.size.width,
                      height: self.size.height)
    }
    
}
