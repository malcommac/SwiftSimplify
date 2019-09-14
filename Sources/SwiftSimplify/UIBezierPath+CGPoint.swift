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

import UIKit

// MARK: - UIBezierPath Extension

public extension UIBezierPath {
    
    /// Create an UIBezierPath instance from a sequence of points which is drawn smoothly.
    ///
    /// - Parameter points: points of the path.
    /// - Returns: smoothed UIBezierPath.
    static func smoothFromPoints<P: Point2DRepresentable>(_ points: [P]) -> UIBezierPath {
        let path = UIBezierPath()
        guard points.count > 1 else {
            return path
        }
        
        var prevPoint: CGPoint?
        for (index, point) in points.enumerated() {
            if index == 0 {
                path.move(to: point.cgPoint)
            } else {
                if index == 1 {
                    path.addLine(to: point.cgPoint)
                }
                if let prevPoint = prevPoint {
                    let midPoint = prevPoint.midPointForPointsTo(point.cgPoint)
                    path.addQuadCurve(to: midPoint, controlPoint: midPoint.controlPointToPoint(prevPoint))
                    path.addQuadCurve(to: point.cgPoint, controlPoint: midPoint.controlPointToPoint(point.cgPoint))
                }
            }
            prevPoint = point.cgPoint
        }
        return path
    }
    
}

// MARK: - CGPoint Extension

fileprivate extension CGPoint {
    
    /// Get the mid point of the receiver with another passed point.
    ///
    /// - Parameter p2: other point.
    /// - Returns: mid point.
    func midPointForPointsTo(_ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (x + p2.x) / 2, y: (y + p2.y) / 2)
    }
    
    /// Control point to another point from receiver.
    ///
    /// - Parameter p2: other point.
    /// - Returns: control point for quad curve.
    func controlPointToPoint(_ p2:CGPoint) -> CGPoint {
        var controlPoint = self.midPointForPointsTo(p2)
        let  diffY = abs(p2.y - controlPoint.y)
        if self.y < p2.y {
            controlPoint.y = controlPoint.y + diffY
        } else if ( self.y > p2.y ) {
            controlPoint.y = controlPoint.y - diffY
        }
        return controlPoint
    }
    
}
