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
import CoreLocation

public protocol Point2DRepresentable {
    var xValue: Float { get }
    var yValue: Float { get }
    
    var cgPoint: CGPoint { get }
    
    func distanceFrom(_ otherPoint: Self) -> Float
    func distanceToSegment(_ p1: Self, _ p2: Self) -> Float
    
    func equalsTo(_ compare: Self) -> Bool
}

extension Point2DRepresentable {
    
    public func equalsTo(_ compare: Self) -> Bool {
        return self.xValue == compare.xValue && self.yValue == compare.yValue
    }
    
    public func distanceFrom(_ otherPoint: Self) -> Float {
        let dx = self.xValue - otherPoint.xValue
        let dy = self.yValue - otherPoint.yValue
        return (dx * dx) + (dy * dy)
    }
    
    public func distanceToSegment(_ p1: Self, _ p2: Self) -> Float {
        var x = p1.xValue
        var y = p1.yValue
        var dx = p2.xValue - x
        var dy = p2.yValue - y
        
        if dx != 0 || dy != 0 {
            let t = ((xValue - x) * dx + (yValue - y) * dy) / (dx * dx + dy * dy)
            if t > 1 {
                x = p2.xValue
                y = p2.yValue
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }
        
        dx = xValue - x
        dy = yValue - y
        
        return dx * dx + dy * dy
    }
    
}

extension CLLocationCoordinate2D: Point2DRepresentable {
    public var xValue: Float { return Float(self.latitude) }
    public var yValue: Float { return Float(self.longitude) }
    
    public var cgPoint: CGPoint { return CGPoint(x: self.latitude, y: self.longitude) }
}

extension CGPoint: Point2DRepresentable {
    public var xValue: Float { return Float(self.x) }
    public var yValue: Float { return Float(self.y) }
    
    public var cgPoint: CGPoint { return self }
}
