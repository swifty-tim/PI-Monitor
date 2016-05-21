//
//  AddTableViewController.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 14/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class AddTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var timerType : Bool = false
    var datePick : Bool = false
    var pickerDataSource = ["Heating", "Water"]
    var timerSchedule : Heater?
    var indexPath : NSIndexPath?
    var scheduleDayNo : Int?
    var update : Bool?
    var editIndexPath : NSIndexPath?
    var navTitle : String = "Add"
    
    @IBOutlet weak var heaterType: UIPickerView!
    @IBOutlet weak var heateTime: UIDatePicker!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "addCell")
        if self.timerSchedule == nil {
            self.update = false
            self.timerSchedule = Heater()
            self.timerSchedule!.setID(-1)
            self.timerSchedule!.setRecordEnabled(1)
            self.timerSchedule!.setDayNo(self.scheduleDayNo! + 1)
            self.timerSchedule!.setBoostUsed(0)
        } else {
            self.update = true
            self.navTitle = "Edit"
            var indexPath = NSIndexPath(forRow: 0, inSection: 0)
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.textLabel?.text = self.timerSchedule!.getHeaterType()
            indexPath = NSIndexPath(forRow: 0, inSection: 1)
            cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.detailTextLabel?.text = self.timerSchedule!.getTimerStart().toTimeString()
            indexPath = NSIndexPath(forRow: 1, inSection: 1)
            cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.detailTextLabel?.text = self.timerSchedule!.getTimerEnd().toTimeString()
        }
        
        self.heaterType.dataSource = self
        self.heaterType.delegate = self
        let addButton = UIBarButtonItem(title: self.navTitle, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.addNewSchedule))
        self.navigationItem.rightBarButtonItem = addButton

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNewSchedule() {
        
        let dic : [String : String] = [ "id": String(self.timerSchedule!.getID()),
                   "day_no": String(self.timerSchedule!.getDayNo()),
                   "record_enabled": String(self.timerSchedule!.getRecordEnabled()),
                   "boost_used": String(self.timerSchedule!.getBoostUsed()),
                   "heater_type" : self.timerSchedule!.getHeaterType(),
                   "heating_used": String(self.timerSchedule!.getHeatingUsed()),
                   "water_used": String(self.timerSchedule!.getWaterUsed()),
                   "time_start": self.timerSchedule!.getTimerStart().toTimeString(),
                   "time_end": self.timerSchedule!.getTimerEnd().toTimeString()
        ]
        
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"heater/send", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
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
                    self.performSegueWithIdentifier("unwindTime", sender: self)
                }
            })
        }

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "unwindTime" {
            
            let subVC: DayViewController = segue.destinationViewController as! DayViewController
            subVC.update = self.update!
            subVC.indexPath = self.editIndexPath!
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var result = 0
        if section == 0 {
            
            result = ( self.timerType == true ? 2 : 1 )

        } else if section == 1 {
            result = ( self.datePick == true ? 3 : 2 )
        }
        return result
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
         self.indexPath = indexPath
        
        if indexPath.section == 0 && indexPath.row == 0 {
           
            self.timerType = ( self.timerType ==  false ? true : false )
            
            /*if self.timerType  {
                self.timerType = false
            } else {
                self.timerType = true
            }*/
            self.tableView.reloadData()
        } else if indexPath.section == 1 && ( indexPath.row == 0 || indexPath.row == 1 ){
            //self.datePick == false ? true : false
            if self.datePick  {
                self.datePick = false
            } else {
                self.datePick = true
            }
            self.tableView.reloadData()
        }
    }
    @IBAction func heateTime(sender: AnyObject) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.stringFromDate(self.heateTime.date)
        let cell = self.tableView.cellForRowAtIndexPath(self.indexPath!)
        cell?.detailTextLabel?.text = strDate
        
        if self.indexPath?.row == 0 {
            self.timerSchedule?.setTimerStart(self.heateTime.date)
        } else {
            self.timerSchedule?.setTimerEnd(self.heateTime.date)
        }
        
    }
    
    
    /*override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("addCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.textLabel?.text = self.timerSchedule?.getHeaterType()
        } else {
            
        }
        
        return cell
        
    }*/
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddTableViewController {
    
    
    // MARK: UIPickerView DataSource and Delegate Methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row == 1 {
            self.timerSchedule?.setWaterUsed(0)
            self.timerSchedule?.setHeatingUsed(1)
        } else  {
            self.timerSchedule?.setWaterUsed(1)
            self.timerSchedule?.setHeatingUsed(0)
        }
        
        
        self.timerSchedule?.setHeaterType(self.pickerDataSource[row])
        let cell = self.tableView.cellForRowAtIndexPath(self.indexPath!)
        cell?.textLabel?.text = self.pickerDataSource[row]
        self.timerType = false
        self.tableView.reloadData()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerDataSource[row]
    }
}
extension NSDate {
    
    func toTimeString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }
}