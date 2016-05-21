//
//  DayViewController.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 01/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class DayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var itemIndex: Int = 0
    var titleName: String?
    var navBar : UINavigationController?
    var item : UINavigationItem?
    var todaySchedules = [Heater]()
    
    var filterView: ScheduleView?
    var isBlurred: Bool = false
    var savedBlurView: UIVisualEffectView?
    var dullView: UIView?
    var indexPath : NSIndexPath?
    var update : Bool?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navBar?.navigationBar.topItem?.title = self.titleName
        let newBackButton = UIBarButtonItem(title: "➕", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.addFilterView))
        self.item!.rightBarButtonItem = newBackButton
        
    }
    
    override func viewDidLayoutSubviews() {
    
        if let rect = self.navigationController?.navigationBar.frame {
            let y = rect.size.height + rect.origin.y
            self.tableView.contentInset = UIEdgeInsetsMake( y, 0, 0, 0)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "addSegue" {
            
            let subVC: AddTableViewController = segue.destinationViewController as! AddTableViewController
            subVC.scheduleDayNo = itemIndex
            
            if indexPath != nil {
                subVC.timerSchedule = self.todaySchedules[self.indexPath!.row]
                subVC.editIndexPath = self.indexPath!
            }
        }
    }
    
    //unwind segue function
    @IBAction func unwindToVC(segue:UIStoryboardSegue) {
        
        if(segue.sourceViewController .isKindOfClass(AddTableViewController))
        {
            let view2:AddTableViewController = segue.sourceViewController as! AddTableViewController
            
            if self.indexPath != nil {
                self.todaySchedules[self.indexPath!.row] = view2.timerSchedule!
                self.indexPath = nil
            } else {
                self.todaySchedules.append(view2.timerSchedule!)
            }
            
            self.tableView.reloadData()
        }
        
    }
    

    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.todaySchedules.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TimerTableViewCell
        cell.timerType.text = "  "+self.todaySchedules[indexPath.row].getHeaterType()
        cell.timerStart.text = "     "+self.todaySchedules[indexPath.row].getTimerStart().timeToString()
        cell.timerEnd.text = self.todaySchedules[indexPath.row].getTimerEnd().timeToString()
        
        if self.todaySchedules[indexPath.row].getRecordEnabled() == 0 {
            cell.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        if self.todaySchedules[self.indexPath!.row].getRecordEnabled() == 0 {
            self.heaterChange("Enable")
        } else {
            self.heaterChange("Disable")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}

extension DayViewController {
    
    
    func heaterChange( disableStr: String) {
        
        var controller: UIAlertController?
        
        controller = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet)
        
        
        let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler: {
            (action) -> Void in
            self.todaySchedules[self.indexPath!.row].setRecordEnabled(-1)
            self.editSchedule(self.indexPath!.row)
            self.indexPath = nil
            
        })
        let disableAction = UIAlertAction(title: disableStr, style: UIAlertActionStyle.Default, handler: {
            (action) -> Void in
            let cell = self.tableView.cellForRowAtIndexPath(self.indexPath!)
            cell?.backgroundColor = UIColor.lightGrayColor()
            if self.todaySchedules[self.indexPath!.row].getRecordEnabled() == 0 {
                self.todaySchedules[self.indexPath!.row].setRecordEnabled(1)
            } else {
                self.todaySchedules[self.indexPath!.row].setRecordEnabled(0)
            }
            self.editSchedule(self.indexPath!.row)
            self.indexPath = nil
            
        })
        let editAction = UIAlertAction(title: "Edit", style: UIAlertActionStyle.Default, handler: {
            (action) -> Void in
            self.performSegueWithIdentifier("addSegue", sender: nil)
        })

        let cancelAction = UIAlertAction(title:  "Cancel", style: UIAlertActionStyle.Cancel,
                                        handler: {(paramAction:UIAlertAction) in
            self.indexPath = nil
                                        
        })
        
        controller!.addAction(deleteAction)
        controller!.addAction(disableAction)
        controller!.addAction(editAction)
        controller!.addAction(cancelAction)
        
        // self.presentViewController(controller!, animated: true, completion: nil)
        
        if(UIDevice.currentDevice().userInterfaceIdiom  == .Pad) {
            
            let popOverController = UIPopoverController(contentViewController: controller!)
            
            let xPos = self.view.frame.width / 2
            let yPos = self.navigationController!.navigationBar.frame.origin.y + self.navigationController!.navigationBar.frame.height
            
            let popOverPosition = CGRect(x: xPos, y: yPos, width: 100, height: 100)
            
            
            popOverController.presentPopoverFromRect(popOverPosition, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Up, animated: true)
            
        } else  {
            
            self.presentViewController(controller!, animated: true, completion: nil)
            
        }
        
    }

}

