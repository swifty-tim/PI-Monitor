//
//  Segments.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 14/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import Foundation
import UIKit

class Segements {
    
    var shape : CAShapeLayer?
    var boost : Int = -1
    
    func setShape( shape : CAShapeLayer ) {
        self.shape = shape
    }
    func getShape() -> CAShapeLayer {
        return self.shape!
    }
    
    func setBoost( boost : Int) {
        self.boost = boost
    }
    func getBoost() -> Int {
        return self.boost
    }
    
}
