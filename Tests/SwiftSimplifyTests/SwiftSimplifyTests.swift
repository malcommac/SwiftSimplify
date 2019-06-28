//
//  SwiftSimplifyTests.swift
//  SwiftSimplify
//
//  Created by Daniele Margutti on 28/06/2019.
//  Copyright © 2019 SwiftSimplify. All rights reserved.
//

import Foundation
import XCTest
import SwiftSimplify

class SwiftSimplifyTests: XCTestCase {
   
    /// The following test ensure simplification works as expected.
    /// The original version was in JS and can be found:
    /// https://mourner.github.io/simplify-js/
    func testSimplifyPoints() {
        let url = Bundle(for: SwiftSimplifyTests.self).path(forResource: "SimplifyTestPoints", ofType: "json")!
        guard let tests = NSArray(contentsOfFile: url) else {
            return
        }
        
        let pointsConversionMapFunction: ((Any) -> CGPoint?) = { point in
            guard let point = point as? NSArray else {
                return nil
            }
            return CGPoint(x: CGFloat((point[0] as! NSNumber).floatValue),
                           y: CGFloat((point[1] as! NSNumber).floatValue))
        }
        
        for test in tests {
            guard let test = test as? NSDictionary else {
                continue
            }
            let points = (test["points"] as! NSArray).compactMap(pointsConversionMapFunction)
            let simplifiedPoints = (test["simplified"] as! NSArray).compactMap(pointsConversionMapFunction)
            let tolerance = (test["tolerance"] as! NSNumber).floatValue
            executeTestForPoints(points, simplified: simplifiedPoints, tolerance: tolerance)
        }
        
    }
    
    func executeTestForPoints(_ initialPoints: [CGPoint], simplified: [CGPoint], tolerance: Float) {
        let algorithmResult = SwiftSimplify.simplify(initialPoints, tolerance: tolerance)
        guard algorithmResult.count == simplified.count else {
            XCTFail("Failed to simplify; algorithm return \(algorithmResult.count) points, expected \(simplified.count) points")
            return
        }
        
        for i in 0..<algorithmResult.count {
            guard algorithmResult[i].equalsTo(simplified[i]) else {
                XCTFail("Failed to simplify; expected point \(algorithmResult[i]), expected \(simplified[i])")
                return
            }
        }
    }
    
    static var allTests = [
        ("testSimplifyPoints", testSimplifyPoints),
    ]
}
