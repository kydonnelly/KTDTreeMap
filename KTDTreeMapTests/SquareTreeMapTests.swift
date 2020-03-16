//
//  SquareTreeMapTests.swift
//  KTDTreeMap
//
//  Created by Kyle Donnelly on 3/15/20.
//

import XCTest
@testable import KTDTreeMap

class SquareTreeMapTests : XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_rects_good_simpleSorted() {
        // This is the example used in https://www.win.tue.nl/~vanwijk/stm.pdf
        // 'bounds' is scaled up to avoid precision comparison issues
        
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let weights: [CGFloat] = [6, 6, 4, 3, 2, 2, 1]
        let bounds = CGRect(x: 0, y: 0, width: 630, height: 420)
        
        // Test
        let rects = generator.rects(weights: weights, bounds: bounds)
        
        // Verify
        let expectedOutput = [CGRect(x: 0, y: 0, width: 315, height: 210),
                              CGRect(x: 0, y: 210, width: 315, height: 210),
                              CGRect(x: 315, y: 0, width: 180, height: 245),
                              CGRect(x: 495, y: 0, width: 135, height: 245),
                              CGRect(x: 315, y: 245, width: 126, height: 175),
                              CGRect(x: 441, y: 245, width: 126, height: 175),
                              CGRect(x: 567, y: 245, width: 63, height: 175)]
        XCTAssertEqual(rects, expectedOutput)
    }

    func test_rects_good_simpleUnsorted() {
        // This is the example used in https://www.win.tue.nl/~vanwijk/stm.pdf
        // 'bounds' is scaled up to avoid precision comparison issues
        
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let weights: [CGFloat] = [1, 3, 2, 6, 4, 2, 6]
        let bounds = CGRect(x: 0, y: 0, width: 630, height: 420)
        
        // Test
        let rects = generator.rects(weights: weights, bounds: bounds)
        
        // Verify
        let expectedOutput = [CGRect(x: 567, y: 245, width: 63, height: 175),
                              CGRect(x: 495, y: 0, width: 135, height: 245),
                              CGRect(x: 315, y: 245, width: 126, height: 175),
                              CGRect(x: 0, y: 0, width: 315, height: 210),
                              CGRect(x: 315, y: 0, width: 180, height: 245),
                              CGRect(x: 441, y: 245, width: 126, height: 175),
                              CGRect(x: 0, y: 210, width: 315, height: 210)]
        XCTAssertEqual(rects, expectedOutput)
    }
    
    func test_worstRatio_bad_empty() {
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let areas: [CGFloat] = []
        let dimension: CGFloat = 3.0
        
        // Test
        let ratio = generator.worstRatio(areas: areas, dimension: dimension)
        
        // Verify
        XCTAssertEqual(CGFloat.infinity, ratio)
    }
    
    func test_worstRatio_bad_zeroDimension() {
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let areas: [CGFloat] = [1, 2, 3]
        let dimension = CGFloat.zero
        
        // Test
        let ratio = generator.worstRatio(areas: areas, dimension: dimension)
        
        // Verify
        XCTAssertEqual(CGFloat.infinity, ratio)
    }
    
    func test_worstRatio_bad_negativeDimension() {
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let areas: [CGFloat] = [1, 2, 3]
        let dimension: CGFloat = -3.0
        
        // Test
        let ratio = generator.worstRatio(areas: areas, dimension: dimension)
        
        // Verify
        XCTAssertEqual(CGFloat.infinity, ratio)
    }

    func test_worstRatio_good_singleElement() {
        // This is the example used in https://www.win.tue.nl/~vanwijk/stm.pdf
        
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let areas: [CGFloat] = [6]
        let dimension: CGFloat = 4.0
        
        // Test
        let ratio = generator.worstRatio(areas: areas, dimension: dimension)
        
        // Verify
        let expectedOutput: CGFloat = 8.0 / 3
        XCTAssertEqual(expectedOutput, ratio)
    }

    func test_worstRatio_good_equalElements() {
        // This is the example used in https://www.win.tue.nl/~vanwijk/stm.pdf
        
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let areas: [CGFloat] = [6, 6]
        let dimension: CGFloat = 4.0
        
        // Test
        let ratio = generator.worstRatio(areas: areas, dimension: dimension)
        
        // Verify
        let expectedOutput: CGFloat = 3.0 / 2
        XCTAssertEqual(expectedOutput, ratio)
    }

    func test_worstRatio_good_differentElements() {
        // This is the example used in https://www.win.tue.nl/~vanwijk/stm.pdf
        
        // Setup
        let generator = SquareTreeMapLayoutGenerator()
        let areas: [CGFloat] = [6, 6, 4]
        let dimension: CGFloat = 4.0
        
        // Test
        let ratio = generator.worstRatio(areas: areas, dimension: dimension)
        
        // Verify
        let expectedOutput: CGFloat = 4.0 / 1
        XCTAssertEqual(expectedOutput, ratio)
    }

}
