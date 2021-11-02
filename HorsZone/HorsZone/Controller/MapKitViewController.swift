//
//  MapKitViewController.swift
//  HorsZone
//
//  Created by Yoan on 02/11/2021.
//

import UIKit
import MapKit
import CoreLocation
import AudioToolbox

class MapKitViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var zoneRecord = ZoneIdentify.all
    var locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        
    }
    private func initializeMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true

        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        mapView.setUserTrackingMode(.follow, animated: true)
    }
}
