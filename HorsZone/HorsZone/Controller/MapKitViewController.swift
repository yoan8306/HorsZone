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

    // MARK: - Properties
    var zoneRecord = ZoneIdentify.all
    var locationManager = CLLocationManager()
    var canAddZone = false
    var points = [CLLocationCoordinate2D]()
    var area: [CLLocationCoordinate2D] = []

    // MARK: - IBoutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedMap: UISegmentedControl!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var cleanLastZoneButton: UIButton!
    @IBOutlet weak var addZoneSwitch: UISwitch!
    
    

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canAddZone else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            
            points.append(coordinate)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canAddZone else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            points.append(coordinate)
            let polyLine = MKPolyline(coordinates: points, count: points.count)
            mapView.addOverlay(polyLine)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canAddZone else {
            return
        }
       
//        let newCoordinate = ZoneIdentify(context: AppDelegate.viewContext)
//        try? AppDelegate.viewContext.save()
        
        let polygon = MKPolygon(coordinates: &points, count: points.count)
        mapView.addOverlay(polygon)
        points = [] // Reset points
    }
    
    
    // MARK: - IBAction
    @IBAction func addZoneSwitchAction(_ sender: Any) {
        if addZoneSwitch.isOn {
            canAddZone = true
            mapView.isUserInteractionEnabled = false
        } else {
            canAddZone = false
            mapView.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func userLocationButton(_ sender: Any) {

        switch CLLocationManager.authorizationStatus() {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            mapView.setUserTrackingMode(.follow, animated: true)
        case .denied, .notDetermined, .restricted:
            presentAlert_Alert(alertMessage: "Veuillez activer la localisation.")
        default:
            presentAlert_Alert(alertMessage: "Vérifier si la localisation est activé")
        }
    }
    
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        segmentedMapStyle(segmentIndex: sender.selectedSegmentIndex)
    }
    
    
    @IBAction func cleanLastZoneAction(_ sender: Any) {
    }
    
    
    // MARK: - Private function
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
    
    private func segmentedMapStyle(segmentIndex: Int) {
        let segmentValue =  segmentedMap.titleForSegment(at: segmentIndex) //selectedSegmentIndex
        switch segmentValue {
        case "Standard":
            mapView.mapType = .standard
        case "Satellite":
            mapView.mapType = .satellite
        case "Hybrid":
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }
    
    private func presentAlert_Alert (alertTitle title: String = "Erreur", alertMessage message: String, buttonTitle titleButton: String = "Ok", alertStyle style: UIAlertAction.Style = .cancel) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
}

// MARK: - Function MapKit, location Manager
extension MapKitViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if canAddZone {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.darkGray
            polylineRenderer.lineWidth = 1
            
            return polylineRenderer
            
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.fillColor = .magenta
            polygonView.alpha = 0.3
            return polygonView
        }
        } else {
            if overlay is MKPolyline {
                let roadView = MKPolylineRenderer(overlay: overlay)
                roadView.strokeColor = UIColor.red
                roadView.lineWidth = 1
                return roadView
            }
        }
        
        return MKPolylineRenderer(overlay: overlay)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for element in  locations {
            area.append(element.coordinate)
        }
        
        guard let speed = manager.location?.speed else { return }
        let speedConverted = speed / 1000 * 3600
        speedLabel.text = speed < 0 ? "No movement registered" : String(format: "%.0f", speedConverted) + " km/h"
        
        let polylines = MKPolyline(coordinates: &area, count: area.count)
        mapView.addOverlay(polylines)
        
        let roadViewer = MKPolylineRenderer(overlay: polylines)
        roadViewer.strokeColor = UIColor.red
        roadViewer.lineWidth = 3
    }
}

