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

class DetailViewController: UIViewController {
    
    @IBOutlet weak var googleMap: UIView!
    //@IBOutlet weak var detailMap: MKMapView!
    var bankName = String()
    var bankAddresses = [String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.cameraWithLatitude(21.28, longitude: -157.8, zoom: 6)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "VTB24"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        
        
        self.view = mapView
        
        //let location = CLLocation.init(latitude: 21.282778, longitude: -157.829444)

        //forwardGeocoding("Yaroslavl")
        
        print("detail did load\n")
        print(bankAddresses)
        
    }

    
    /*func centerMap(location: CLLocation) {
        let radius: CLLocationDistance = 100
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, radius * 2, radius * 2)
        detailMap.setRegion(region, animated: true)
        
    }
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                
                self.centerMap(location!)
                
                if placemark?.areasOfInterest?.count > 0 {
                    let areaOfInterest = placemark!.areasOfInterest![0]
                    print(areaOfInterest)
                } else {
                    print("No area of interest found.")
                }
            }
        })
    }*/
    
}