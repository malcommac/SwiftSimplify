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
