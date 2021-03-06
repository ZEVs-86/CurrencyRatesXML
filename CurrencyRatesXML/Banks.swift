//
//  Banks.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 3/29/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import Foundation

class Banks {
    
    var name: String?
    var url: String?
    var addresses = [String]()
    var markers = [MapPoints]()
    var usdBuy: Float
    var usdSell: Float
    var eurBuy: Float
    var eurSell: Float
    var ready: Bool!
    
    init(name: String?, url: String?, usdBuy: Float, usdSell: Float, eurBuy:Float, eurSell: Float) {
        self.name = name
        self.url = url
        self.usdBuy = usdBuy
        self.usdSell = usdSell
        self.eurBuy = eurBuy
        self.eurSell = eurSell
        
        if !(url?.isEmpty)! {
            self.ready = false
        } else {
            self.ready = true
        }
    }
    
    
    
}