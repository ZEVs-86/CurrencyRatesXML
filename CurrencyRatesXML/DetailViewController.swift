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
    var mapPoints: [MapPoints] = []
    var mapView: GMSMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view did load")
        
        var markerList = [GMSMarker]()

        let camera = GMSCameraPosition.cameraWithLatitude(41.887, longitude: -87.622, zoom: 20)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        //var bounds = GMSCoordinateBounds()
        
        for point in mapPoints {
            let marker = GMSMarker()
            marker.position.latitude = point.lat
            marker.position.longitude = point.lon
            marker.title = point.address
            marker.map = mapView
            markerList.append(marker)
            //bounds = bounds.includingCoordinate(marker.position)
        }
        
        self.view = mapView
            var bounds = GMSCoordinateBounds()
            
            for marker in markerList {
                bounds = bounds.includingCoordinate(marker.position)
            }

        
        
        mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))


    }
    
    
    
}