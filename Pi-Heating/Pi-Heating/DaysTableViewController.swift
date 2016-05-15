//
//  DaysTableViewController.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 08/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class DaysTableViewController: UITableViewController {

    // Initialize it right away here
    private let days = ["Monday",
                                 "Tuesday",
                                 "Wednesday",
                                 "Thursday",
                                 "Friday",
                                 "Saturday",
                                 "Sunday"];
    private var heaterSchedules = [AllTimers]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getHeaterValues()
        self.tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBAction func goBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    
    func getHeaterValues() {
        
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"heater", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
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
                    //print (NSString(data: data, encoding: NSUTF8StringEncoding) )
                    self.heaterSchedules = HTTPConnection.parseJSON(data)
                    self.tableView.reloadData()
                }
            })
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.heaterSchedules.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("ShowDetailIdentifier", sender: indexPath.row)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dayCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.days[indexPath.row]

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowDetailIdentifier") {
            var detail: DayTableViewController
            
            if let navigationController = segue.destinationViewController as? UINavigationController {
                detail = navigationController.topViewController as! DayTableViewController
                
            } else {
                detail = segue.destinationViewController as! DayTableViewController
            }
            
            if let path = tableView.indexPathForSelectedRow {
                detail.itemIndex = path.row + 1
                detail.todaySchedules = self.heaterSchedules[path.row].getDatTimer()
                detail.titleName = self.days[path.row]
            }
        }
    }


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
