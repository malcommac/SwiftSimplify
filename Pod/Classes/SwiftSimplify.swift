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

func equalsPoints<T>(_ pointA: T, pointB: T) -> Bool {
	if let pointA = pointA as? CGPoint, let pointB = pointB as? CGPoint {
		return (pointA.x == pointB.x && pointA.y == pointB.y)
	} else if let pointA = pointA as? CLLocationCoordinate2D, let pointB = pointB as? CLLocationCoordinate2D {
		return ( pointA.latitude == pointB.latitude && pointA.longitude == pointB.longitude )
	}
	return false
}

open class SwiftSimplify {

	/**
	Returns an array of simplified points
	
	- parameter points:      An array of points of (maybe CGPoint or CLLocationCoordinate2D points)
	- parameter tolerance:   Affects the amount of simplification (in the same metric as the point coordinates)
	- parameter highQuality: Excludes distance-based preprocessing step which leads to highest quality simplification but runs ~10-20 times slower.
	
	- returns: Returns an array of simplified points
	*/
	open class func simplify<T>(_ points: [T], tolerance: Float?, highQuality: Bool = false) -> [T] {
		if points.count == 2 {
			return points
		}
		// both algorithms combined for awesome performance
		let sqTolerance = (tolerance != nil ? tolerance! * tolerance! : 1.0)
		var result: [T] = (highQuality == true ? points : simplifyRadialDistance(points, tolerance: sqTolerance))
		result = simplifyDouglasPeucker(result, tolerance: sqTolerance)
		return result
	}
	
	fileprivate class func simplifyRadialDistance<T>(_ points: [T], tolerance: Float!) -> [T] {
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
		
		if equalsPoints(prevPoint, pointB: point) == false {
			newPoints.append(point)
		}
		
		return newPoints
	}
	
	fileprivate class func simplifyDouglasPeucker<T>(_ points: [T], tolerance: Float!) -> [T] {
		// simplification using Ramer-Douglas-Peucker algorithm
		let last: Int = points.count - 1
		var simplified: [T] = [points.first!]
		simplifyDPStep(points, first: 0, last: last, tolerance: tolerance, simplified: &simplified)
		simplified.append(points[last])
		return simplified
	}
	
	fileprivate class func simplifyDPStep<T>(_ points: [T], first: Int, last: Int, tolerance: Float, simplified: inout [T]) {
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
	
	fileprivate class func getSQSegDist<T>(point p: T, point1 p1: T, point2 p2: T) -> Float {
		// square distance from a point to a segment
		var point: CGPoint = CGPoint.zero
		var point1: CGPoint = CGPoint.zero
		var point2: CGPoint = CGPoint.zero
		
		if let p = p as? CGPoint, let p1 = p1 as? CGPoint, let p2 = p2 as? CGPoint {
			point = p
			point1 = p1
			point2 = p2
		} else if let p = p as? CLLocationCoordinate2D, let p1 = p1 as? CLLocationCoordinate2D, let p2 = p2 as? CLLocationCoordinate2D {
			point = CGPoint( x: CGFloat(p.latitude), y: CGFloat(p.longitude) )
			point1 = CGPoint( x: CGFloat(p1.latitude), y: CGFloat(p1.longitude) )
			point2 = CGPoint( x: CGFloat(p2.latitude), y: CGFloat(p2.longitude) )
		}
		var x = point1.x
		var y = point1.y
		var dx = point2.x - x
		var dy = point2.y - y
		
		if dx != 0 || dy != 0 {
			let t = ( (point.x - x) * dx + (point.y - y) * dy ) / ( (dx * dx) + (dy * dy) )
			if t > 1 {
				x = point2.x
				y = point2.y
			} else if t > 0 {
				x += dx * t
				y += dy * t
			}
		}
		
		dx = point.x - x
		dy = point.y - y
		
		return Float( (dx * dx) + (dy * dy) )
	}
	
	fileprivate class func getSqDist<T>(_ pointA: T, pointB: T) -> Float {
		// square distance between 2 points
		if let pointA = pointA as? CGPoint, let pointB = pointB as? CGPoint {
			let dx = pointA.x - pointB.x
			let dy = pointA.y - pointB.y
			return Float( (dx * dx) + (dy * dy) )
		} else if let pointA = pointA as? CLLocationCoordinate2D, let pointB = pointB as? CLLocationCoordinate2D {
			let dx = pointA.latitude - pointB.latitude
			let dy = pointA.longitude - pointB.longitude
			return Float ( (dx * dx) + (dy * dy) )
		} else {
			return 0.0
		}
	}
	
}
