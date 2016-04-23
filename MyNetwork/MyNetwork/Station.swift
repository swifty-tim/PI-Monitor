//
//  Station.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 23/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import Foundation
import MapKit

class Station: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude:Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}