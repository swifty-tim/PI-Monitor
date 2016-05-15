//
//  PageViewController.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 02/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class PageViewController: UIViewController, UIPageViewControllerDataSource {

    
    // MARK: - Variables
    private var pageViewController: UIPageViewController?
    private var heaterSchedules = [AllTimers]()
    
    // Initialize it right away here
    private let contentImages = ["Monday",
                                 "Tuesday",
                                 "Wednesday",
                                 "Thursday",
                                 "Friday",
                                 "Saturday",
                                 "Sunday"];
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.goBack))
        self.navigationItem.leftBarButtonItem = newBackButton;
        //createPageViewController()
        self.getHeaterValues()
        
    }
    func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func getHeaterValues() {
        
        let dic = [String: String]()
        let networkURL = NSBundle.mainBundle().objectForInfoDictionaryKey("Home URL") as! String
        HTTPConnection.getPingResults(dic, url: networkURL+"heater/get", httpMethod: "POST") { (succeeded: Bool, data: NSData) -> () in
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
                    self.createPageViewController()
                    self.setupPageControl()
                }
            })
        }
        
    }

    
    private func createPageViewController() {
        
        let pageController = self.storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageController.dataSource = self
        
        if heaterSchedules.count > 0 {
            let firstController = getItemController(0)!
            
            //self.navigationController?.navigationBar.topItem?.title = self.contentImages[0]
            let startingViewControllers: NSArray = [firstController]
            pageController.setViewControllers(startingViewControllers as? [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
            
        }
        
        pageViewController = pageController
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.grayColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.darkGrayColor()
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! DayViewController
        
        if itemController.itemIndex > 0 {
            return getItemController(itemController.itemIndex-1)
        }
        
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let itemController = viewController as! DayViewController
        
        if itemController.itemIndex + 1 < contentImages.count {
            return getItemController(itemController.itemIndex+1)
        }
        6
        return nil
    }
    
    private func getItemController(itemIndex: Int) -> DayViewController? {
        
        if itemIndex < self.heaterSchedules.count &&  self.heaterSchedules.count > 0 {
            
            let pageItemController = self.storyboard!.instantiateViewControllerWithIdentifier("Day") as! DayViewController
            pageItemController.itemIndex = itemIndex
            pageItemController.titleName = contentImages[itemIndex]
            pageItemController.navBar = self.navigationController
            pageItemController.item = self.navigationItem
            pageItemController.todaySchedules = self.heaterSchedules[itemIndex].getDatTimer()
            //self.navigationController?.navigationBar.topItem?.title = self.contentImages[itemIndex]
            return pageItemController
        }
        
        return nil
    }
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contentImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
