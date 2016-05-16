//
//  ViewController.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 30/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit
import Foundation

let π = CGFloat(M_PI)

class ViewController: UIViewController {
   
    var boostUp: UIButton = UIButton()
    var boostDown: UIButton = UIButton()
    var boostTime : Bool = false
    var heaterOn : Bool = false
    var currIndex : Int = -1
    var startIndex : Int = -1
    var tempLabel : UILabel = UILabel()
    var filterView: FilterContentView?
    var isBlurred: Bool = false
    var dullView: UIView?
    var timerUsed: Bool?
    var heaterSchedules = [AllTimers]()
    var todaySchedules = [Heater]()
    var circleRadius : CGFloat = 150
    var boostTenMins : Int?
    var boostIndex : Int?
    
    var controlValues = [String:Int]()
    
    //255, 0, 128
    let currTimeColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 128.0/255, alpha: 0.8)
    //146, 205, 0
    let boostUpColor = UIColor(red: 146.0/255, green: 205.0/255, blue: 0.0/255, alpha: 0.8)
    //
    let boostDownColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.8)
    
    var x :CGFloat = 0
    var y :CGFloat = 0
    var segments : [Segements] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.boostIndex = 0
        self.boostTenMins = 0
        self.getControlValues()
        self.getHeaterValues()
        timerUsed = true
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipUpGesture))
        //let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipDownGesture))
        
        upSwipe.direction = .Up
        //downSwipe.direction = .Down
        
        view.addGestureRecognizer(upSwipe)
        //view.addGestureRecognizer(downSwipe)
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        self.circleRadius = width / 3.5
        
        self.boostDown.frame = CGRectMake(0, 0, 50, 50)
        self.boostDown.backgroundColor = self.boostDownColor
        self.boostDown.center = CGPointMake( width / 2, height + self.boostDown.frame.size.height + 10  )
        self.boostDown.titleLabel!.font =  UIFont(name: "Avenir Next", size: 40)
        self.boostDown.addTarget(self, action: #selector(self.boostDownButton), forControlEvents: .TouchUpInside)
        
        self.boostUp.frame = CGRectMake(0, 0, 80, 80)
        self.boostUp.backgroundColor = self.boostUpColor
        self.boostUp.center = CGPointMake( width / 2, height - self.boostUp.frame.size.height - 10  )
        self.boostUp.titleLabel!.font =  UIFont(name: "Avenir Next", size: 60)
        self.boostUp.addTarget(self, action: #selector(self.boostUpButton), forControlEvents: .TouchUpInside)
        
        let boostUpWidth = self.boostUp.frame.width / 2
        self.boostUp.layer.cornerRadius = boostUpWidth
        let boostDownWidth = self.boostDown.frame.width / 2
        self.boostDown.layer.cornerRadius = boostDownWidth
        self.boostUp.setTitle("+", forState: .Normal)
        self.boostDown.setTitle("—", forState: .Normal)
        
        self.view.addSubview(self.boostDown)
        self.view.addSubview(self.boostUp)
        
        x = self.view.center.x
        y = self.view.center.y - self.view.center.y / 3.8
        // Do any additional setup after loading the view, typically from a nib.
        _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.updateView), userInfo: nil, repeats: true)
       self.createCirlce()
       // self.drawSemicircle()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getControlValues() {
        
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"control/get", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                    let alert = UIAlertController(title: "Oops!", message:"No data found", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        //
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                    
                } else {
                    self.controlValues = HTTPConnection.parseJSONControl(data)
                    print(self.controlValues["waterOn"])
                    print(self.controlValues["heatingOn"])
                    print(self.controlValues["pumpOn"])
                    if self.controlValues["waterOn"] == 0 {
                        self.timerUsed = false
                    } else {
                        self.timerUsed = true
                    }
                }
            })
        }
        
    }
    
    func getHeaterValues() {
        
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"heater/get", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                    let alert = UIAlertController(title: "Oops!", message:"No data found", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        //
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                    
                } else {
                    //print (NSString(data: data, encoding: NSUTF8StringEncoding) )
                    self.heaterSchedules = HTTPConnection.parseJSON(data)
                    let date = NSDate()
                    self.todaySchedules = self.heaterSchedules[date.weekday() - 1 ].getDatTimer()
                }
            })
        }
        
    }

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func refreshView(sender: AnyObject) {
        self.updateView()
    }
    
    func swipUpGesture() {
        self.addOrRemoveBlurrToView()
        self.addFilterView()
    }
    
    //func swipDownGesture() {
    //    self.addOrRemoveBlurrToView()
    //    self.dismissFilterView()
   // }
    
    
    func boostUpButton(sender: UIButton) {
        
        self.boostTenMins! = self.boostTenMins! + 1
        
        if !boostTime {
            
            let boostMulti = self.boostTenMins! * 10
            let date1 = NSDate()
            let newHeater = Heater()
            newHeater.setDayNo(1)
            newHeater.setTimerStart(date1)
            newHeater.setTimerEnd(date1.addMinutes(boostMulti))
            newHeater.setBoostUsed(1)
            newHeater.setWaterUsed(1)
            newHeater.setHeaterType("Boost Hot Water")
            newHeater.setHeatingUsed(0)
            newHeater.setID(self.todaySchedules.count)
            self.boostIndex = self.todaySchedules.count
            self.todaySchedules.append(newHeater)
            
            self.boostTime = true
            self.heaterOn = true
            UIView.animateWithDuration(1.0, animations:{
                self.boostUp.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - self.boostDown.frame.size.height - self.boostUp.frame.size.height - 20 )
                self.boostDown.center = CGPointMake(  self.view.frame.size.width / 2, self.view.frame.size.height - self.boostDown.frame.size.height - 10 )
            })
            self.updateView()
            /*let date = NSDate()
            let hour = date.hour()
            let min = date.minute()
            let interval = Int(min / 20)
            let currIndex = ( hour * 3 - 1 ) + interval
            
            self.segments[self.checkCurrentIndex(currIndex)].getShape().strokeColor = UIColor.orangeColor().CGColor */
            //self.segments[self.checkCurrentIndex(currIndex)].setBoost(1)
            //newHeater.setID(self.currIndex)
            
        } else {
    
            let boostMulti = self.boostTenMins! * 10
            let date1 = NSDate()
            self.todaySchedules[self.boostIndex!].setTimerEnd(date1.addMinutes(boostMulti))
            self.updateView()
            
        }
    }
    
    func boostDownButton(sender: UIButton) {
        
        if self.boostTime {
            
            self.boostTenMins! = self.boostTenMins! - 1
    
            let boostMulti = self.boostTenMins! * 10
            let date1 = NSDate()
            self.todaySchedules[self.boostIndex!].setTimerEnd(date1.addMinutes(boostMulti))
            self.updateView()
            let timeStart = self.todaySchedules[self.boostIndex!].getTimerStart()
            let timeEnd = self.todaySchedules[self.boostIndex!].getTimerEnd()
            
            if timeEnd.isLessThanDate( timeStart ) {
                
                self.boostTime = false
                self.heaterOn = false
                
                self.todaySchedules.removeAtIndex(self.boostIndex!)
                
                UIView.animateWithDuration(1.0, animations:{
                    self.boostUp.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height - self.boostUp.frame.size.height - 20 )
                    self.boostDown.center = CGPointMake(  self.view.frame.size.width / 2, self.view.frame.size.height + self.boostDown.frame.size.height + 10 )
                })
                
            }
        }
    }
    
    func testValue( index : Int) -> Int {
        
        if index > 0  {
            return index - 1
        } else if index == 0 {
            return self.segments.count - 1
        }
        return index
    }
    
    
    func checkCurrentIndex(curIndex : Int) -> Int {
        
        if curIndex == self.segments.count {
            return 0
        } else if curIndex < 0 {
            return self.segments.count - 1
        }
        return curIndex
    }
    
    func updateView() {
        
        let date = NSDate()
        let hour = date.hour()
        let min = date.minute() / 20
        let interval = self.flourValue(min)
        var indexNow = ( hour * 3 ) + interval
        
        indexNow  = self.testValue(indexNow)
        
        for i in self.segments {
            
            if !self.timerUsed! {
               i.getShape().strokeColor = UIColor.lightGrayColor().CGColor
                
            } else {
                i.getShape().strokeColor = UIColor.blueColor().CGColor
            }
            if CGColorEqualToColor( i.getShape().strokeColor!, UIColor.yellowColor().CGColor ) {
                i.getShape().strokeColor = UIColor.blueColor().CGColor
            }
        }
        
        self.segments[indexNow].getShape().strokeColor = UIColor.yellowColor().CGColor
        
        
        /*if indexNow >= self.startIndex && indexNow <= self.currIndex ||
        CGColorEqualToColor( self.segments[indexNow].getShape().strokeColor!, UIColor.greenColor().CGColor) ||
        CGColorEqualToColor( self.segments[indexNow].getShape().strokeColor!, UIColor.orangeColor().CGColor) {
            
            self.segments[indexNow].getShape().strokeColor = UIColor.orangeColor().CGColor
        } else {
            self.segments[indexNow].getShape().strokeColor = UIColor.yellowColor().CGColor
        } */
        
        if self.heaterSchedules.count > 0 && self.timerUsed! {
        
            for schedule in self.todaySchedules {
                
                let hourStart = schedule.getTimerStart().hour()
                let minStart = schedule.getTimerStart().minute() / 20
            
                let intervalStart = self.flourValue(minStart)
                var startIndex = ( hourStart * 3 ) + intervalStart
                startIndex = self.testValue(startIndex)
            
            
                let hourEnd = schedule.getTimerEnd().hour()
                let minEnd = schedule.getTimerEnd().minute() / 20
        
                let intervalEnd = self.flourValue(minEnd)
                var endIndex = ( hourEnd * 3 ) + intervalEnd
                endIndex = self.testValue(endIndex)
            
                var timeIndex = 0
                timeIndex = timeIndex + startIndex
                while endIndex >= timeIndex {
                    
                    if schedule.getBoostUsed() == 1 {
                        self.segments[timeIndex].getShape().strokeColor = UIColor.orangeColor().CGColor
                    } else {
                        self.segments[timeIndex].getShape().strokeColor = UIColor.greenColor().CGColor
                    }
                    timeIndex = timeIndex + 1
            
                }
            }
        }
        
        if CGColorEqualToColor( self.segments[indexNow].getShape().strokeColor!, UIColor.orangeColor().CGColor) {
            
            self.tempLabel.backgroundColor = UIColor.redColor()
            self.tempLabel.textColor = UIColor.whiteColor()
            
        } else {
            
            self.tempLabel.backgroundColor = UIColor.whiteColor()
            self.tempLabel.textColor = UIColor.redColor()
        }

    }
    
    
    
    func createCirlce() {
        
        let circlePoints = self.getNPointsOnCircle(self.circleRadius + 50)
        var index = 0
        let start =  (CGFloat(M_PI_2) * 4.0) / 72
        let test = start / 1.3
        let circlePath = UIBezierPath(arcCenter: CGPointMake(x,y), radius: self.circleRadius, startAngle: CGFloat(M_PI_2) * 3.0 + test , endAngle:CGFloat(M_PI_2) * 3.0 + CGFloat(M_PI) * 2.0 + test, clockwise: true)
        let segmentAngle : CGFloat = 1 / 72
        
        for i in 0 ..< 72 {
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.CGPath
            
            circleLayer.strokeStart = segmentAngle * CGFloat(i)
            
            let gapSize : CGFloat = 0.008
            circleLayer.strokeEnd = circleLayer.strokeStart + segmentAngle - gapSize
            
            circleLayer.lineWidth = 70
           
            circleLayer.strokeColor = UIColor.blueColor().CGColor
            
            circleLayer.fillColor = UIColor.whiteColor().CGColor
            
            let newSegement = Segements()
            newSegement.setBoost(0)
            newSegement.setShape(circleLayer)
            
            self.segments.insert(newSegement, atIndex: i)
            self.view.layer.addSublayer(segments[i].getShape())
            
            if i % 3 == 0 {
                
                let label = UILabel(frame: CGRectMake(0, 0, 22, 22))
                label.center = CGPointMake(circlePoints[index].x, circlePoints[index].y)
                label.textColor = UIColor.redColor()
                label.textAlignment = NSTextAlignment.Center
                label.text = String(index)
                label.font = UIFont(name: "Avenir Next", size: 16)
                self.view.addSubview(label)
                index = index + 1
                
            }
        }
        
        self.tempLabel.frame =  CGRectMake(0, 0, 100, 100)
        self.tempLabel.center = CGPointMake(self.x, self.y)
        self.tempLabel.textColor = UIColor.purpleColor()
        self.tempLabel.adjustsFontSizeToFitWidth = true
        self.tempLabel.textAlignment = NSTextAlignment.Center
        self.tempLabel.text = "20℃"
        self.tempLabel.font = UIFont(name: "Avenir Next", size: 32)
        self.tempLabel.layer.cornerRadius = self.tempLabel.frame.size.width / 2
        self.tempLabel.clipsToBounds = true
        self.view.addSubview(self.tempLabel)
        
    }
    
    func getNPointsOnCircle(radius:CGFloat) -> [CGPoint]{
        
        let alpha:CGFloat = 360 / 24;
        var startPoint:CGFloat = 270

        var circlePoints = [CGPoint]()
        
        var index = 0
    
        for _ in 0..<24 {
            
            if ( alpha * CGFloat(index) + startPoint ) > 360 {
                index = 0
                startPoint = 15
            }
            
            let theta:CGFloat = alpha * CGFloat(index) + startPoint;
        
            let pointX = self.x + ( radius * cos(theta.degreesToRadians))
            let pointY = self.y + ( radius * sin(theta.degreesToRadians))
            let pointOnCircle:CGPoint = CGPoint(x: CGFloat(pointX), y: CGFloat(pointY))
            circlePoints.append(pointOnCircle)
            index = index + 1
        }
        return circlePoints
    }
    
    func flourValue(val: Int) -> Int {
        return Int(floor(CGFloat(val)))
    }

}

