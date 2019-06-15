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
	var path: CGPath?
	
/*
	func renderPoints(_ p: [CGPoint]) {
		points = p
		self.setNeedsDisplay()
	}
	
	override func draw(_ rect: CGRect) {
		// Just draw our points
		let context = UIGraphicsGetCurrentContext()
		
		context?.setStrokeColor(UIColor.red.cgColor)
		context?.setLineWidth(1.0)

		if points != nil {
			let start = points!.first!.x
			var minY = points!.first!.y
			
			for i in 1 ..< points!.count {
				let p1 = points![i]
				if p1.y < minY {
					minY = p1.y
				}
			}
			
			for i in 0 ..< (points!.count-1) {
				let p1 = points![i]
				let p2 = points![i+1]
				context?.move(to: CGPoint(x: p1.x-start, y: p1.y-minY))
				context?.addLine(to: CGPoint(x: p2.x-start, y: p2.y-minY))
				context?.strokePath()
			}
			context?.drawPath(using: CGPathDrawingMode.stroke);
		}
	}
 */
	func renderPath(path: CGPath) {
		self.path = path
		self.setNeedsDisplay()
	}
	
	override func drawRect(rect: CGRect) {
        guard let path = path else { return }
		// Just draw our path
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        CGContextSetLineWidth(context, 1.0)
        CGContextAddPath(context, path)
        CGContextStrokePath(context)
    }
	
}
