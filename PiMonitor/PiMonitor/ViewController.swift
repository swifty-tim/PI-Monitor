//
//  ViewController.swift
//  PiMonitor
//
//  Created by Timothy Barnard on 24/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {

    @IBOutlet weak var networkLive: NSTextField!
    @IBOutlet weak var customView1: NSView!
    @IBOutlet weak var lblDownload: NSTextField!
    @IBOutlet weak var customView2: NSView!
    @IBOutlet weak var customView3: NSView!
    @IBOutlet weak var customView4: NSView!
    @IBOutlet weak var lblUpload: NSTextField!
    @IBOutlet weak var lblRamUsed: NSTextField!
    @IBOutlet weak var lblCpuUsed: NSTextField!
    @IBOutlet weak var timerIndicator: NSProgressIndicator!
    
    var counter = 0
    let networkDown = NSColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
    let networkUp = NSColor(red: 146.0/255, green: 205.0/255, blue: 0.0/255, alpha: 1.0)
    let networkReset = NSColor(red: 102.0/255, green: 204.0/255, blue: 255.0/255, alpha: 1.0)
    let cellColor1 = NSColor(red: 204.0/255, green: 204.0/255, blue: 204.0/255, alpha: 0.5)
    let cellColor2 = NSColor(red: 192.0/255, green: 192.0/255, blue: 192.0/255, alpha: 0.5)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timerIndicator.minValue = 0.0
        self.timerIndicator.maxValue = 100.0
        self.customView1.layer?.backgroundColor = cellColor1.CGColor
        self.customView2.layer?.backgroundColor = cellColor2.CGColor
        self.customView3.layer?.backgroundColor = cellColor2.CGColor
        self.customView4.layer?.backgroundColor = cellColor1.CGColor
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        self.checkNetworkPing()
        self.checkNetworkSpeed()
        self.checkPiStatus()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func updateCounter() {
        
        self.timerIndicator.incrementBy(1.0)
        if self.timerIndicator.doubleValue == 100.0 {
            self.checkNetworkPing()
            self.checkNetworkSpeed()
            self.checkPiStatus()
            self.timerIndicator.doubleValue = 0.0
        }
    }

    
    func checkNetworkPing() {
        var networkValues = [Network]()
        self.networkLive.backgroundColor = networkReset
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Network URL") as! String
        print(networkURL)
        HTTPConnection.getPingResults(dic, url: networkURL+"type=1&route=0", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                    //let alert = UIAlertController(title: "Oops!", message:"No data found", preferredStyle: .Alert)
                    //let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        //
                   // }
                    //alert.addAction(action)
                    //self.presentViewController(alert, animated: true){}
                    
                } else {
                
                    networkValues = HTTPConnection.parseJSON(data)
                    
                    if networkValues.count > 0 {
                        self.checkNetwork(networkValues[0].getTestDate())
                    } else {
                        self.checkNetwork("")
                    }
                }
            })
        }
        
    }
    
    func checkNetworkSpeed() {
        var networkValues = [Network]()
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Network URL") as! String
        print(networkURL)
        HTTPConnection.getPingResults(dic, url: networkURL+"type=2", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                } else {
                    
                    networkValues = HTTPConnection.parseJSON(data)
                    if networkValues.count > 0 {
                        self.lblUpload.stringValue = networkValues[0].getUpload()
                        self.lblDownload.stringValue = networkValues[0].getDownload()
                    }
                }
            })
        }
        
    }

    
    func checkPiStatus() {
        var piData: PIData?
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Network URL") as! String
        print(networkURL)
        HTTPConnection.getPingResults(dic, url: networkURL+"type=1&route=-1", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                } else {
                    
                    piData = HTTPConnection.parseJSONPIData(data)
                    self.lblCpuUsed.stringValue = piData!.getCpuUsage()
                    self.lblRamUsed.stringValue = piData!.getRamUsage()
                }
            })
        }
        
    }

    
    func checkNetwork(pingDate : String) {
        
        if pingDate != "" {
            
            let date = NSDate()
        
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let pingdate = dateFormatter.dateFromString(pingDate)
            let timeTenMin = date.dateByAddingTimeInterval(-15 * 60)
            
            if( pingdate!.isGreaterThanDate(timeTenMin) && pingdate!.isLessThanDate(date)) {
                self.networkLive.backgroundColor = networkUp
                self.networkLive.stringValue  = "Network Up"
            } else  {
                self.networkLive.backgroundColor = networkDown
                self.networkLive.stringValue  = "Network Down"
            }
        } else {
            self.networkLive.backgroundColor = networkDown
            self.networkLive.stringValue  = "No repsonse"
        }
        
    }




}

extension NSDate
{
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
}
