//
//  HTTPConnection.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 08/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import Foundation

//
//  GenericAsyncTask.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 17/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import Foundation

public class HTTPConnection {
    
    class func getPingResults(params : Dictionary<String, String>, url : String, httpMethod: String, postCompleted : (succeeded: Bool, data: NSData) -> ()) {

        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = httpMethod
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch {
            //err = error
            request.HTTPBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
            print("Response: \(response)")
            //print(data)
            //print(error)
            //let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print(strData)
            if ((error) != nil) {
                print(error!.localizedDescription)
                postCompleted(succeeded: false, data: NSData())
            } else {
                postCompleted(succeeded: true, data: data!)
            }
        })
        
        task.resume()
    }
    
    class func parseJSONControl(data : NSData) -> [String:Int] {
        var controlVaules = [String: Int]()
        
        do {
            let strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            let data1: NSData = strData!.dataUsingEncoding(NSUTF8StringEncoding)!
            let json = try NSJSONSerialization.JSONObjectWithData(data1, options: .MutableLeaves)
            
            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
            if let feeds = json["control"] as? NSArray {
                //    println("Succes: \(success)")
                
                for feed in feeds {
                    
                    
                    if let id = feed["id"] as? Int {
                        controlVaules["id"] = id
                    }
                    if let heatingOn = feed["heatingOn"] as? Int {
                        controlVaules["heatingOn"] = heatingOn
                    }
                    if let pumpON = feed["pumpOn"] as? Int {
                        controlVaules["pumpOn"] = pumpON
                    }
                    if let waterOn = feed["waterOn"] as? Int {
                       controlVaules["waterOn"] = waterOn
                    }
                }
            }
        } catch let parseError {
            print(parseError)
        }
        
        return controlVaules
    }
    
    class func parseJSON(data : NSData) -> [AllTimers] {
        var heaterValues = [AllTimers]()
        do {
            let strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            let data1: NSData = strData!.dataUsingEncoding(NSUTF8StringEncoding)!
            let json = try NSJSONSerialization.JSONObjectWithData(data1, options: .MutableLeaves)
            
            var monValues = [Heater]()
            var tuesValues = [Heater]()
            var wedValues = [Heater]()
            var thursValues = [Heater]()
            var friValues = [Heater]()
            var satValues = [Heater]()
            var sunValues = [Heater]()
            
            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
            if let feeds = json["heater"] as? NSArray {
                //    println("Succes: \(success)")
                
                for feed in feeds {
                    let newheater = Heater()
                    
                    if let id = feed["id"] as? Int {
                        newheater.setID(id)
                    }
                    if let day_no = feed["day_no"] as? Int {
                        newheater.setDayNo(day_no)
                    }
                    if let heater_type = feed["heater_type"] as? String {
                        newheater.setHeaterType(heater_type)
                    }
                    if let heating_used = feed["heating_used"] as? Int {
                        newheater.setHeatingUsed(heating_used)
                    }
                    if let record_enabled = feed["record_enabled"] as? Int {
                        newheater.setRecordEnabled(record_enabled)
                    }
                    if let water_used = feed["water_used"] as? Int {
                        newheater.setWaterUsed(water_used)
                    }
                    if let boost_used = feed["boost_used"] as? Int {
                        newheater.setBoostUsed(boost_used)
                    }
                    if let time_start = feed["time_start"] as? String {
                        newheater.setTimerStart(time_start.toDateTime())
                    }
                    if let time_end = feed["time_end"] as? String {
                        newheater.setTimerEnd(time_end.toDateTime())
                    }
                    
                    switch newheater.getDayNo() {
                    case 0  :
                        monValues.append(newheater)
                    case 1  :
                        tuesValues.append(newheater)
                    case 2  :
                        wedValues.append(newheater)
                    case 3  :
                        thursValues.append(newheater)
                    case 4  :
                        friValues.append(newheater)
                    case 5  :
                        satValues.append(newheater)
                    case 6  :
                        sunValues.append(newheater)
                    default :
                        monValues.append(newheater)
                    }
                    
                }
            }
            
            let monScheduler = AllTimers()
            monScheduler.setDayTimer(monValues)
            heaterValues.append(monScheduler)
            
            let tuesScheduler = AllTimers()
            tuesScheduler.setDayTimer(tuesValues)
            heaterValues.append(tuesScheduler)
            
            let wedScheduler = AllTimers()
            wedScheduler.setDayTimer(wedValues)
            heaterValues.append(wedScheduler)
            
            let thursScheduler = AllTimers()
            thursScheduler.setDayTimer(thursValues)
            heaterValues.append(thursScheduler)
            
            let friScheduler = AllTimers()
            friScheduler.setDayTimer(friValues)
            heaterValues.append(friScheduler)
            
            
            let satScheduler = AllTimers()
            satScheduler.setDayTimer(satValues)
            heaterValues.append(satScheduler)
            
            let sunScheduler = AllTimers()
            sunScheduler.setDayTimer(sunValues)
            heaterValues.append(sunScheduler)
            
            
        } catch let parseError {
            print(parseError)
        }
        
        
        return heaterValues
    }
    
    
}

extension String
{
    func toDateTime() -> NSDate
    {
        //Create Date Formatter
        let dateFormatter = NSDateFormatter()
        
        //Specify Format of String to Parse
        dateFormatter.dateFormat = "HH:mm"
        
        //Parse into NSDate
        let dateFromString : NSDate = dateFormatter.dateFromString(self)!
        
        //Return Parsed Date
        return dateFromString
    }
}
