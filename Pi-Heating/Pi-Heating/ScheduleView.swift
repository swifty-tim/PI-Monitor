//
//  ScheduleView.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 05/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class ScheduleView: UIView {

    var screenWidth = UIScreen.mainScreen().bounds.size.width
    var screenHeight = UIScreen.mainScreen().bounds.size.height
    internal var titleLabel: UILabel?
    internal var countryTextField : UITextField?
    internal var countyTextField: UITextField?
    internal var searchButton: UIButton?
    //internal var pickerView: UIPickerView?
    internal var pickerView: UIDatePicker?
    
    
    var buttonYValue: CGFloat?
    
    var textFieldPicker: Bool = false
    
    init() {
        super.init(frame: CGRectMake(5,0, screenWidth - 10, screenHeight * 0.6 ))
        self.backgroundColor = UIColor.whiteColor()
        self.loadUI()
        
        // self.getStringsFromDatabase("location", whereString: "", modelString: "", json: "carLocationCountry")
    }
    
    func loadUI() {
        
        var yValue: CGFloat?
        
        // Set attributes for alertMessage which is just a UILabel
        self.titleLabel = UILabel(frame: CGRectMake(0 , 0, self.frame.width * 0.6, 40))
        self.titleLabel!.center = CGPoint(x: self.frame.width / 2, y: 0)
        self.titleLabel?.textAlignment = .Center
        self.titleLabel!.clipsToBounds = true
        self.titleLabel!.layer.cornerRadius = self.titleLabel!.frame.height / 3
        self.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.titleLabel?.backgroundColor = UIColor(red: 110.0/255.0, green: 197.0/255.0, blue: 233.0/255.0, alpha: 1)
        self.titleLabel?.text = "Schedule"
        self.addSubview(titleLabel!)
        
        yValue = self.titleLabel!.frame.origin.y + self.titleLabel!.frame.height + 40
        
        self.countryTextField = UITextField(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        self.countryTextField?.center = CGPoint(x: self.frame.width / 2, y: yValue!)
        self.countryTextField?.placeholder = "Country"
        self.countryTextField?.textAlignment = .Center
        self.countryTextField?.layer.borderWidth = 0.5
        self.countryTextField?.borderStyle = UITextBorderStyle.RoundedRect
        //self.countryTextField!.delegate = self
        self.addSubview(countryTextField!)
        
        yValue = self.countryTextField!.frame.origin.y + self.countryTextField!.frame.height + 40
        
        self.countyTextField = UITextField(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        self.countyTextField?.center = CGPoint(x: self.frame.width / 2, y: yValue!)
        self.countyTextField?.placeholder = "County"
        self.countyTextField?.textAlignment = .Center
        self.countyTextField?.layer.borderWidth = 0.5
        self.countyTextField?.borderStyle = UITextBorderStyle.RoundedRect
        //self.countyTextField!.delegate = self
        self.addSubview(countyTextField!)
        
        buttonYValue = self.countyTextField!.frame.origin.y + self.countyTextField!.frame.height + 40
        
        self.pickerView = UIDatePicker(frame: CGRect(x: 0, y: self.frame.height * 0.5 , width: self.frame.width, height: 200))
        self.pickerView!.datePickerMode = UIDatePickerMode.Time // 4- use time only
        let currentDate = NSDate()  //5 -  get the current date
        self.pickerView!.minimumDate = currentDate  //6- set the current date/time as a minimum
        self.pickerView!.date = currentDate //7 - defaults to current time but shows how to use it.

        //self.pickerView!.delegate = self
        //self.pickerView!.dataSource = self
        //self.pickerView!.hidden = false
        self.addSubview(pickerView!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func returnCounty()->String {
        return self.countyTextField!.text!
    }
    func returnCountry()->String {
        return self.countryTextField!.text!
    }
    
    func setTitle(title:String) {
        self.titleLabel?.text = title
    }
    func setCountryPlaceHolder(placeholder:String) {
        self.countryTextField?.placeholder = placeholder
    }
    func setCountyPlaceHolder(placeholder:String) {
        self.countyTextField?.placeholder = placeholder
    }
    
    func setCountryField(name:String) {
        
        self.countryTextField?.text = name
    }
    
    func setCountyField(name:String) {
        self.countyTextField?.text = name
    }
    
    func clearFields() {
        self.countyTextField?.text = ""
        self.countryTextField?.text = ""
    }
    
}
extension ScheduleView: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(colorPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return self.locationStrings.count
        return 10
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        /*if(self.textFieldPicker) {
            self.countryTextField!.text = self.locationStrings[row]
            
        } else {
            
            self.countyTextField!.text = self.locationStrings[row]
        }*/
        
    }
}

extension ScheduleView: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return "Timothy"
    }
}

extension ScheduleView {
    
}
