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
    var counter = 0
    var networkValues = [Network]()
    let networkDown = NSColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.5)
    let networkUp = NSColor(red: 146.0/255, green: 205.0/255, blue: 0.0/255, alpha: 1.0)
    let networkReset = NSColor(red: 102.0/255, green: 204.0/255, blue: 255.0/255, alpha: 1.0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var timer = NSTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        self.checkNetworkPing()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func updateCounter() {
        self.counter += 1
        print(self.counter)
        if counter == 180 {
            self.checkNetworkPing()
            self.counter = 0
        }
    }

    
    func checkNetworkPing() {
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
                
                    self.networkValues = HTTPConnection.parseJSON(data)
                    self.checkNetwork()
                }
            })
        }
        
    }
    
    func checkNetwork() {
        
        if self.networkValues.count > 0 {
            
            let date = NSDate()
            
            let dateString = self.networkValues[0].getTestDate()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let pingdate = dateFormatter.dateFromString(dateString)
            let timeTenMin = date.dateByAddingTimeInterval(-15 * 60)
            
            if( pingdate!.isGreaterThanDate(timeTenMin) && pingdate!.isLessThanDate(date)) {
                self.networkLive.backgroundColor = networkUp
                //self.networkStatus.text = "Network Up"
            } else  {
                self.networkLive.backgroundColor = networkDown
                //self.networkStatus.text = "Network Down"
            }
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
