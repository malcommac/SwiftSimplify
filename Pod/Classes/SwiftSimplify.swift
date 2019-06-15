//
// SwiftSimplify.swift
// Simplify
//
// Created by Daniele Margutti on 11/07/15.
// Copyright (c) 2015 Daniele Margutti. All rights reserved
//
// Web:		http://www.danielemargutti.com
// Mail:	me@danielemargutti.com
// Twitter: http://www.twitter.com/danielemargutti
// GitHub:	http://www.github.com/malcommac
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

import UIKit
import CoreLocation

public protocol SimplifyValue {
    
    var xValue: Double { get }
    var yValue: Double { get }
}

func equalsPoints<T: SimplifyValue>(lhs: T, rhs: T) -> Bool {
    return lhs.xValue == rhs.xValue && lhs.yValue == rhs.yValue
}

extension CGPoint: SimplifyValue {
    
    public var xValue: Double {
        return Double(x)
    }
    
    public var yValue: Double {
        return Double(y)
    }
}

extension CLLocationCoordinate2D: SimplifyValue {
    
    public var xValue: Double {
        return latitude
    }

    public var yValue: Double {
        return longitude
    }
}

open class SwiftSimplify {

	/**
	Returns an array of simplified points
	
	- parameter points:      An array of points of (maybe CGPoint or CLLocationCoordinate2D points)
	- parameter tolerance:   Affects the amount of simplification (in the same metric as the point coordinates)
	- parameter highQuality: Excludes distance-based preprocessing step which leads to highest quality simplification but runs ~10-20 times slower.
	
	- returns: Returns an array of simplified points
	*/
    open class func simplify<T:SimplifyValue>(_ points: [T], tolerance: Float?, highQuality: Bool = false) -> [T] {
		guard points.count > 1 else { return points }
		// both algorithms combined for awesome performance
		let sqTolerance = (tolerance != nil ? tolerance! * tolerance! : 1.0)
		var result: [T] = (highQuality == true ? points : simplifyRadialDistance(points, tolerance: sqTolerance))
		result = simplifyDouglasPeucker(result, tolerance: sqTolerance)
		return result
	}
    
    /**
     Creates a simplified path
     
     - parameter path:        CGPath to be simplified
     - parameter tolerance:   Affects the amount of simplification (in the same metric as the point coordinates)
     - parameter smooth:      Whether the path should be smoothed post simplification
     - parameter highQuality: Excludes distance-based preprocessing step which leads to highest quality simplification but runs ~10-20 times slower.
     
     - returns: Simplified path
     */
    public class func simplifyPath(path: CGPath, tolerance: Float?, smooth: Bool = false, highQuality: Bool = false)->CGPath {
        
        let points = simplify(path.points(), tolerance: tolerance, highQuality: highQuality)
        let simplifiedPath = CGPathCreateMutable()
        
        for i in 0 ..< (points.count-1) {
            let p1 = points[i]
            let p2 = points[i+1]
            CGPathMoveToPoint(simplifiedPath, nil, p1.x, p1.y)
            CGPathAddLineToPoint(simplifiedPath, nil, p2.x, p2.y)
        }
        
        return smooth ? smoothPath(simplifiedPath) : simplifiedPath
    }

	
    fileprivate class func simplifyRadialDistance<T:SimplifyValue>(_ points: [T], tolerance: Float!) -> [T] {
		var prevPoint: T = points.first!
		var newPoints: [T] = [prevPoint]
		var point: T = points[1]
		
		for idx in 1 ..< points.count {
			point = points[idx]
			let distance = getSqDist(point, pointB: prevPoint)
			if distance > tolerance! {
				newPoints.append(point)
				prevPoint = point
			}
		}
		
        if !equalsPoints(lhs: prevPoint, rhs: point) {
            newPoints.append(point)
        }
		
		return newPoints
	}
	
    fileprivate class func simplifyDouglasPeucker<T:SimplifyValue>(_ points: [T], tolerance: Float!) -> [T] {
        guard points.count > 1 else { return [] }
        guard let first = points.first else { return [] }

		// simplification using Ramer-Douglas-Peucker algorithm
		let last: Int = points.count - 1
		var simplified: [T] = [first]
		simplifyDPStep(points, first: 0, last: last, tolerance: tolerance, simplified: &simplified)
		simplified.append(points[last])
		return simplified
	}
	
