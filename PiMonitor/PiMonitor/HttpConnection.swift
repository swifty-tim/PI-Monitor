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
            //print(error)
            //let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            if ((error) != nil) {
                print(error!.localizedDescription)
                postCompleted(succeeded: false, data: NSData())
            } else {
                postCompleted(succeeded: true, data: data!)
            }
        })
        
        task.resume()
    }
    
    
    class func parseJSON(data : NSData) -> [Network] {
        var networkValues = [Network]()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)
            
            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
            if let feeds = json["network"] as? NSArray {
                //    println("Succes: \(success)")
                
                for feed in feeds {
                    let newNetwork = Network()
                    
                    if let id = feed["id"] as? String {
                        newNetwork.setID(id)
                    }
                    if let address = feed["ip_address"] as? String {
                        newNetwork.setIpAddress(address)
                    }
                    if let ping_min = feed["ping_min"] as? String {
                        newNetwork.setPingMin(ping_min)
                    }
                    if let ping_max = feed["ping_max"] as? String {
                        newNetwork.setPingMax(ping_max)
                    }
                    if let ping_avg = feed["ping_avg"] as? String {
                        newNetwork.setPingAvg(ping_avg)
                    }
                    if let packet_loss = feed["packet_loss"] as? String {
                        newNetwork.setPacketLoss(packet_loss)
                    }
                    if let download = feed["download"] as? String {
                        newNetwork.setDownload(download)
                    }
                    if let upload = feed["upload"] as? String {
                        newNetwork.setUpload(upload)
                    }
                    if let hosted_by = feed["hosted_by"] as? String {
                        newNetwork.setHostedBy(hosted_by)
                    }
                    if let ping = feed["ping"] as? String {
                        newNetwork.setPing(ping)
                    }
                    if let net_type = feed["net_type"] as? String {
                        newNetwork.setNetType(net_type)
                    }
                    if let test_date = feed["test_date"] as? String {
                        newNetwork.setTestDate(test_date)
                    }
                    if let hostname = feed["hostname"] as? String {
                        newNetwork.setHostname(hostname)
                    }
                    if let ping_loc = feed["ping_loc"] as? String {
                        newNetwork.setPingLoc(ping_loc)
                    }
                    
                    networkValues.append(newNetwork)
                }
            }
            
        } catch let parseError {
            print(parseError)
        }
        
        return networkValues
    }
    
    class func parseJSONRoute(data : NSData) -> [Route] {
        var routeValues = [Route]()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)
            
            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
            if let feeds = json["network"] as? NSArray {
                //    println("Succes: \(success)")
                
                for feed in feeds {
                    let newRoute = Route()
                    
                    if let address = feed["route_ip"] as? String {
                        newRoute.setIP(address)
                    }
                    if let rtt = feed["rtt"] as? String {
                        let rttArr = rtt.characters.split{$0 == " "}.map(String.init)
                        newRoute.setRTT(rttArr)
                        
                    }
                    if let coord = feed["coord"] as? String {
                        newRoute.setCoord(coord)
                    }
                    if let test_date = feed["test_date"] as? String {
                        newRoute.setTestDate(test_date)
                    }
                    if let location = feed["location"] as? String {
                        newRoute.setLoc(location)
                    }
                    routeValues.append(newRoute)
                }
            }
            
        } catch let parseError {
            print(parseError)
        }
        
        return routeValues
    }
    
    
    class func parseJSONPIData(data : NSData) -> PIData {
        let piDataValues = PIData()
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves)
            
            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
            if let feed = json["network"] as? NSDictionary {
                //    println("Succes: \(success)")
                
                
                if let cpu_temperature = feed["cpu_temperature"] as? String {
                   piDataValues.setCPUTemp(cpu_temperature)
                }
                if let cpu_usage = feed["cpu_usage"] as? String {
                   piDataValues.setCpuUsage(cpu_usage+"%")
                }
                if let ram_total = feed["ram_total"] as? String {
                    piDataValues.setRamTotal(ram_total)
                }
                if let ram_percent_used = feed["ram_percent_used"] as? String {
                    piDataValues.setRamUsage(ram_percent_used+"%")
                }
                /*if let ram_used = feed["ram_used"] as? String {
                    //piDataValues.append("RAM Used: "+ram_used)
                }
                if let ram_free = feed["ram_free"] as? String {
                    //piDataValues.append("RAM Free: "+ram_free)
                }
                if let disk_total = feed["disk_total"] as? String {
                    //piDataValues.append("Disk Total: "+disk_total)
                }
                if let disk_used = feed["disk_used"] as? String {
                    //piDataValues.append("Disk Used: "+disk_used)
                }
                if let disk_free = feed["disk_free"] as? String {
                    //piDataValues.append("Disk Free: "+disk_free)
                }
                if let disk_percent_used = feed["disk_percent_used"] as? String {
                    //piDataValues.append("Disk Used: "+disk_percent_used+"%")
                } */
            }
            
        } catch let parseError {
            print(parseError)
        }
        
        return piDataValues
    }
    
    
    
}
