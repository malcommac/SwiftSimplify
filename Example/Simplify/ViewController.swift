//
//  ViewController.swift
//  Simplify
//
//  Created by Daniele Margutti on 11/07/15.
//  Copyright (c) 2015 danielemargutti. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
	@IBOutlet var rView:			RenderView?
	@IBOutlet var rSlider:			UISlider?
	@IBOutlet var hQuality:			UISwitch?
	@IBOutlet var resultsLabel:		UILabel?
	@IBOutlet var toleranceLabel:	UILabel?
	private var initialPoints:		[CGPoint]?

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Just load some example's data from a JSON file.
		let exampleJSONPath = NSBundle.mainBundle().pathForResource("1k", ofType: "json")
		let JSONData = try? NSData(contentsOfFile:exampleJSONPath!, options: [])
		let JSONObj: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(JSONData!, options: NSJSONReadingOptions.MutableContainers)
		
		if let JSONObj = JSONObj as? NSArray {
			// SwiftSimplify can take an array of [CGPoint] or [CLLocationCoordinate2D]
			// So we want to convert it.
			// I've also included convertJSONToCLLocationCoordinates to convert JSON array to CLLocationCoordinate2D's array
			// In our example it's easier to work with CGPoint!
			initialPoints = convertJSONToCGPoints(JSONObj)
			// Refresh our data!
			refresh()
		}
	}
	
	@IBAction func didChangeHQParameter(sender: UISwitch) {
		refresh()
	}
	
	@IBAction func didChangeValue(sender: UISlider) {
		refresh()
	}
	
	func refresh() {
		let tolerance = Float(rSlider!.value)
		let hQ = (hQuality!.state == UIControlState.Selected ? true : false)
		
		toleranceLabel!.text = "Tolerance: \(rSlider!.value) px"
		
		// Call our library in background thread
		dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) { // 1
			let initialTime = CACurrentMediaTime();
			
			// Here is the magic!
			let simplified = SwiftSimplify.simplify(self.initialPoints!, tolerance: tolerance, highQuality: hQ)
			
			// A little masturbation benchmark for our lib
			let elapsedTime = round(1000 * (CACurrentMediaTime() - initialTime)) / 1000
			let decrement = 100.0 - ((Float(simplified.count) / Float(self.initialPoints!.count)) * 100.0)
			
			dispatch_async(dispatch_get_main_queue()) {
				// Update the rendering view and print some fancy stuff
				self.rView!.renderPoints(simplified)
				
				var resultsString = "› INITIAL POINTS: \(self.initialPoints!.count)\n"
				resultsString += "› AFTER SEMPLIFICATION: \(self.rView!.points!.count)\n"
				resultsString += "› REDUCTION: \(decrement)%\n"
				resultsString += "› ELAPSED TIME: \(elapsedTime) ms"
				self.resultsLabel!.text = resultsString
			}
		}
	}
	
	func convertJSONToCGPoints(list: NSArray) -> [CGPoint] {
		var points: [CGPoint] = []
		for idx in 0 ..< list.count {
			if let itemDict = list[idx] as? NSDictionary {
				if let x = itemDict["x"] as? NSNumber, y = itemDict["y"] as? NSNumber {
					points.append( CGPointMake( CGFloat(x.floatValue), CGFloat(y.floatValue)) )
				}
			}
		}
		return points
	}
	
	/*
	func convertJSONToCLLocationCoordinates(list: NSArray) -> [CLLocationCoordinate2D] {
		var points: [CLLocationCoordinate2D] = []
		for (var idx = 0; idx < list.count; idx++ ) {
			if let itemDict = list[idx] as? NSDictionary {
				if let x = itemDict["x"] as? NSNumber, y = itemDict["y"] as? NSNumber {
					var loc = CLLocationCoordinate2DMake(CLLocationDegrees(x.floatValue), CLLocationDegrees(y.floatValue))
					points.append(loc)
				}
			}
		}
		return points
	}
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}


}

