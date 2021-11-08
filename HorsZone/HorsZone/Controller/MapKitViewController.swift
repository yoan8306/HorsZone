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
    var pointUserHistory: [CLLocationCoordinate2D] = []
    var timer: Timer?
    var counter = 0
    var startCheckPosition = false
    var polygonIdentity: [MKPolygon] = []
    
    // MARK: - IBoutlet
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedMap: UISegmentedControl!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var cleanLastZoneButton: UIButton!
    @IBOutlet weak var startMonitoringButton: UIButton!
    @IBOutlet weak var addZoneSwitch: UISwitch!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMapView()
    }
    
    /// take first point for make polygon
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canAddZone else {
            return
        }
        if let touch = touches.first {
            let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
            points.append(coordinate)
        }
    }
    
    /// create polyline for make polygon
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
    
    /// Create polygon
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canAddZone else {
            return
        }
        //        let newCoordinate = ZoneIdentify(context: AppDelegate.viewContext)
        //        try? AppDelegate.viewContext.save()
        let polygon = MKPolygon(coordinates: &points, count: points.count)
        mapView.addOverlay(polygon)
        polygonIdentity.append(polygon)
        points = [] // Reset points
    }
    
    // MARK: - IBAction
    
    /// disable user interface for draw polygon
    /// - Parameter sender: switch addZone
    @IBAction func addZoneSwitchAction(_ sender: Any) {
        if addZoneSwitch.isOn {
            addZoneOn()
            startMonitoringOff()
        } else {
            addZoneOff()
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
    
    /// change map view
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        segmentedMapStyle(segmentIndex: sender.selectedSegmentIndex)
    }
    
    /// start if user is in polygon
    @IBAction func startMonitoringActionButton() {
        addZoneOff()
        
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways else {
            presentAlert_Alert(alertMessage: "Veuillez activer la localisation")
            return
        }
        
        guard !startCheckPosition else {
            startMonitoringOff()
            return
        }
        startMonitoringOn()
    }
    
    /// check user each 3 secondes if user is in polygon
    @objc func checkPositionInPolygon() {
        counter += 1
        if counter == 3 {
            guard checkIfUserInPolygon() else {
                vibrate()
                presentAlert_Alert(alertMessage: "vous avez quitté la zone")
                counter = 0
                return
            }
            counter = 0
        }
    }
    
    /// erase last zone. no functionnaly
    @IBAction func cleanLastZoneAction(_ sender: Any) {
//  remove all zone modify on going
        mapView.removeOverlays(mapView.overlays)
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
        let segmentValue =  segmentedMap.titleForSegment(at: segmentIndex)
        
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
    
    /// check if user location is in polygonIdentity
    /// - Returns: if user is in polygon return true
    private func checkIfUserInPolygon() -> Bool {
        for zone in polygonIdentity {
            if zone.contain(coordonate: mapView.userLocation.coordinate) {
                return true
            }
        }
        return false
    }
    
    private func animateMonitoringButton() {
        UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCurlUp, animations: {
            self.startMonitoringButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCurlUp, animations: {
            self.startMonitoringButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .transitionCurlUp, animations: {
            self.startMonitoringButton.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    private func addZoneOff() {
        canAddZone = false
        mapView.isUserInteractionEnabled = true
        addZoneSwitch.isOn = false
        cleanLastZoneButton.isHidden = true
    }
    
    private func addZoneOn() {
        canAddZone = true
        mapView.isUserInteractionEnabled = false
        addZoneSwitch.isOn = true
        cleanLastZoneButton.isHidden = false
    }
    
    private func startMonitoringOff() {
        startMonitoringButton.backgroundColor? = .init(red: 0, green: 0, blue: 0, alpha: 0)
        startCheckPosition = false
        timer?.invalidate()
    }
    
    /// initialize timer and launch checkPositionInPolygon()
    private func startMonitoringOn() {
        startCheckPosition = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: #selector(checkPositionInPolygon), userInfo: nil, repeats: true)
        startMonitoringButton.backgroundColor = #colorLiteral(red: 0, green: 0.9866302609, blue: 0.837818563, alpha: 0.699257234)
        startMonitoringButton.layer.cornerRadius = startMonitoringButton.frame.height / 2
        animateMonitoringButton()
    }
    
    private func presentAlert_Alert (alertTitle title: String = "Erreur", alertMessage message: String, buttonTitle titleButton: String = "Ok", alertStyle style: UIAlertAction.Style = .cancel) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
    
    // make speed user and stock user point location
    /// - Parameters:
    ///   - manager: user locationManager
    ///   - locations: location user array
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for element in  locations {
            pointUserHistory.append(element.coordinate)
        }
        
        guard let speed = manager.location?.speed else { return }
        let speedConverted = speed / 1000 * 3600
        speedLabel.text = speed < 0 ? "No movement registered" : String(format: "%.0f", speedConverted) + " km/h"
        
        let polylines = MKPolyline(coordinates: &pointUserHistory, count: pointUserHistory.count)
        mapView.addOverlay(polylines)
        
        let roadViewer = MKPolylineRenderer(overlay: polylines)
        roadViewer.strokeColor = UIColor.red
        roadViewer.lineWidth = 3
    }
}

