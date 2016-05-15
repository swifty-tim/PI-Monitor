//
//  Heater.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 08/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//
import Foundation

class AllTimers {
    
    var dayTimer : [Heater]?
    
    func setDayTimer(dayTimer: [Heater]) {
        self.dayTimer = dayTimer
    }
    func getDatTimer() -> [Heater] {
        return self.dayTimer!
    }
}


class Heater {
    var id: Int = -1
    var day_no : Int = -1
    var record_enabled : Int = 0
    var boost_used : Int = 0
    var heating_used : Int = 0
    var water_used : Int = 0
    var heater_type : String = ""
    var test_date : NSDate?
    var time_start : NSDate?
    var time_end : NSDate?
    
    
    func setID(id: Int) {
        self.id = id
    }
    func getID() -> Int {
        return self.id
    }
    
    func setDayNo(day_no : Int) {
        self.day_no = day_no
    }
    func getDayNo() -> Int {
        return self.day_no
    }
    
    func setRecordEnabled(record_enabled : Int) {
        self.record_enabled = record_enabled
    }
    func getRecordEnabled() -> Int {
        return self.record_enabled
    }
    
    func setHeatingUsed(heating_used: Int) {
        self.heating_used = heating_used
    }
    func getHeatingUsed() -> Int {
        return self.heating_used
    }
    
    func setWaterUsed(water_used: Int) {
        self.water_used = water_used
    }
    func getWaterUsed() -> Int {
        return self.water_used
    }
    
    func setBoostUsed(boost_used: Int) {
        self.boost_used = boost_used
    }
    func getBoostUsed() -> Int {
        return self.boost_used
    }
    
    func setHeaterType(heater_type: String) {
        self.heater_type = heater_type
    }
    func getHeaterType() -> String {
        return self.heater_type
    }
    
    
    func setTimerStart(time_start: NSDate) {
        self.time_start = time_start
    }
    func getTimerStart() -> NSDate {
        return self.time_start!
    }
    
    func setTimerEnd(time_end: NSDate) {
        self.time_end = time_end
    }
    func getTimerEnd() -> NSDate {
        return self.time_end!
    }
    

    func setTestDate(test_date: NSDate) {
        self.test_date = test_date
    }
    func getTestDate() -> NSDate {
        return self.test_date!
    }
    
}