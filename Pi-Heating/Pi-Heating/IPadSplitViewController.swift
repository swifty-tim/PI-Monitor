//
//  IPadSplitViewController.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 08/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class IPadSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         splitViewController?.preferredDisplayMode = .PrimaryOverlay

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
