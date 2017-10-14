//
//  ViewController.swift
//  Veður
//
//  Created by Benedikt Óskarsson on 20/08/2017.
//  Copyright © 2017 Benzi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    var appServer = AppServer()
    var requestAndPraser = WeatherRequestAndPraser()
    var closestStation: Station?
    @IBOutlet weak var townLbl: UILabel!
    @IBOutlet weak var areaLbl: UILabel!
    @IBOutlet weak var windDirectionLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var heatLbl: UILabel!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var smallestDistance: CLLocationDistance?
        var tempStation = Station()
        
        //When we get the location, we calculate which station is closest to the user location
        if let userLocation = manager.location {
            for station in appServer.getStations() {
                let location = CLLocation(latitude: station.latitude, longitude: station.longitude)
                let distance = userLocation.distance(from: location)
                if smallestDistance == nil || distance < smallestDistance! {
                    smallestDistance = distance
                    tempStation = station
                }
            }
            closestStation = tempStation
            let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
            let userLocation2D: CLLocationCoordinate2D = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude )
            let region: MKCoordinateRegion = MKCoordinateRegionMake(userLocation2D, span)
             
        }
        
        if let currentStation = closestStation {
            requestAndPraser.getObservasion(stationID: currentStation.stationNumber) { (inner: () throws -> observasion) -> Void in
                do {
                    let result = try inner()
                    print(self.closestStation?.name)
                    print(result)
                } catch _ {
                    
                }
            }
            
        }
        
        if let currentStation = closestStation {
            requestAndPraser.getForecast(stationID: currentStation.stationNumber) { (inner: () throws -> [foreCast?]) -> Void in
                do {
                    let result = try inner()
                    print(self.closestStation?.name)
                    print(result)
                } catch _ {
                    
                }
            }
            
        }

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appServer.loadStations()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

