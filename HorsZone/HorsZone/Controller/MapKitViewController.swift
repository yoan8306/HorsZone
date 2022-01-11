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
import AVFoundation
import UserNotifications

class MapKitViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: - Properties
    private var currentPlace: CLPlacemark?
    
    // arrow user direction
    var headingImageView: UIImageView?
    var userHeading: CLLocationDirection?
    

    var zoneRecord = ZoneIdentify.all
    var locationManager = CLLocationManager()
    var distance : Double = 0.00
    var canAddZone = false
    var points = [CLLocationCoordinate2D]()
    var pointUserHistory: [CLLocationCoordinate2D] = []
    var timer: Timer?
    var counter = 0
    var startCheckPosition = false
    var polygonIdentity: [MKPolygon] = []
    var alertSong: AVAudioPlayer?
    let myNotification = LocalNotification()
    var translateText = Translate()
    var tappedAdress = true
    var startPosition: CLLocation!
    var lastPosition: CLLocation!
    var altitudeMin : CLLocationDistance = 0
    var altitudeMax : CLLocationDistance = 0
    var tappedAltitude = true
    
    // MARK: - IBoutlet
    @IBOutlet weak var mapBarItem: UITabBarItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedMap: UISegmentedControl!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var cleanLastZoneButton: UIButton!
    @IBOutlet weak var startMonitoringButton: UIButton!
    @IBOutlet weak var positionAdressUserLabel: UILabel!
    @IBOutlet weak var addZoneSwitch: UISwitch!
    @IBOutlet weak var addZoneLabel: UILabel!
    @IBOutlet weak var activityIndicatorAdress: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorAltitude: UIActivityIndicatorView!
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let name = Notification.Name(rawValue: "SortieZone")
        NotificationCenter.default.addObserver(self, selector: #selector(stopMonitoring),
                                               name: name, object: nil)
        initializeMapView()
        myNotification.notificationInitialize()
        let tappedAdress = UITapGestureRecognizer.init(target: self, action: #selector(MapKitViewController.tappedAdressLabel(_:)))
        positionAdressUserLabel.isUserInteractionEnabled = true
        positionAdressUserLabel.addGestureRecognizer(tappedAdress)
        
        let tappedAltitude = UITapGestureRecognizer.init(target: self, action: #selector(MapKitViewController.tappedAltitudeLabel(_:)))
        altitudeLabel.isUserInteractionEnabled = true
        altitudeLabel.addGestureRecognizer(tappedAltitude)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        translateText = Translate()
        initializeLanguageView()
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
        
        let polygon = MKPolygon(coordinates: points, count: points.count)
        mapView.addOverlay(polygon)
        polygonIdentity.append(polygon)
        
        // for save point
        //        let newCoordinate = ZoneIdentify(context: AppDelegate.viewContext)
        //        newCoordinate.name = "test"
        //        for element in points {
        //            let newPointsPolyline = PointList(context: AppDelegate.viewContext)
        //            newPointsPolyline.latitudeY = element.latitude
        //            newPointsPolyline.longitudeX = element.longitude
        //            newPointsPolyline.zoneIdentify = newCoordinate
        //            try? AppDelegate.viewContext.save()
        //        }
        //        print(newCoordinate.pointList)
        //        try? AppDelegate.viewContext.save()
        points = [] // Reset points
    }
    
    // MARK: - IBAction
    
    @objc func stopMonitoring() {
        startMonitoringOff()
    }
    
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
    
    /// User tracking. Center mapview  on user
    /// - Parameter sender: button
    @IBAction func userLocationButton(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorized, .authorizedAlways, .authorizedWhenInUse:
            
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            
        case .denied, .notDetermined, .restricted:
            presentAlert_Alert(alertTitle: translateText.alertLeftZoneTitle(), alertMessage: translateText.userLocalizationIssue())
        default:
            presentAlert_Alert(alertTitle: translateText.alertLeftZoneTitle(), alertMessage: "Vérifier si la localisation est activé")
        }
    }
    
    /// change map view
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        segmentedMapStyle(segmentIndex: sender.selectedSegmentIndex)
    }
    
    /// start if user is in polygon
    @IBAction func startMonitoringActionButton() {
        addZoneOff()
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse
                ||
                CLLocationManager.authorizationStatus() == .authorizedAlways else {
                    presentAlert_Alert(alertTitle: translateText.alertLeftZoneTitle(), alertMessage: translateText.userLocalizationIssue())
                    return
                }
        
        guard !startCheckPosition else {
            startMonitoringOff()
            return
        }
        startMonitoringOn()
    }
    
    /// check user each 3 secondes if user is in polygon
    /// Notification here
    @objc func checkPositionInPolygon() {
        counter += 1
        if counter == 5 {
            guard checkIfUserInPolygon() else {
                makeAlerte()
                counter = 0
                return
            }
            stopSong()
            counter = 0
        }
    }
    
    /// erase last zone. no functionnaly
    @IBAction func cleanLastZoneAction(_ sender: Any) {
        //  remove all zone modify on going
        mapView.removeOverlays(mapView.overlays)
        polygonIdentity.removeAll()
        //        let lastOverlay = mapView.overlays.count - 1
        //        mapView.removeOverlay(mapView.overlays[lastOverlay])
        //        polygonIdentity.remove(at: polygonIdentity.count - 1)
    }
    
    @IBAction func tappedAdressLabel(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended, .began, .changed:
            showPositionAdressUserLabel(show: false)
            if tappedAdress {
                tappedAdress = false
            } else {
                tappedAdress = true
            }
        case .cancelled, .failed:
            return
        default:
            return
        }
    }
    
    @IBAction func tappedAltitudeLabel(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended, .began, .changed:
            showAltitudeLabel(show: false)
            if tappedAltitude {
                tappedAltitude = false
            } else {
                tappedAltitude = true
            }
        case .cancelled, .failed:
            return
        default:
            return
        }
    }
    
    
    // MARK: - Private function
        
    private func initializeMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func initializeLanguageView() {
        startMonitoringButton.setTitle(translateText.buttonStartMonitoringText(), for: .normal)
        addZoneLabel.text = translateText.addZoneLabelText()
        cleanLastZoneButton.setTitle(translateText.cancelButtonText(), for: .normal)
        mapBarItem.title = translateText.mapBarItem()
    }
    
    private func segmentedMapStyle(segmentIndex: Int) {
        let segmentValue =  segmentedMap.titleForSegment(at: segmentIndex)
        
        switch segmentValue {
        case "Standard":
            mapView.mapType = .standard
        case "Satellite":
            mapView.mapType = .satelliteFlyover
        case "Hybrid":
            mapView.mapType = .hybridFlyover
        default:
            mapView.mapType = .standard
        }
    }
    
    /// check if user location is in polygonIdentity
    /// - Returns: if user is in polygon return true
    private func checkIfUserInPolygon() -> Bool {
        for zone in polygonIdentity {
            if let userPostion = locationManager.location?.coordinate {
                if zone.contain(coordonate: userPostion) {
                    return true
                }
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
    
    public func startMonitoringOff() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        locationManager.allowsBackgroundLocationUpdates = false
        startMonitoringButton.backgroundColor? = .init(red: 0, green: 0, blue: 0, alpha: 0)
        startCheckPosition = false
        startMonitoringButton.setTitle(translateText.buttonStartMonitoringText(), for: .normal)
        timer?.invalidate()
    }
    
    /// initialize timer and launch checkPositionInPolygon()
    private func startMonitoringOn() {
        locationManager.allowsBackgroundLocationUpdates = true
        startCheckPosition = true
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: #selector(checkPositionInPolygon), userInfo: nil, repeats: true)
        startMonitoringButton.backgroundColor = #colorLiteral(red: 0, green: 0.9866302609, blue: 0.837818563, alpha: 0.699257234)
        startMonitoringButton.layer.cornerRadius = startMonitoringButton.frame.height / 2
        startMonitoringButton.setTitle(translateText.buttonStopMonitoringText(), for: .normal)
        animateMonitoringButton()
    }
    
    private func makeAlerte() {
        playSong()
        vibrate()
        myNotification.sendNotification()
        presentAlert_Alert(alertTitle: translateText.alertLeftZoneTitle(), alertMessage: translateText.alertLeftZoneMessage())
    }
    
    private func playSong() {
        let path = Bundle.main.path(forResource: "orchestralEmergency.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            alertSong = try AVAudioPlayer(contentsOf: url)
            alertSong?.play()
        } catch {
            print("file isn't  food!")
        }
    }
    
    private func stopSong() {
        alertSong?.stop()
    }
    
    private func presentAlert_Alert (alertTitle title: String,
                                     alertMessage message: String,
                                     buttonTitle titleButton: String = "Ok",
                                     alertStyle style: UIAlertAction.Style = .cancel) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: titleButton, style: style, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    private func vibrate() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func showPositionAdressUserLabel(show: Bool) {
        positionAdressUserLabel.isHidden = !show
        activityIndicatorAdress.isHidden = show
    }
    
    private func showAltitudeLabel(show: Bool) {
        altitudeLabel.isHidden = !show
        activityIndicatorAltitude.isHidden = show
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
        
        getAddressLocalizationUser(locations: locations)
          
        for element in  locations {
            pointUserHistory.append(element.coordinate)
        }
        
       measureDistanceTravelled(locations: locations)
        
       
        getAltitude(locations: locations)
        
        guard let speed = manager.location?.speed else { return }
        let speedConverted = speed / 1000 * 3600
        speedLabel.text = speed < 0 ? "0 km/h" : String(format: "%.0f", speedConverted) + " km/h"
        
        let polylines = MKPolyline(coordinates: &pointUserHistory, count: pointUserHistory.count)
        mapView.addOverlay(polylines)
        
        let roadViewer = MKPolylineRenderer(overlay: polylines)
        roadViewer.strokeColor = UIColor.red
        roadViewer.lineWidth = 3
    }
    
    private func getAddressLocalizationUser(locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard let firstPlace = places?.first else {
                return
            }
            self.createAdress(firstPlace: firstPlace)
        }
    }
    
    private func createAdress(firstPlace: CLPlacemark ) {
        var addressString = ""
        showPositionAdressUserLabel(show: true)
        if tappedAdress {
            if let name = firstPlace.name {
                addressString = addressString + name + ", "
            }
            if let subLocality = firstPlace.subLocality {
                addressString = addressString + subLocality + ", "
            }
            //        if let thoroughfare = firstPlace.thoroughfare {
            //           addressString = addressString + thoroughfare + ", "
            //        }
            //        if let postalCode = firstPlace.postalCode {
            //            addressString = addressString + postalCode + ", "
            //        }
            if let locality = firstPlace.locality {
                addressString = addressString + locality
            }
            
        } else {
            let coordinate = mapView.userLocation.coordinate
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            addressString = translateText.latitudeTranslate() + ": " + String(format: "%.6f", latitude) + "\n\(translateText.longitudeTranslate()): " + String(format: "%.6f", longitude)
        }
        self.positionAdressUserLabel.text = addressString
    }
    
    private func measureDistanceTravelled(locations: [CLLocation]) {
        if startPosition == nil {
            startPosition = locations.first
        } else if let location = locations.last {
            distance += lastPosition.distance(from: location)
            let distanceConvert = distance / 1000
            distanceLabel.text = String(format: "%.2f", distanceConvert) + " km"
        }
        lastPosition = locations.last
    }
    
    private func getAltitude(locations: [CLLocation]) {
        guard let altitude =  locations.last?.altitude else { return }
        
        for position in locations {
            if position.altitude > altitudeMax {
                altitudeMax = position.altitude
            }
            if position.altitude < altitudeMin {
                altitudeMin = position.altitude
            }
        }
        
        if tappedAltitude {
        altitudeLabel.text = "Alt:" + String(format: "%.0f", altitude) + " m"
        } else {
            altitudeLabel.text = "Min: " + String(format: "%.0f", altitudeMin) + " m" + " ... Max: " + String(format: "%.0f", altitudeMax) + " m"
        }
        showAltitudeLabel(show: true)
    }
}


// MARK: - Arrow user direction
extension MapKitViewController {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if views.last?.annotation is MKUserLocation {
            addHeadingView(toAnnotationView: views.last!)
        }
    }
    
    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        if headingImageView == nil {
            let image = UIImage(named: "arrowDirection")
            if let image = image {
                headingImageView = UIImageView(image: image)
                headingImageView!.frame = CGRect(x: (annotationView.frame.size.width - image.size.width)/2, y: (annotationView.frame.size.height - image.size.height)/2, width: image.size.width, height: image.size.height)
                annotationView.insertSubview(headingImageView!, at: 0)
                headingImageView!.isHidden = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
         if newHeading.headingAccuracy < 0 { return }

         let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
         userHeading = heading
         updateHeadingRotation()
        }
    
    func updateHeadingRotation() {
        if let heading = locationManager.heading?.trueHeading, let headingImageView = headingImageView {
            headingImageView.isHidden = false
            let rotation = CGFloat(heading/180 * Double.pi)
            headingImageView.transform = CGAffineTransform(rotationAngle: rotation)
        }
    }
}
