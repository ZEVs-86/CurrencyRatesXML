//
//  Utils.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 4/11/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import Foundation

class Utils {
    
    
    static func getDataFromUrl(url: String, callback: (data: NSData?, url: String) -> Void) {
        if let nsurl = NSURL(string: url) {
            NSURLSession.sharedSession().dataTaskWithURL(nsurl) {
                (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    callback(data: data, url: url)
                })
                }.resume()
        }
    }
   
    static func getDataFromUrlWithParam(url: String, param: String?, callback: (data: NSData?, param: String?) -> Void) {
        if let nsurl = NSURL(string: url) {
            NSURLSession.sharedSession().dataTaskWithURL(nsurl) {
                (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    callback(data: data, param: param)
                })
                }.resume()
        }
    }
    
}