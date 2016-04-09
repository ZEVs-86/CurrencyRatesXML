//
//  ViewController.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 3/24/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate {

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
    var currentUrl: String?
    var tempUrl: String = ""
    
    var lastTag = NSString()
    var currentCurrency = NSString()
    var currentOperation = NSString()
    
    var getAddressesByUrl = [String: [String]]()
    
    var htmlRequestStarted: Bool = false
    
    var alert = UIAlertController(title: "Loading data", message: "Please wait...", preferredStyle: UIAlertControllerStyle.Alert)
    var alertNoUrl = UIAlertController(title: "No addresses for this bank!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)

    
    @IBOutlet weak var loadDataButton: UIButton!
    @IBOutlet weak var resultTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // no-url-alert action
        alertNoUrl.addAction(okAction)
    }
    
    
    // check array of banks fully loaded 
    func checkBanksLoaded(arData: [Banks]) -> Bool {
        for item in arData {
            if item.ready == false {
                return false
            }
        }
        return true
    }
    
    
    func addAddressToBankByUrl(url: String, address: String) {
        for bank in arData {
            if bank.url == url {
                bank.addresses.append(address)
                bank.ready = true
                
                if checkBanksLoaded(arData) {
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
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
        if let name = arData[row].name {
            cell.textLabel?.text = name
            cell.detailTextLabel?.text = "USD: \(arData[row].usdBuy)/\(arData[row].usdSell) EUR: \(arData[row].eurBuy)/\(arData[row].eurSell)"
        }
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func getHtmlFromUrl(url: String, callback: (data: NSData?, url: String) -> Void) {
        if let nsurl = NSURL(string: url) {
            NSURLSession.sharedSession().dataTaskWithURL(nsurl) {
                (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    callback(data: data, url: url)
                })
            }.resume()
        }
    }
    
    
    func getAddressesFromHtml(data: NSData?, url: String) {
        let doc = TFHpple(HTMLData: data)
        let elements = doc.searchWithXPathQuery("//tr[@class='br-head']/following-sibling::tr[1]/*[2]")
        for element in elements {
            addAddressToBankByUrl(url, address: element.content)
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
                self.resultTableView.reloadData()
            } else {
                print("!!! parsing fucked up!")
            }
        }
    }
    
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
            let bank = Banks(name: currentName, url: currentUrl, usdBuy: currentUsdBuy, usdSell: currentUsdSell, eurBuy: currentEurBuy, eurSell: currentEurSell)
            // if has url - get adresses
            if !(bank.url?.isEmpty)! {
                htmlRequestStarted = true
                getHtmlFromUrl(bank.url!, callback: getAddressesFromHtml)
            }
            arData.append(bank)
        }
        
        if elementName == "Url" {
            currentUrl = tempUrl
            tempUrl = ""
        }
    }

    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
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
        
        if lastTag == "Url" {
            if !string.isEmpty {
                tempUrl += prepareStringValue(string)!
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
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "DetailSegue" {
            let indexPath = resultTableView.indexPathForSelectedRow
            if let url = arData[indexPath!.row].url {
                if url.isEmpty {
                    self.presentViewController(alertNoUrl, animated: true, completion: nil)
                } else {
                    print("getting addresses from \(url)")
                    print(arData[indexPath!.row].addresses)
                    print(arData[indexPath!.row])
                    return true
                }
            }
        }
        return false
    }
        
    
    
    
    /*override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/


}

