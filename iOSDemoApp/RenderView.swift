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
	
    override func draw(_ rect: CGRect) {
        guard let path = path else { return }
		// Just draw our path
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(1.0)
        context.addPath(path)
        context.strokePath()
    }
	
}