    fileprivate class func simplifyDPStep<T:SimplifyValue>(_ points: [T], first: Int, last: Int, tolerance: Float, simplified: inout [T]) {
        guard last > first else { return }

		var maxSqDistance = tolerance
		var index = 0
		
		for i in first + 1 ..< last {
			let sqDist = getSQSegDist(point: points[i], point1: points[first], point2: points[last])
			if sqDist > maxSqDistance {
				index = i
				maxSqDistance = sqDist
			}
		}
		
		if maxSqDistance > tolerance {
			if index - first > 1 {
				simplifyDPStep(points, first: first, last: index, tolerance: tolerance, simplified: &simplified)
			}
			simplified.append(points[index])
			if last - index > 1 {
				simplifyDPStep(points, first: index, last: last, tolerance: tolerance, simplified: &simplified)
			}
		}
	}
	
    // square distance from a point to a segment
    fileprivate class func getSQSegDist<T:SimplifyValue>(point p: T, point1 p1: T, point2 p2: T) -> Float {
        
		var x = p1.xValue
		var y = p1.yValue
		var dx = p2.xValue - x
		var dy = p2.yValue - y
		
		if dx != 0 || dy != 0 {
			let t = ( (p.xValue - x) * dx + (p.yValue - y) * dy ) / ( (dx * dx) + (dy * dy) )
			if t > 1 {
				x = p2.xValue
				y = p2.yValue
			} else if t > 0 {
				x += dx * t
				y += dy * t
			}
		}
		
		dx = p.xValue - x
		dy = p.yValue - y
		
		return Float( (dx * dx) + (dy * dy) )
	}

    
    /// Calculate square distance
    ///
    /// - Parameters:
    ///   - pointA: x point
    ///   - pointB: y point
    /// - Returns: square distance between 2 points
    fileprivate class func getSqDist<T:SimplifyValue>(_ pointA: T, pointB: T) -> Float {
        let dx = pointA.xValue - pointB.xValue
        let dy = pointA.yValue - pointB.yValue
        return Float((dx * dx) + (dy * dy))
	}
    
    private class func smoothPath(path: CGPath)->CGPath {
        let points = path.points()
        
        let smoothedPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(smoothedPath, nil, points[0].x, points[0].y)
        var i = 1
        while i<points.count-3 {
            let end = CGPoint(x: (points[i+1].x + points[i+3].x)/2.0, y: (points[i+1].y + points[i+3].y)/2)
            CGPathAddCurveToPoint(smoothedPath, nil, points[i].x, points[i].y, points[i+1].x, points[i+1].y, end.x, end.y)
            i+=3
        }
        
        if i == points.count-3 {
            CGPathAddCurveToPoint(smoothedPath, nil, points[i].x, points[i].y, points[i+1].x, points[i+1].y, points[i+2].x, points[i+2].y)
        } else if i == points.count-2{
            CGPathAddQuadCurveToPoint(smoothedPath, nil, points[i].x, points[i].y, points.last!.x, points.last!.y)
        } else {
            CGPathAddLineToPoint(smoothedPath, nil, points[i].x, points[i].y)
        }
        
        return smoothedPath
    }
    
}


public extension CGPath {
    
    private func forEachElement(@noescape body: @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutablePointer<Void>, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, Body.self)
            body(element.memory)
        }
        let unsafeBody = unsafeBitCast(body, UnsafeMutablePointer<Void>.self)
        CGPathApply(self, unsafeBody, callback)
    }
    
    public func points()->[CGPoint] {
        var points = [CGPoint]()
        forEachElement { element in
            switch (element.type) {
            case CGPathElementType.MoveToPoint:
                points.append(element.points[0])
            case .AddLineToPoint:
                points.append(element.points[0])
            case .AddQuadCurveToPoint:
                points.append(element.points[0])
                points.append(element.points[1])
            case .AddCurveToPoint:
                points.append(element.points[0])
                points.append(element.points[1])
                points.append(element.points[2])
            case .CloseSubpath: break
            }
        }
        return points
    }
}
