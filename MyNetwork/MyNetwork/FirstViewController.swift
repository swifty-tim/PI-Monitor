//
//  FirstViewController.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 17/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    var networkValues = [Network]()
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var networkStatus: UILabel!
    let networkDown = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.5)
    let networkUp = UIColor(red: 146.0/255, green: 205.0/255, blue: 0.0/255, alpha: 1.0)
    let networkReset = UIColor(red: 102.0/255, green: 204.0/255, blue: 255.0/255, alpha: 1.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.networkStatus.layer.cornerRadius = 10
        self.networkStatus.clipsToBounds = true
        self.checkNetworkPing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkNetworkPing() {
        self.networkStatus.backgroundColor = networkReset
        self.networkStatus.text = "Testing..."
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Network URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"type=1&route=0", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
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
                    
                    self.networkValues = HTTPConnection.parseJSON(data)
                    self.checkNetwork()
                }
            })
        }

    }
    
    @IBAction func refreshTest(sender: AnyObject) {
        self.checkNetworkPing()
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
                self.networkStatus.backgroundColor = networkUp
                self.networkStatus.text = "Network Up"
            } else  {
                self.networkStatus.backgroundColor = networkDown
                self.networkStatus.text = "Network Down"
            }
        }

    }


    @IBAction func btnReset(sender: AnyObject) {
        //192.168.1.12:5000/offPin/18
        self.networkStatus.backgroundColor = networkDown
        self.networkStatus.text = "Network Down"
        let homeURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        let dic = [String: String]()
        HTTPConnection.getPingResults(dic, url: homeURL, httpMethod: "GET") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                /*if (!succeeded) {
                    let alert = UIAlertController(title: "Oops!", message:"No data found", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        //
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                    
                } else {
                }*/
            })
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