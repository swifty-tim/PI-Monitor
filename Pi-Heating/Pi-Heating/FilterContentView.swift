//
//  FilterContentView.swift
//  Motor Spy
//
//  Created by Timothy Barnard on 01/08/2015.
//  Copyright (c) 2015 Timothy Barnard. All rights reserved.
//

import UIKit

class FilterContentView: UIView {
    
    var screenWidth = UIScreen.mainScreen().bounds.size.width
    var screenHeight = UIScreen.mainScreen().bounds.size.height
    internal var titleLabel: UILabel?
    internal var centralHeating : UISwitch?
    internal var hotWater : UISwitch?
    internal var pumpSwitch: UISwitch?
    
    init() {
        super.init(frame: CGRectMake(5,0, screenWidth - 10, screenHeight * 0.6 ))
        self.backgroundColor = UIColor.whiteColor()
        self.loadUI()
    }
    
    func loadUI() {
        
        var yValue: CGFloat?
        let xValue : CGFloat = self.frame.width / 4
        
        // Set attributes for alertMessage which is just a UILabel
        self.titleLabel = UILabel(frame: CGRectMake(0 , 0, self.frame.width * 0.6, 40))
        self.titleLabel!.center = CGPoint(x: self.frame.width / 2, y: 0)
        self.titleLabel?.textAlignment = .Center
        self.titleLabel!.clipsToBounds = true
        self.titleLabel!.layer.cornerRadius = self.titleLabel!.frame.height / 3
        self.titleLabel?.font = UIFont(name: "Avenir Next", size: 20)
        self.titleLabel?.textColor = UIColor.whiteColor()
        self.titleLabel?.backgroundColor = UIColor(red: 110.0/255.0, green: 197.0/255.0, blue: 233.0/255.0, alpha: 1)
        self.titleLabel?.text = "Controller"
        self.addSubview(titleLabel!)
        
        yValue = self.titleLabel!.frame.origin.y + self.titleLabel!.frame.height + 40
        
        let label1: UILabel = UILabel(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        label1.center = CGPoint(x: xValue * 2, y: yValue!)
        label1.text = "Hot Water"
        label1.font = UIFont(name: "Avenir Next", size: 20)
        self.addSubview(label1)
        
        self.centralHeating = UISwitch(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        self.centralHeating!.center = CGPoint(x: xValue * 3, y: yValue!)
        self.centralHeating!.on = true
        self.centralHeating!.setOn(true, animated: false);
        self.centralHeating!.transform = CGAffineTransformMakeScale(1.6, 1.6);
        //self.centralHeating!.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.addSubview(self.centralHeating!);
        
        yValue = self.centralHeating!.frame.origin.y + self.centralHeating!.frame.height + 40
        
        let label2: UILabel = UILabel(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        label2.center = CGPoint(x: xValue * 2, y: yValue!)
        label2.text = "Heating"
        label2.font = UIFont(name: "Avenir Next", size: 20)
        self.addSubview(label2)
        
        self.hotWater = UISwitch(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        self.hotWater!.center = CGPoint(x: xValue * 3, y: yValue!)
        self.hotWater!.on = true
        self.hotWater!.setOn(true, animated: false);
        self.hotWater!.transform = CGAffineTransformMakeScale(1.6, 1.6);
        self.addSubview(self.hotWater!);
        
        
        yValue = self.hotWater!.frame.origin.y + self.hotWater!.frame.height + 40
        
        let label3: UILabel = UILabel(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        label3.center = CGPoint(x: xValue * 2, y: yValue!)
        label3.text = "Pump"
        label3.font = UIFont(name: "Avenir Next", size: 20)
        self.addSubview(label3)
        
        self.pumpSwitch = UISwitch(frame: CGRect(x: 0, y: yValue!, width: self.frame.width * 0.8, height: 40))
        self.pumpSwitch!.center = CGPoint(x: xValue * 3, y: yValue!)
        self.pumpSwitch!.on = true
        self.pumpSwitch!.setOn(true, animated: false);
        self.pumpSwitch!.transform = CGAffineTransformMakeScale(1.6, 1.6);
        //self.centralHeating!.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.addSubview(self.pumpSwitch!);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func returnPumpSwitch()->Bool {
        return self.pumpSwitch!.on
    }
    func returnHotWaterSwitch()->Bool {
        return self.hotWater!.on
    }
    
    func returnHeatingSwitch()->Bool {
        return self.centralHeating!.on
    }
    
    func setPumpSwitchState(state : Bool) {
        self.pumpSwitch?.on = state
    }
    func setHotWaterSwitch(state : Bool) {
        self.hotWater?.on = state
    }
    func setHeatingSwitch(state : Bool) {
        self.centralHeating?.on = state
    }
}

