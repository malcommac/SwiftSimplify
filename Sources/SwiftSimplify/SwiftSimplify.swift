//
// SwiftSimplify.swift
// Simplify
//
// Created by Daniele Margutti on 28/06/2019.
// Copyright (c) 2019 Daniele Margutti. All rights reserved
// Original work by https://mourner.github.io/simplify-js/
//
// Web:     http://www.danielemargutti.com
// Mail:    hello@danielemargutti.com
// Twitter: http://www.twitter.com/danielemargutti
// GitHub:  http://www.github.com/malcommac
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

// MARK: - SwiftSimplify

public struct SwiftSimplify {
    
    public static func simplify<P: Point2DRepresentable>(_ points: [P], tolerance: Float?, highestQuality: Bool = false) -> [P] {
        guard points.count > 1 else {
            return points
        }
        
        let sqTolerance = tolerance != nil ? (tolerance! * tolerance!): 1.0
        var result = highestQuality ? points : simplifyRadialDistance(points, tolerance: sqTolerance)
        result = simplifyDouglasPeucker(result, sqTolerance: sqTolerance)
        
        return result
    }
    
    private static func simplifyRadialDistance<P: Point2DRepresentable>(_ points: [P], tolerance: Float) -> [P] {
        guard points.count > 2 else {
            return points
        }
        
        var prevPoint = points.first!
        var newPoints = [prevPoint]
        var currentPoint: P!
        
        for i in 1..<points.count {
            currentPoint = points[i]
            if currentPoint.distanceFrom(prevPoint) > tolerance {
                newPoints.append(currentPoint)
                prevPoint = currentPoint
            }
        }
        
        if prevPoint.equalsTo(currentPoint) == false {
            newPoints.append(currentPoint)
        }
        
        return newPoints
    }
    
    private static func simplifyDPStep<P: Point2DRepresentable>(_ points: [P], first: Int, last: Int, sqTolerance: Float, simplified: inout [P]) {
        
        guard last > first else {
            return
        }
        var maxSqDistance = sqTolerance
        var index = 0
        
        for currentIndex in first+1..<last {
            let sqDistance = points[currentIndex].distanceToSegment(points[first], points[last])
            if sqDistance > maxSqDistance {
                maxSqDistance = sqDistance
                index = currentIndex
            }
        }
        
        if maxSqDistance > sqTolerance {
            if (index - first) > 1 {
                simplifyDPStep(points, first: first, last: index, sqTolerance: sqTolerance, simplified: &simplified)
            }
            simplified.append(points[index])
            if (last - index) > 1 {
                simplifyDPStep(points, first: index, last: last, sqTolerance: sqTolerance, simplified: &simplified)
            }
        }
    }
    
    private static func simplifyDouglasPeucker<P: Point2DRepresentable>(_ points: [P], sqTolerance: Float) -> [P] {
        guard points.count > 1 else {
            return []
        }
        
        let last = (points.count - 1)
        var simplied = [points.first!]
        simplifyDPStep(points, first: 0, last: last, sqTolerance: sqTolerance, simplified: &simplied)
        simplied.append(points.last!)
        
        return simplied
    }
    
}

// MARK: - Array Extension

public extension Array where Element: Point2DRepresentable {
    
    func simplify(tolerance: Float? = nil, highestQuality: Bool = true) -> [Element] {
        return SwiftSimplify.simplify(self, tolerance: tolerance, highestQuality: highestQuality)
    }
    
}