extension ViewController {
    
    func addFilterView() {
        
        self.filterView = FilterContentView()
        self.filterView!.frame = CGRect(x: 5, y: self.view.frame.height, width: self.view.frame.width - 10 , height: self.view.frame.height * 0.6)
        self.navigationController!.view.addSubview(self.filterView!)
        let waterOn = self.IntToBool(self.controlValues["waterOn"]!)
        let heatingOn = self.IntToBool(self.controlValues["heatingOn"]!)
        let pumpOn = self.IntToBool(self.controlValues["pumpOn"]! )
        self.filterView?.setHotWaterSwitch(waterOn)
        self.filterView?.setHeatingSwitch(heatingOn)
        self.filterView?.setPumpSwitchState(pumpOn)
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            
            self.filterView!.frame = CGRect(x: 5, y: self.view.frame.height * 0.6, width: self.view.frame.width - 10, height: self.view.frame.height * 0.6)
            self.view.bringSubviewToFront(self.filterView!)
        })
        
        let swipDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipFilterView))
        swipDownGesture.direction = .Down
        self.filterView!.addGestureRecognizer(swipDownGesture)
        
    }
    
    func swipFilterView(recognizer: UISwipeGestureRecognizer) {
        self.addOrRemoveBlurrToView()
        self.dismissFilterView()
    }
    func dismissFilterView() {
        //println("Starting...")
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            
            self.filterView!.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
            
        }) { (complete) -> Void in
            self.timerUsed = self.filterView!.returnHotWaterSwitch()
            
            var change : Bool = false
            if self.controlValues["waterOn"] != self.boolToInt(self.filterView!.returnHotWaterSwitch()) {
                self.controlValues["waterOn"] = self.boolToInt(self.filterView!.returnHotWaterSwitch())
                change = true
            }
            if self.controlValues["heatingOn"] != self.boolToInt(self.filterView!.returnHeatingSwitch()) {
                self.controlValues["heatingOn"] = self.boolToInt(self.filterView!.returnHeatingSwitch())
                change = true
            }
            if self.controlValues["pumpOn"] != self.boolToInt(self.filterView!.returnPumpSwitch()) {
                self.controlValues["pumpOn"] = self.boolToInt(self.filterView!.returnPumpSwitch())
                change = true
            }
            
            if change {
                self.updateControlServer()
            }
            
            self.filterView!.removeFromSuperview()
        }
    }
    
    func updateControlServer() {
        
        let dic : [String : String] = [ "id": String(self.controlValues["id"]!),
                                        "waterOn": String(self.controlValues["waterOn"]!),
                                        "heatingOn": String(self.controlValues["heatingOn"]!),
                                        "pumpOn": String(self.controlValues["pumpOn"]!)
                                        ]
        
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"control/send", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                    let alert = UIAlertController(title: "Oops!", message:"No data found", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        //
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                    
                } else {
                    print("succeded")
                }
            })
        }

    }
    
    func IntToBool(value : Int) -> Bool {
        if value == 0 {
            return false
        } else {
            return true
        }
    }
    
    func boolToInt( value : Bool ) -> Int {
        if value {
            return 1
        } else {
            return 0
        }
    }
    
    func addOrRemoveBlurrToView() {
        
        if !isBlurred {
            self.dullView = UIView(frame: UIScreen.mainScreen().bounds)
            self.dullView!.backgroundColor = UIColor.blackColor()
            self.dullView!.alpha = 0.4
            
            self.navigationController!.view.addSubview(self.dullView!)
            
            
            isBlurred = true
        } else {
            self.dullView?.removeFromSuperview()
            
            isBlurred = false
        }
        
    }

}

extension CGFloat {
    var doubleValue:      Double  { return Double(self) }
    var degreesToRadians: CGFloat { return CGFloat(doubleValue * M_PI / 180) }
    var radiansToDegrees: CGFloat { return CGFloat(doubleValue * 180 / M_PI) }
}

extension NSDate
{
    
    func weekday() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Weekday, fromDate: self)
        let weekday = components.weekday
        calendar.firstWeekday = 2
        return (weekday + 7 - calendar.firstWeekday) % 7 + 1
    }
    
    func hour() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        return hour
    }
    
    
    func minute() -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        return minute
    }
    
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }

    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    func addMinutes(hoursToAdd: Int) -> NSDate {
        let secondsInMins: NSTimeInterval = Double(hoursToAdd) * 60
        let dateWithMinsAdded: NSDate = self.dateByAddingTimeInterval(secondsInMins)
        
        //Return Result
        return dateWithMinsAdded
    }
}

extension UINavigationController {
    public override func shouldAutorotate() -> Bool {
        return false
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.Portrait]
        return orientation
    }
}
