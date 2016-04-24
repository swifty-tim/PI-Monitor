//
//  Network.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 17/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import Foundation

class Route {
    var ip: String = ""
    var rtt = [String]()
    var loc : String = ""
    var test_date : String = ""
    var coord : String = ""
    
    func setIP(ip: String) {
        self.ip = ip
    }
    func getIP() -> String {
        return self.ip
    }
    
    func setRTT(rtt : [String]) {
        self.rtt = rtt
    }
    func getRTT() -> [String] {
        return self.rtt
    }
    func setCoord(coord : String) {
        self.coord = coord
    }
    func getCoord() -> String {
        return self.coord
    }
    
    func setLoc(loc: String) {
        self.loc = loc
    }
    func getLoc() -> String {
        return self.loc
    }
    func setTestDate(test_date: String) {
        self.test_date = test_date
    }
    func getTestDate() -> String {
        return self.test_date
    }
    
}

class Network {
    
    var id          :String = ""
    var ip_address  :String = ""
    var ping_min    :String = ""
    var ping_max    :String = ""
    var ping_avg    :String = ""
    var hosted_by   :String = ""
    var packet_loss :String = ""
    var download    :String = ""
    var upload      :String = ""
    var ping        :String = ""
    var net_type    :String = ""
    var test_date   :String = ""
    var hostname    :String = ""
    var ping_loc    :String = ""
    var routeArr = [Route]()
    
    func setID(id: String) {
        self.id = id
    }
    func getID() -> String {
        return self.id
    }
    
    func setIpAddress(ip_address: String) {
        self.ip_address = ip_address
    }
    func getIPAddress() -> String {
        return self.ip_address
    }
    
    func setHostedBy(hosted_by : String) {
        self.hosted_by = hosted_by
    }
    func getHostedBy() -> String {
        return self.hosted_by
    }
    
    func setPingMin(ping_min: String) {
        self.ping_max = ping_min
    }
    func getPingMin() -> String {
        return self.ping_min
    }
    
    func setPingAvg(ping_avg: String) {
        self.ping_avg = ping_avg
    }
    func getPingAvg() -> String {
        return self.ping_avg
    }
    
    func setPingMax(ping_max: String) {
        self.ping_max = ping_max
    }
    func getPingMax() -> String {
        return self.ping_max
    }
    
    
    func setPacketLoss(packet_loss: String) {
        self.packet_loss = packet_loss
    }
    func getPacketLoss() -> String {
        return self.packet_loss
    }
    
    func setDownload(download: String) {
        self.download = download
    }
    func getDownload() -> String {
        return self.download
    }
    
    
    func setUpload(upload: String) {
        self.upload = upload
    }
    func getUpload() -> String {
        return self.upload
    }
    
    func setPing(ping: String) {
        self.ping = ping
    }
    func getPing() -> String {
        return self.ping
    }
    
    func setNetType(net_type: String) {
        self.net_type = net_type
    }
    func getNetTye() -> String {
        return self.net_type
    }
    
    func setTestDate(test_date: String) {
        self.test_date = test_date
    }
    func getTestDate() -> String {
        return self.test_date
    }
    
    func setHostname(hostname: String) {
        self.hostname = hostname
    }
    func getHostname() -> String {
        return self.hostname
    }
    
    func setPingLoc(ping_loc: String) {
        self.ping_loc = ping_loc
    }
    func getPingLoc() -> String {
        return self.ping_loc
    }
    func setRouteArr(routeArr : [Route]) {
        self.routeArr = routeArr
    }
    func getRouteArr() -> [Route] {
        return self.routeArr
    }
}
