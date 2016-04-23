//
//  RouteTableViewController.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 18/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class RouteTableViewController: UITableViewController {
    
    var networkID : String = ""
    var backButton: UIBarButtonItem?
    var routeArr = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: #selector(self.buttonMethod))
        navigationItem.rightBarButtonItem = refreshButton
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh), forControlEvents: UIControlEvents.ValueChanged)
        
        self.handleRefresh()
    }
    
    
    func handleRefresh() {
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Network URL") as! String
        let dic = [String: String]()
        HTTPConnection.getPingResults(dic, url: networkURL+"type=1&route="+networkID, httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if (!succeeded) {
                    let alert = UIAlertController(title: "Oops!", message:"No data found", preferredStyle: .Alert)
                    let action = UIAlertAction(title: "OK", style: .Default) { _ in
                        self.refreshControl!.endRefreshing()
                    }
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true){}
                    
                } else {
                    
                    self.routeArr = HTTPConnection.parseJSONRoute(data)
                    self.tableView.reloadData()
                    self.refreshControl!.endRefreshing()
                    //println(msg)
                }
            })
        }

    }
    
    func buttonMethod() {
        self.performSegueWithIdentifier("mapSegue", sender: "")
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
        return self.routeArr.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("routeCell", forIndexPath: indexPath) as! SpeedTableViewCell
        cell.cellHeader.text = self.routeArr[indexPath.row].getIP()
        cell.cellLeftTop.text = self.routeArr[indexPath.row].getTestDate()
        cell.cellRightTop.text = self.routeArr[indexPath.row].getLoc()
        if self.routeArr[indexPath.row].rtt.count > 2 {
            cell.cellLeftTop.text! = self.routeArr[indexPath.row].rtt[0]
            cell.cellLeftBottom.text = "Ping: "+self.routeArr[indexPath.row].rtt[1]
            cell.cellRightTop.text! = "Upload: "+self.routeArr[indexPath.row].rtt[2]
        }
        return cell
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

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "mapSegue" {
            
            let subVC: MapViewController = segue.destinationViewController as! MapViewController
            subVC.routeArr = self.routeArr
        }
        
    }

}
