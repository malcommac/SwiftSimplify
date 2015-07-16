//
//  RenderView.swift
//  Simplify
//
//  Created by Daniele Margutti on 11/07/15.
//  Copyright (c) 2015 danielemargutti. All rights reserved.
//

import Foundation
import UIKit

class RenderView: UIView {
	var points: [CGPoint]?
	
	func renderPoints(p: [CGPoint]) {
		points = p
		self.setNeedsDisplay()
	}
	
	override func drawRect(rect: CGRect) {
		// Just draw our points
		var context = UIGraphicsGetCurrentContext()
		
		CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
		CGContextSetLineWidth(context, 1.0)

		if points != nil {
			var start = points!.first!.x
			var minY = points!.first!.y
			
			for (var i = 1; i < points!.count; i++) {
				let p1 = points![i]
				if p1.y < minY {
					minY = p1.y
				}
			}
			
			for (var i = 0; i < (points!.count-1); i++) {
				let p1 = points![i]
				let p2 = points![i+1]
				CGContextMoveToPoint(context, p1.x-start, p1.y-minY)
				CGContextAddLineToPoint(context, p2.x-start, p2.y-minY)
				CGContextStrokePath(context)
			}
			CGContextDrawPath(context, kCGPathStroke);
		}
	}
	
}
