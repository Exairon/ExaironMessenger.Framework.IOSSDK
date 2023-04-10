///
//  LocationViewController.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 10.04.2023.
//

import Foundation
import MapKit
import CoreLocation

class LocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var senderButton: UILabel!
    
    var locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Harita ayarları
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        iconView.addGestureRecognizer(tapGestureRecognizer)
        iconView.layer.cornerRadius = 25
        
        senderButton.layer.cornerRadius = 20
        senderButton.clipsToBounds = true
        
        let tapSender = UITapGestureRecognizer(target: self, action: #selector(sendMessageClicked))
        senderButton.isUserInteractionEnabled = true
        senderButton.addGestureRecognizer(tapSender)
        
        self.modalPresentationStyle = .fullScreen
    }
    
    @objc func viewTapped() {
        self.dismiss(animated: true)
    }
    
    @objc func sendMessageClicked() {
        if latitude != nil && longitude != nil {
            sendLocationMessage(latitude: latitude!, longitude: longitude!)
            self.dismiss(animated: true)
        }
    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let _latitude = coordinate.latitude
        let _longitude = coordinate.longitude
        
        latitude = _latitude
        longitude = _longitude
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: _latitude, longitude: _longitude)
        annotation.title = Localization.init().locale(key: "targetLocation")
        mapView.addAnnotation(annotation)
    }
    
    func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                // Konum hizmetleri etkinleştirildi, konum hizmetlerine erişim izni var mı kontrol et
                checkLocationAuthorization()
            } else {
                // Konum hizmetleri devre dışı, kullanıcıya konum hizmetlerini etkinleştirmelerini söyle
                print("Location services disabled")
            }
        }
        
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Konum hizmetlerine erişim izni var, konum güncellemelerini al
            locationManager.startUpdatingLocation()
        case .denied:
            // Kullanıcı konum hizmetlerine erişim iznini reddetti, konum hizmetlerini kullanamazsınız
            print("Location access denied")
        case .notDetermined:
            // Kullanıcı henüz konum hizmetleri için bir seçim yapmadı, konum hizmetlerine erişim izni iste
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Konum hizmetleri
            print("Location access restricted")
        case .authorizedAlways:
            // Konum hizmetlerine sürekli erişim izni var, konum güncellemelerini al
            locationManager.startUpdatingLocation()
        @unknown default:
            // Yeni bir CLAuthorizationStatus durumu eklendiğinde
            fatalError("Unknown location authorization status")
        }
    }
}


extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Konum değiştiğinde haritayı konuma göre merkezle
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        annotation.title = Localization.init().locale(key: "currentLocation")
        mapView.addAnnotation(annotation)
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        // Konum güncellemelerini durdur
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Konum hizmetlerine erişim izni değişti, kontrol et
        checkLocationAuthorization()
    }
}

// MKMapViewDelegate yöntemleri
extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        // Seçilen konumla ilgili işlemler yapın
        print("Selected location: \(annotation.coordinate)")
    }
}
