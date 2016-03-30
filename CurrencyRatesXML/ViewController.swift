//
//  ViewController.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 3/24/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, NSXMLParserDelegate {

    /*struct bank {
        var bankName: NSString = ""
        var usdBuy: Float = 0
        var usdSell: Float = 0
        var eurBuy: Float = 0
        var eurSell: Float = 0
    }*/
    var xmlParser = NSXMLParser()
    var arData: [Banks] = []
    //var currentBankItem: Banks
    
    var currentName: String = "";
    var currentUsdBuy: Float = 0.0;
    var currentUsdSell: Float = 0.0;
    var currentEurBuy: Float = 0.0;
    var currentEurSell: Float = 0.0;
    
    var lastTag = NSString()
    var currentCurrency = NSString()
    var currentOperation = NSString()

    var items: [String] = ["We", "Heart", "Swift"]
    
    var alert = UIAlertController(title: "Loading data", message: "Please wait...", preferredStyle: UIAlertControllerStyle.Alert)
    
    @IBOutlet weak var loadDataButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //currentBankItem = Banks(name: "", usdBuy: 0, usdSell: 0, eurBuy: 0, eurSell: 0)
        
        //resultTableView.delegate = BanksTableViewController.self as? UITableViewDelegate
        //resultTableView.dataSource = BanksTableViewController.self as? UITableViewDataSource
    }
    
    func getDataFromUrl(url: String, callback: (data: NSData?) -> Void) {
        if let url = NSURL(string: url) {
            NSURLSession.sharedSession().dataTaskWithURL(url) {
                (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    callback(data: data)
                })
                
            }.resume()
        }
    }

    
    func parseXmlData(data: NSData?) {
        print("go parsing...")
        
        arData = []
        
        if data === nil {
            print("!!! no data loaded!")
        } else {
        
            xmlParser = NSXMLParser(data: data!)//  (contentsOfURL: url!)!
            xmlParser.delegate = self
            if xmlParser.parse() {
                print("parsing ok\n")
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                self.resultTableView.reloadData()
            } else {
                print("!!! parsing fucked up!")
            }
            
        }
        
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //print("element: \(elementName) \(qName)\n")
        
        lastTag = elementName
        
        switch(elementName) {
            case "USD":
                currentCurrency = "USD"
                break;
            case "EUR":
                currentCurrency = "EUR"
                break;
            default:
                break;
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
        // bank is over - add bank and reset current struct
        if elementName == "Bank" {
            
            let bank = Banks(name: currentName, usdBuy: currentUsdBuy, usdSell: currentUsdSell, eurBuy: currentEurBuy, eurSell: currentEurSell)
            arData.append(bank)
         
            
            //print(bank.name)

        }
        
    }

    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        //print("last tag: \(Float(ststring))\n")
        
        if lastTag == "Buy" {
            if !string.isEmpty {
                
                let val = prepareFloatValue(string)
                
                if currentCurrency == "USD" {
                    if val > 0 {
                        currentUsdBuy = val!
                    }
                    //print("string: '\(string)'\n")
                } else {
                    if val > 0 {
                        currentUsdSell = val!
                    }
                }
            }
        }
        
        if lastTag == "Sell" {
            if !string.isEmpty {
                
                let val = prepareFloatValue(string)
                
                if currentCurrency == "USD" {
                    if val > 0 {
                        currentEurBuy = val!
                    }
                } else {
                    if val > 0 {
                        currentEurSell = val!
                    }
                }
            }
        }
        
        
        if lastTag == "Name" {
            let str = prepareStringValue(string)
            if !str!.isEmpty {
                currentName = str!
            }
        }
    
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("parse error \(parseError)")
    }

    
    func prepareFloatValue(str: String) -> Float? {
        var str = str.stringByReplacingOccurrencesOfString("\n", withString: "")
        str = str.stringByReplacingOccurrencesOfString("\t", withString: "")
        str = str.stringByReplacingOccurrencesOfString(" ", withString: "")
        str = str.stringByReplacingOccurrencesOfString(",", withString: ".")
        return Float(str)
    }
    
    func prepareStringValue(str: String) -> String? {
        var str = str.stringByReplacingOccurrencesOfString("\n", withString: "")
        str = str.stringByReplacingOccurrencesOfString("\t", withString: "")
        str = str.stringByReplacingOccurrencesOfString(" ", withString: "")
        return str
    }
    

    @IBAction func loadDataButtonPressed(sender: AnyObject) {
    
        self.presentViewController(alert, animated: true, completion: nil)
        let url = "http://informer.kovalut.ru/webmaster/xml-table.php?kod=7601"
        getDataFromUrl(url, callback: parseXmlData)

    }

        
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