extension DayViewController {
    
    func editSchedule(row : Int) {
        
        let timerSchedule = self.todaySchedules[row]
        let dic : [String : String] = [ "id": String(timerSchedule.getID()),
                                        "day_no": String(timerSchedule.getDayNo()),
                                        "record_enabled": String(timerSchedule.getRecordEnabled()),
                                        "boost_used": String(timerSchedule.getBoostUsed()),
                                        "heater_type" : timerSchedule.getHeaterType(),
                                        "heating_used": String(timerSchedule.getHeatingUsed()),
                                        "water_used": String(timerSchedule.getWaterUsed()),
                                        "time_start": timerSchedule.getTimerStart().toTimeString(),
                                        "time_end": timerSchedule.getTimerEnd().toTimeString()
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
                    if timerSchedule.getRecordEnabled() == -1 {
                        self.todaySchedules.removeAtIndex(row)
                    }
                    self.tableView.reloadData()
                }
            })
        }
        
        
    }

    
    
    func addFilterView() {
        self.performSegueWithIdentifier("addSegue", sender: nil)
//        self.addOrRemoveBlurrToView()
//        
//        self.filterView = ScheduleView()
//        self.filterView!.frame = CGRect(x: 5, y: self.view.frame.height, width: self.view.frame.width - 10 , height: self.view.frame.height * 0.6)
//        self.navigationController!.view.addSubview(self.filterView!)
//        
//        UIView.animateWithDuration(0.8, animations: { () -> Void in
//            
//            self.filterView!.frame = CGRect(x: 5, y: self.view.frame.height * 0.4, width: self.view.frame.width - 10, height: self.view.frame.height * 0.6)
//            self.view.bringSubviewToFront(self.filterView!)
//        })
//        
//        
//        let swipDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipFilterView))
//        swipDownGesture.direction = .Down
//        self.filterView!.addGestureRecognizer(swipDownGesture)
        
    }
    
    func addOrRemoveBlurrToView() {
        
        if !isBlurred {
            self.dullView = UIView(frame: UIScreen.mainScreen().bounds)
            self.dullView!.backgroundColor = UIColor.blackColor()
            self.dullView!.alpha = 0.4
            
            self.navBar!.view.addSubview(self.dullView!)
            
            
            isBlurred = true
        } else {
            self.dullView?.removeFromSuperview()
            
            isBlurred = false
        }
        
    }
    
    func swipFilterView(recognizer: UISwipeGestureRecognizer) {
        self.addOrRemoveBlurrToView()
        self.dismissFilterView()
    }
    func dismissFilterView() {
        //println("Starting...")
        
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            
            self.filterView!.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height / 2)
            
        }) { (complete) -> Void in
            //self.timerUsed = self.filterView!.returnHotWaterSwitch()
            self.filterView!.removeFromSuperview()
        }
    }


}

extension NSDate {
    
    func timeToString() ->String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let dateString = dateFormatter.stringFromDate(self)
        return dateString
    }
}
