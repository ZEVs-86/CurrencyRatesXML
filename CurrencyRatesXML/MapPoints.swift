//
//  MapPoints.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 4/12/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import Foundation

class MapPoints {
    
    var lat = Double()
    var lon = Double()
    var title = String?()
    var address = String?()
    var ready = Bool()
    
    init(address: String?) {
        self.address = address
        self.ready = false
    }
    
    
}