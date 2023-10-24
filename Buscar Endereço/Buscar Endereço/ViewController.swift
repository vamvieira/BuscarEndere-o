//
//  ViewController.swift
//  Buscar Endereço
//
//  Created by Usuário Convidado on 24/10/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var textEndereco: UITextField!
    @IBOutlet weak var mapa: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapa.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    @IBAction func buscar(_ sender: Any) {
        localizarendereco()
    }
    
    
    func localizarendereco(){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textEndereco.text!) { placemarks, error in
            guard let placemarks = placemarks, let location = placemarks.first?.location
            else {
                print("Não encontrou o endereço")
                return
            }
            print(location)
            self.rota(destinatioCord: location.coordinate)
        }
    }
    
    func rota(destinatioCord: CLLocationCoordinate2D){
        let sourceCordinate = (locationManager.location?.coordinate)!
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destinatioCord)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print("Alguma coisa deu errada \(error.localizedDescription)")
                }
                return
            }
            let route = response.routes[0]
            self.mapa.addOverlay(route.polyline)
            self.mapa.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
}
