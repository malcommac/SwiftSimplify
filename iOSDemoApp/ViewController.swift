//
//  ViewController.swift
//  iOSDemoApp
//
//  Created by Daniele Margutti on 28/06/2019.
//  Copyright © 2019 SwiftSimplify. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var rView: RenderView!
    @IBOutlet weak var rSlider: UISlider!
    @IBOutlet weak var hQuality: UISwitch!
    @IBOutlet weak var smoothSwitch: UISwitch!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var toleranceLabel: UILabel!
    private var initialPoints:        [CGPoint]?
    
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
            initialPoints = convertJSONToCGPoints(JSONObj, pointOffset: CGPoint(x: 270, y: 80))
            // Refresh our data!
            refresh()
        }
    }
    
    @IBAction func didChangeHQParameter(_ sender: UISwitch) {
        refresh()
    }
    
    @IBAction func didChangeSmoothParameter(_ sender: UISwitch) {
        refresh()
    }
    
    @IBAction func didChangeValue(_ sender: UISlider) {
        refresh()
    }
    
    func refresh() {
        let tolerance = Float(rSlider!.value)
        let hQ = hQuality.isOn
        toleranceLabel!.text = NSString(format: "Tolerance: %0.2fpx", rSlider!.value) as String
        
        // Call our library in background thread
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async { // 1
            let initialTime = CACurrentMediaTime();
            
            let start = self.initialPoints!.first!.x
            var minY = self.initialPoints!.first!.y
            
            for i in 1 ..< self.initialPoints!.count {
                let p1 = self.initialPoints![i]
                if p1.y < minY {
                    minY = p1.y
                }
            }
            // Here is the magic!
            let path = CGMutablePath()
            for i in 0 ..< (self.initialPoints!.count-1) {
                let p1 = self.initialPoints![i]
                let p2 = self.initialPoints![i+1]
                
                path.move(to: CGPoint(x: p1.x-start, y: p1.y-minY))
                path.addLine(to: CGPoint(x: p2.x-start, y: p2.y-minY))
            }
            let simplifiedPoints = SwiftSimplify.simplify(self.initialPoints!, tolerance: tolerance, highestQuality: hQ)
            let simplifiedPath = UIBezierPath.smoothFromPoints(simplifiedPoints)
            
            // A little masturbation benchmark for our lib
            let elapsedTime = round(1000 * (CACurrentMediaTime() - initialTime)) / 1000
            let decrement = 100.0 - ((Float(simplifiedPoints.count) / Float(self.initialPoints!.count)) * 100.0)
            
            DispatchQueue.main.async {
                // Update the rendering view and print some fancy stuff
                self.rView!.renderPath(path: simplifiedPath.cgPath)
                
                var resultsString = "› INITIAL POINTS: \(self.initialPoints!.count)\n"
                resultsString += "› AFTER SEMPLIFICATION: \(simplifiedPoints.count)\n"
                resultsString += "› REDUCTION: \(decrement)%\n"
                resultsString += "› ELAPSED TIME: \(elapsedTime) ms"
                self.resultsLabel!.text = resultsString
            }
        }
    }
    
    func convertJSONToCGPoints(_ list: NSArray, pointOffset: CGPoint = .zero) -> [CGPoint] {
        var points: [CGPoint] = []
        for idx in 0 ..< list.count {
            if let itemDict = list[idx] as? NSDictionary {
                if let x = itemDict["x"] as? NSNumber, let y = itemDict["y"] as? NSNumber {
                    points.append( CGPoint( x: CGFloat(x.floatValue) - pointOffset.x, y: CGFloat(y.floatValue) - pointOffset.y) )
                }
            }
        }
        return points
    }
    
    
    
}

