//
//  ViewController.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 3/24/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, NSXMLParserDelegate, UITableViewDelegate, UITableViewDataSource {

    struct bank {
        var bankName: NSString = ""
        var usdBuy: Float = 0
        var usdSell: Float = 0
        var eurBuy: Float = 0
        var eurSell: Float = 0
    }
    var xmlParser = NSXMLParser()
    var arData: [bank] = []
    var currentBankItem = bank()
    
    var lastTag = NSString()
    var currentCurrency = NSString()
    var currentOperation = NSString()

    var items: [String] = ["We", "Heart", "Swift"]
    
    @IBOutlet weak var loadDataButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        resultTableView.delegate = self
        resultTableView.dataSource = self
    }
    
    func goParsing() {
        print("go parsing...")
        
        arData = []
        let url = NSURL(string: "http://informer.kovalut.ru/webmaster/xml-table.php?kod=7601")
        xmlParser = NSXMLParser(contentsOfURL: url!)!
        xmlParser.delegate = self
        if xmlParser.parse() {
            print("parsing ok\n")
            //print(arData)
        } else {
            print("parsing fucked up!")
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
            arData.append(currentBankItem)
            
            //print(currentBankItem)
            
            currentBankItem = bank()
        }
        
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
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        //print("last tag: \(Float(ststring))\n")
        
        if lastTag == "Buy" {
            if !string.isEmpty {
                
                let val = prepareFloatValue(string)
                
                if currentCurrency == "USD" {
                    if val > 0 {
                        currentBankItem.usdBuy = val!
                    }
                    //print("string: '\(string)'\n")
                } else {
                    if val > 0 {
                        currentBankItem.eurBuy = val!
                    }
                }
            }
        }
        
        if lastTag == "Sell" {
            if !string.isEmpty {
                
                let val = prepareFloatValue(string)
                
                if currentCurrency == "USD" {
                    if val > 0 {
                        currentBankItem.usdSell = val!
                    }
                } else {
                    if val > 0 {
                        currentBankItem.eurSell = val!
                    }
                }
            }
        }
        
        
        if lastTag == "Name" {
            let str = prepareStringValue(string)
            if !str!.isEmpty {
                currentBankItem.bankName = str!
            }
        }
    
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("parse error \(parseError)")
    }

    

    @IBAction func loadDataButtonPressed(sender: AnyObject) {
    
        goParsing()
        
        self.resultTableView.reloadData()
    
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultTableViewCell", forIndexPath: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = arData[row].bankName as String
        cell.detailTextLabel?.text = "USD: \(arData[row].usdBuy)/\(arData[row].usdSell) EUR: \(arData[row].eurBuy)/\(arData[row].eurSell)"
        
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print(items[row])
    }
    
        
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

