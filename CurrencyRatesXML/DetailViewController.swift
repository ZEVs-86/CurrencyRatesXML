//
//  DetailViewController.swift
//  CurrencyRatesXML
//
//  Created by Evgeny Zakharov on 4/1/16.
//  Copyright © 2016 Evgeny Zakharov. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var googleMap: UIView!
    //@IBOutlet weak var detailMap: MKMapView!
    var bankName = String()
    var bankAddresses = [String]()
    var markers = [GMSMarker]()
    var mapPoints: [MapPoints] = []
    
    
    func getLatLngForZip(address: String) {
        let addressForUrl = address.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let appD = UIApplication.sharedApplication().delegate as! AppDelegate
        let url = "\(appD.googleMapsGeocoderUrl)address=\(addressForUrl)&key=\(appD.googleMapsKey)"
        Utils.getDataFromUrlWithParam(url, param:address, callback: parseGeocoderResult)
    }
    

    
    
    func parseGeocoderResult(data: NSData?, param: String?) {
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
            if let geometry = result[0]["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    let latitude = location["lat"] as! Double
                    let longitude = location["lng"] as! Double
                    
                    let marker = GMSMarker()
                    marker.position.longitude = longitude
                    marker.position.latitude = latitude
                    markers.append(marker)
                    
                    for point in mapPoints {
                        if point.address == param {
                            point.lat = latitude
                            point.lon = longitude
                            point.ready = true
                        }
                    }
                    
                    for point in mapPoints {
                        if point.ready == false {
                            break
                        }
                    }
                    
                    print("marker added: \(latitude), \(longitude)")

                    if checkPointsLoaded(mapPoints) {
                        print("all point loaded")
                        showPoints()
                    }

                }
            }
        }
    }
    
    
    func checkPointsLoaded(arData: [MapPoints]) -> Bool {
        for item in arData {
            if item.ready == false {
                return false
            }
        }
        return true
    }
    
    
    
    
    
    func showPoints() {
        
        // show points on map
        
        let camera = GMSCameraPosition.cameraWithLatitude(41.887, longitude: -87.622, zoom: 12)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        var bounds = GMSCoordinateBounds()
        
        mapView.mapType = kGMSTypeNormal
        
        for point in mapPoints {
            let marker = GMSMarker()
            marker.position.latitude = point.lat
            marker.position.longitude = point.lon
            marker.snippet = "VTB24"
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = mapView

            bounds = bounds.includingCoordinate(marker.position)
        }
       
        
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
        self.view = mapView
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for address in bankAddresses {
            let point = MapPoints(address: address)
            mapPoints.append(point)
            getLatLngForZip(address)
        }
        
    }
    
}