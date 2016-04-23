//
//  MapViewController.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 19/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var routeArr = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var annotations = [Station]()
        self.mapView.delegate = self
        
        
        for route in routeArr {
            
            let lat_long = route.getCoord()
            if lat_long != "" {
                let longLats = lat_long.characters.split{$0 == ","}.map(String.init)
                let latitude = Double(longLats[0].trim())
                let longitude = Double(longLats[1].trim())
                let newStation = Station(latitude: latitude!, longitude: longitude!)
                annotations.append(newStation)
            }
        }
        
        
       mapView.addAnnotations(annotations)

        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        //points.append(newYorkLocation)
        
        for annotation in annotations {
            points.append(annotation.coordinate)
        }
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        mapView.addOverlay(polyline)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
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
extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}
