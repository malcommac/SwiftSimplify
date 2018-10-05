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
	fileprivate var initialPoints:		[CGPoint]?

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Just load some example's data from a JSON file.
		let exampleJSONPath = Bundle.main.path(forResource: "1k", ofType: "json")
		let JSONData = try? Data(contentsOf: URL(fileURLWithPath: exampleJSONPath!), options: [])
		let JSONObj: AnyObject? = try! JSONSerialization.jsonObject(with: JSONData!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
		
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
	
	@IBAction func didChangeHQParameter(_ sender: UISwitch) {
		refresh()
	}
	
	@IBAction func didChangeValue(_ sender: UISlider) {
		refresh()
	}
	
	func refresh() {
		let tolerance = Float(rSlider!.value)
		let hQ = (hQuality!.state == .selected ? true : false)
		
		toleranceLabel!.text = "Tolerance: \(rSlider!.value) px"
		
		// Call our library in background thread
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { // 1
			let initialTime = CACurrentMediaTime();
			
			// Here is the magic!
			let simplified = SwiftSimplify.simplify(self.initialPoints!, tolerance: tolerance, highQuality: hQ)
			
			// A little masturbation benchmark for our lib
			let elapsedTime = round(1000 * (CACurrentMediaTime() - initialTime)) / 1000
			let decrement = 100.0 - ((Float(simplified.count) / Float(self.initialPoints!.count)) * 100.0)
			
			DispatchQueue.main.async {
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
	
	func convertJSONToCGPoints(_ list: NSArray) -> [CGPoint] {
		var points: [CGPoint] = []
		for idx in 0 ..< list.count {
			if let itemDict = list[idx] as? NSDictionary {
				if let x = itemDict["x"] as? NSNumber, let y = itemDict["y"] as? NSNumber {
					points.append( CGPoint( x: CGFloat(x.floatValue), y: CGFloat(y.floatValue)) )
				}
			}
		}
		return points
	}
	


}

